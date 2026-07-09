#!/usr/bin/env bash
# Carrega dados de exemplo direto no Elasticsearch (web logs realistas).
#
# Por que não usamos a API de sample data do Kibana: a partir do Kibana 9.x,
# o endpoint /api/sample_data/* virou API INTERNA e é bloqueado para chamadas
# externas (curl/script) — retorna "not available with the current
# configuration". Indexar direto no Elasticsearch não tem essa restrição,
# é mais didático (você vê o dado nascer) e não quebra a cada versão nova.
#
# O índice criado se chama kibana_sample_data_logs para manter compatibilidade
# com todo o material do curso (roteiros, desafios e visualizações).
#
# Uso: ./scripts/carregar-dados.sh
set -uo pipefail
if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado. Copie .env.example para .env antes de continuar."
  exit 1
fi
ES="http://localhost:9200"
KB="http://localhost:5601"
AUTH="elastic:${ELASTIC_PASSWORD}"
INDEX="kibana_sample_data_logs"

echo "==> Aguardando o Elasticsearch..."
for i in $(seq 1 30); do
  if curl -s -u "${AUTH}" "${ES}/_cluster/health" | grep -q '"status"'; then
    echo "Elasticsearch disponível."; break
  fi
  echo "   ...ainda subindo (tentativa ${i}/30)"; sleep 5
done

echo "==> Criando o índice ${INDEX} com mapping (geo_point + campos ECS)"
curl -s -u "${AUTH}" -X PUT "${ES}/${INDEX}" -H 'Content-Type: application/json' -d '{
  "mappings": { "properties": {
    "@timestamp":       { "type": "date" },
    "bytes":            { "type": "long" },
    "response":         { "type": "keyword" },
    "url":              { "type": "keyword" },
    "geo": { "properties": {
      "src":            { "type": "keyword" },
      "dest":           { "type": "keyword" },
      "coordinates":    { "type": "geo_point" }
    }},
    "machine": { "properties": {
      "os":             { "type": "keyword" },
      "ram":            { "type": "long" }
    }},
    "clientip":         { "type": "ip" },
    "extension":        { "type": "keyword" },
    "tags":             { "type": "keyword" }
  }}
}' -o /dev/null -w "   índice: HTTP %{http_code}\n"

echo "==> Gerando ~720 documentos (14 dias de tráfego) via _bulk"
PAISES=(BR US DE IN CN GB FR JP CA BR BR US)          # BR enviesado (mais tráfego)
COORDS=("-47.9 -15.8" "-95.7 37.1" "10.4 51.2" "78.9 20.6" "104.2 35.9" "-3.4 55.4" "2.2 46.2" "138.3 36.2" "-106.3 56.1" "-47.9 -15.8" "-46.6 -23.5" "-122.4 37.8")
OS=(win osx ios android win win linux)
URLS=("/" "/produtos" "/carrinho" "/checkout" "/api/login" "/api/pedidos" "/sobre" "/produto/1138")
EXT=(html css js png json)

BULK=$(mktemp)
now=$(date +%s)
for d in $(seq 0 719); do
  ts=$(( now - d*1680 ))                              # ~1 doc a cada 28 min, 14 dias
  iso=$(date -u -d "@${ts}" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -r "${ts}" +"%Y-%m-%dT%H:%M:%SZ")
  idx=$(( RANDOM % 12 )); pais=${PAISES[$idx]}; coord=${COORDS[$idx]}
  lon=${coord% *}; lat=${coord#* }
  r=$(( RANDOM % 100 ))
  if   [ $r -lt 78 ]; then resp=200
  elif [ $r -lt 88 ]; then resp=404
  elif [ $r -lt 95 ]; then resp=301
  else resp=500; fi
  bytes=$(( (RANDOM % 8000) + 200 ))
  url=${URLS[$((RANDOM % 8))]}; osv=${OS[$((RANDOM % 7))]}; ext=${EXT[$((RANDOM % 5))]}
  ip="$((RANDOM%223+1)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
  printf '{"index":{}}\n' >> "$BULK"
  printf '{"@timestamp":"%s","bytes":%d,"response":"%d","url":"%s","geo":{"src":"%s","dest":"BR","coordinates":{"lon":%s,"lat":%s}},"machine":{"os":"%s","ram":%d},"clientip":"%s","extension":"%s","tags":["success"]}\n' \
    "$iso" "$bytes" "$resp" "$url" "$pais" "$lon" "$lat" "$osv" "$(((RANDOM%16+2)*1073741824))" "$ip" "$ext" >> "$BULK"
done
curl -s -u "${AUTH}" -X POST "${ES}/${INDEX}/_bulk" \
  -H 'Content-Type: application/x-ndjson' --data-binary "@${BULK}" \
  -o /dev/null -w "   bulk: HTTP %{http_code}\n"
rm -f "$BULK"
curl -s -u "${AUTH}" -X POST "${ES}/${INDEX}/_refresh" -o /dev/null

total=$(curl -s -u "${AUTH}" "${ES}/${INDEX}/_count" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "   documentos indexados: ${total}"

echo "==> Criando a data view no Kibana (chamada de UI, não é API bloqueada)"
curl -s -u "${AUTH}" -X POST "${KB}/api/data_views/data_view" \
  -H "kbn-xsrf: true" -H 'Content-Type: application/json' -d "{
    \"data_view\": { \"title\": \"${INDEX}*\", \"name\": \"Kibana Sample Data Logs\", \"timeFieldName\": \"@timestamp\" }
  }" -o /dev/null -w "   data view: HTTP %{http_code}\n"

echo ""
echo "Pronto! Índice ${INDEX} com ${total} documentos + data view criada."
echo "Abra ${KB} > Discover, selecione 'Kibana Sample Data Logs' e ajuste o"
echo "time range para 'Last 15 days'. Campos: response, bytes, geo.src,"
echo "geo.coordinates (mapa), machine.os, url."
