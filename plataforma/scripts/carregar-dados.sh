#!/usr/bin/env bash
# =============================================================================
#  carregar-dados.sh — indexa os dados de exemplo DIRETO no Elasticsearch.
# =============================================================================
#  Por que não usamos /api/sample_data do Kibana: a partir do 9.x esse
#  endpoint é uma API interna e recusa chamadas externas
#  ("not available with the current configuration").
#
#  DUAS ARMADILHAS DE WINDOWS JÁ CORRIGIDAS AQUI
#
#  1. Arquivo temporário no curl.
#     A versão original gerava o NDJSON num arquivo e mandava com
#     `--data-binary "@/tmp/arquivo"`. No Git Bash o curl do PATH costuma ser
#     o build nativo do Windows (/mingw64/bin/curl), que não entende caminho
#     POSIX sozinho — depende da conversão do MSYS, que MSYS_NO_PATHCONV=1
#     desliga. O índice era criado e o _bulk nunca carregava: zero documentos,
#     zero erro. Agora o NDJSON vai por STDIN (`--data-binary @-`).
#
#  2. Fork em excesso no gerador.
#     A versão em shell puro chamava `date`, subshells de PRNG e um
#     `echo | tr | awk` por campo — cerca de 26 processos POR DOCUMENTO,
#     ~19.000 no total. No Linux são segundos; no Git Bash, onde o MSYS
#     emula fork() sobre a API do Windows a dezenas de ms por spawn, passa
#     de 15 minutos e parece travado. Agora o NDJSON inteiro sai de UM
#     único processo awk, em menos de um segundo.
#
#     Detalhe: o timestamp sai como epoch em milissegundos (número), não
#     string ISO. Evita depender de strftime(), que é extensão do gawk e nem
#     todo awk tem. O Elasticsearch lê nativamente — o mapping declara
#     `strict_date_optional_time||epoch_millis`.
#
#  Uso:
#     ./scripts/carregar-dados.sh            carrega se estiver vazio
#     ./scripts/carregar-dados.sh --forcar   apaga o índice e reindexa
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"
INDEX="onp-web-logs"
FORCAR="${1:-}"
TOTAL_DOCS=720

conta() {
  curl -s -u "$AUTH" "$ES/${INDEX}/_count" 2>/dev/null \
    | grep -o '"count":[0-9]*' | head -1 | cut -d: -f2
}

EXISTENTES=$(conta); EXISTENTES="${EXISTENTES:-0}"

if [ "$FORCAR" = "--forcar" ]; then
  echo "==> --forcar: apagando o índice ${INDEX}"
  curl -s -u "$AUTH" -X DELETE "$ES/${INDEX}" -o /dev/null
  EXISTENTES=0
elif [ "$EXISTENTES" -ge 700 ] 2>/dev/null; then
  echo "==> ${INDEX} já tem ${EXISTENTES} documentos — nada a fazer."
  echo "    Para reindexar do zero: ./scripts/carregar-dados.sh --forcar"
  exit 0
elif [ "$EXISTENTES" -gt 0 ] 2>/dev/null; then
  echo "==> ${INDEX} tem só ${EXISTENTES} documentos (carga anterior incompleta)."
  echo "    Recriando do zero."
  curl -s -u "$AUTH" -X DELETE "$ES/${INDEX}" -o /dev/null
fi

# `referrer` fica mapeado mas o gerador NUNCA a preenche, de propósito:
# é o campo do desafio autônomo da Lição 1.3 (achar via Discover um campo
# mapeado com 0% de preenchimento).
echo "==> Criando o índice ${INDEX}"
CODIGO=$(curl -s -u "$AUTH" -X PUT "$ES/${INDEX}" -H 'Content-Type: application/json' -d '{
  "mappings": { "properties": {
    "@timestamp":  { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
    "bytes":       { "type": "long" },
    "response":    { "type": "keyword" },
    "url":         { "type": "keyword" },
    "clientip":    { "type": "ip" },
    "extension":   { "type": "keyword" },
    "geo":     { "properties": { "src": {"type":"keyword"}, "dest": {"type":"keyword"},
                                 "coordinates": {"type":"geo_point"} } },
    "machine": { "properties": { "os": {"type":"keyword"}, "ram": {"type":"long"} } },
    "user_agent": { "properties": { "original": {"type":"keyword"} } },
    "referrer": { "type": "keyword" }
  }}}' -o /dev/null -w '%{http_code}')
echo "   índice: HTTP ${CODIGO}"
if [ "$CODIGO" != "200" ] && [ "$CODIGO" != "201" ]; then
  echo "   ERRO: não consegui criar o índice. Resposta do Elasticsearch:"
  curl -s -u "$AUTH" -X PUT "$ES/${INDEX}" -H 'Content-Type: application/json' -d '{}' | head -c 400
  echo; exit 1
fi

# ---------------------------------------------------------------------------
#  Gerador: UM processo awk, sem fork por documento.
#
#  PRNG: Lehmer / MINSTD  ->  semente = (semente * 16807) mod 2147483647
#  Multiplicador pequeno de propósito: o produto máximo (~3,6e13) cabe com
#  folga na precisão exata de double do awk (2^53 ~ 9e15). Com o 1103515245
#  do rand() clássico o produto passaria de 2e18 e a aritmética perderia
#  precisão em silêncio, gerando valores degenerados.
#
#  ESPAÇAMENTO NÃO É CONSTANTE DE PROPÓSITO (correção pós-lançamento).
#  A primeira versão usava `ts = agora - i*1680`: intervalo fixo, sem
#  nenhuma variação na taxa de eventos. Resultado: 2-3 documentos por hora,
#  o tempo todo, por 14 dias — zero desvio real para detectar. Um job de ML
#  (Lab 5.1) rodava, fechava, e devolvia ZERO anomaly records: nada para
#  clicar no Single Metric Viewer, Anomaly Explorer vazio, Forecast sem
#  graça. Agora dois blocos da janela têm espaçamento diferente: uma rajada
#  (pico de tráfego, ~3 dias atrás) e um vão largo (queda/indisponibilidade,
#  ~6,5 dias atrás) — desvios de verdade pro detector `count` encontrar.
#
#  MESMO PROBLEMA EM DOIS OUTROS CAMPOS (Lab 5.2):
#  `clientip` era 100% aleatório por documento -> cardinalidade 720/720, sem
#  NENHUM IP repetido. Um job `population` (count over clientip) não acha
#  outlier porque não existe "população": todo mundo visita 1x só. Agora um
#  pool fixo de IPs "normais" se repete (comportamento de visitante regular)
#  e um IP fixo aparece bem mais que os outros (o outlier que o job acha).
#  `url` tinha distribuição quase uniforme entre as 8 rotas -> um job `rare`
#  não encontra nada raro porque nada É raro. Agora dois documentos forçam
#  a rota /admin/debug, que nunca mais se repete -- a "agulha no palheiro"
#  que o detector `rare` existe para achar.
# ---------------------------------------------------------------------------
echo "==> Gerando e indexando ${TOTAL_DOCS} documentos (14 dias de tráfego)"

AGORA=$(date +%s)

gera_ndjson() {
  awk -v total="$TOTAL_DOCS" -v agora="$AGORA" -v semente="$AGORA" '
  function rnd(m) { semente = (semente * 16807) % 2147483647; return int(semente % m) }
  BEGIN {
    np = split("BR US DE IN CN GB FR JP CA BR BR US", pais, " ")
    split("-47.9 -95.7 10.4 78.9 104.2 -3.4 2.2 138.3 -106.3 -47.9 -46.6 -122.4", lon, " ")
    split("-15.8 37.1 51.2 20.6 35.9 55.4 46.2 36.2 56.1 -15.8 -23.5 37.8", lat, " ")
    nu = split("/ /produtos /carrinho /checkout /api/login /api/pedidos /sobre /produto/1138", url, " ")
    ns = split("win osx ios android win win linux", so, " ")
    ne = split("html css js png json", ext, " ")
    na = split("Mozilla/5.0 curl/8.4.0 PostmanRuntime/7.39", ua, " ")

    npool = 40
    for (p = 1; p <= npool; p++) ip_pool[p] = (rnd(223) + 1) "." rnd(256) "." rnd(256) "." rnd(256)
    ip_outlier = "198.51.100.77"

    cum = 0
    for (i = 0; i < total; i++) {
      # rajada (pico): ~83min de janela com evento a cada ~4min, em vez de 28min
      if      (i >= 150 && i < 170) delta = 250
      # rajada de um unico IP (scraper): ~50min, evento a cada ~100s, sempre o mesmo IP
      else if (i >= 300 && i < 330) delta = 100
      # vão largo (queda/indisponibilidade): ~27h de janela com evento a cada ~108min
      else if (i >= 400 && i < 415) delta = 6500
      else                          delta = 1680
      if (i > 0) cum += delta
      ts = (agora - cum) * 1000
      k  = rnd(np) + 1
      r  = rnd(100)
      if      (r < 78) resp = 200
      else if (r < 88) resp = 404
      else if (r < 95) resp = 301
      else             resp = 500
      bytes = rnd(8000) + 200
      if      (i >= 300 && i < 330) ip = ip_outlier
      else if (rnd(100) < 3)        ip = ip_outlier
      else                          ip = ip_pool[rnd(npool) + 1]
      if (i == 500 || i == 501) urlv = "/admin/debug"
      else                       urlv = url[rnd(nu) + 1]
      ram = (rnd(16) + 2) * 1073741824

      printf "{\"index\":{}}\n"
      printf "{\"@timestamp\":%d,\"bytes\":%d,\"response\":\"%d\",\"url\":\"%s\",\"clientip\":\"%s\",\"extension\":\"%s\",\"geo\":{\"src\":\"%s\",\"dest\":\"BR\",\"coordinates\":{\"lon\":%s,\"lat\":%s}},\"machine\":{\"os\":\"%s\",\"ram\":%d},\"user_agent\":{\"original\":\"%s\"}}\n", \
        ts, bytes, resp, urlv, ip, ext[rnd(ne)+1], \
        pais[k], lon[k], lat[k], so[rnd(ns)+1], ram, ua[rnd(na)+1]
    }
  }'
}

LINHAS=$(gera_ndjson | wc -l | tr -d ' ')
echo "   linhas geradas: ${LINHAS} (esperado: $((TOTAL_DOCS * 2)))"
if [ "$LINHAS" -lt $((TOTAL_DOCS * 2)) ] 2>/dev/null; then
  echo "   ERRO: o gerador não produziu o esperado."
  echo "   Teste o awk isoladamente:  awk 'BEGIN{print \"awk ok\"}'"
  exit 1
fi

CODIGO=$(gera_ndjson | curl -s -u "$AUTH" -X POST "$ES/${INDEX}/_bulk" \
  -H 'Content-Type: application/x-ndjson' --data-binary @- \
  -o /dev/null -w '%{http_code}')
echo "   bulk: HTTP ${CODIGO}"

curl -s -u "$AUTH" -X POST "$ES/${INDEX}/_refresh" -o /dev/null
FINAL=$(conta); FINAL="${FINAL:-0}"
echo "   documentos indexados: ${FINAL}"

if [ "$FINAL" -lt 700 ] 2>/dev/null; then
  echo
  echo "   ERRO: esperava ${TOTAL_DOCS} documentos, encontrei ${FINAL}."
  echo "   Para ver o que o Elasticsearch respondeu ao bulk:"
  echo "     ./scripts/carregar-dados.sh --forcar 2>&1 | tail -20"
  exit 1
fi

echo "==> Criando a data view no Kibana"
CODIGO=$(curl -s -u "$AUTH" -X POST "http://localhost:5601/api/data_views/data_view" \
  -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
  -d "{\"data_view\":{\"title\":\"${INDEX}*\",\"name\":\"ONP Web Logs\",\"timeFieldName\":\"@timestamp\"}}" \
  -o /dev/null -w '%{http_code}')
case "$CODIGO" in
  200|201) echo "   data view: criada" ;;
  400|409) echo "   data view: já existia" ;;
  *)       echo "   data view: HTTP ${CODIGO} (crie manualmente se precisar)" ;;
esac

echo "Pronto. Discover > data view 'ONP Web Logs' > time range 'Last 15 days'."
