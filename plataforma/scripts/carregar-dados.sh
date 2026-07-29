#!/usr/bin/env bash
# Indexa dados de exemplo DIRETO no Elasticsearch.
#
# Por que não usamos /api/sample_data do Kibana: a partir do 9.x esse
# endpoint é uma API interna e recusa chamadas externas
# ("not available with the current configuration"). Indexar direto no
# Elasticsearch não tem essa limitação e ainda é mais didático.
#
# IDEMPOTÊNCIA: o subir.sh pode ser rodado várias vezes. Sem a trava abaixo,
# cada execução somaria mais 720 documentos ao índice e os gráficos das lições
# ficariam com volume errado. Para reindexar do zero: ./carregar-dados.sh --forcar
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"
INDEX="onp-web-logs"
FORCAR="${1:-}"

# ------------------------------------------------------- trava de duplicação
EXISTENTES=$(curl -s -u "$AUTH" "$ES/${INDEX}/_count" 2>/dev/null \
  | grep -o '"count":[0-9]*' | head -1 | cut -d: -f2)
EXISTENTES="${EXISTENTES:-0}"

if [ "$FORCAR" = "--forcar" ]; then
  echo "==> --forcar: apagando o índice ${INDEX} antes de recriar"
  curl -s -u "$AUTH" -X DELETE "$ES/${INDEX}" -o /dev/null
  EXISTENTES=0
elif [ "$EXISTENTES" -ge 700 ] 2>/dev/null; then
  echo "==> ${INDEX} já tem ${EXISTENTES} documentos — nada a fazer."
  echo "    Para reindexar do zero: ./scripts/carregar-dados.sh --forcar"
  exit 0
fi

echo "==> Criando o índice ${INDEX}"
curl -s -u "$AUTH" -X PUT "$ES/${INDEX}" -H 'Content-Type: application/json' -d '{
  "mappings": { "properties": {
    "@timestamp":  { "type": "date" },
    "bytes":       { "type": "long" },
    "response":    { "type": "keyword" },
    "url":         { "type": "keyword" },
    "clientip":    { "type": "ip" },
    "extension":   { "type": "keyword" },
    "geo":     { "properties": { "src": {"type":"keyword"}, "dest": {"type":"keyword"},
                                 "coordinates": {"type":"geo_point"} } },
    "machine": { "properties": { "os": {"type":"keyword"}, "ram": {"type":"long"} } },
    "user_agent": { "properties": { "original": {"type":"keyword"} } }
  }}}' -o /dev/null -w "   índice: HTTP %{http_code}\n"

echo "==> Gerando 14 dias de tráfego (~720 documentos) via _bulk"
PAISES="BR US DE IN CN GB FR JP CA BR BR US"
LONS="-47.9 -95.7 10.4 78.9 104.2 -3.4 2.2 138.3 -106.3 -47.9 -46.6 -122.4"
LATS="-15.8 37.1 51.2 20.6 35.9 55.4 46.2 36.2 56.1 -15.8 -23.5 37.8"
URLS="/ /produtos /carrinho /checkout /api/login /api/pedidos /sobre /produto/1138"
SOS="win osx ios android win win linux"
EXTS="html css js png json"
UAS="Mozilla/5.0|curl/8.4.0|PostmanRuntime/7.39"

BULK=$(mktemp); AGORA=$(date +%s); SEED=$AGORA
n() { SEED=$(( (SEED * 1103515245 + 12345) % 2147483648 )); echo $(( (SEED / 65536) % $1 )); }
campo() { echo "$1" | tr ' |' '\n\n' | awk -v i="$2" 'NR==i'; }

i=0
while [ $i -lt 720 ]; do
  TS=$(( AGORA - i * 1680 ))
  ISO=$(date -u -d "@${TS}" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -r "${TS}" +"%Y-%m-%dT%H:%M:%SZ")
  IDX=$(( $(n 12) + 1 ))
  PAIS=$(campo "$PAISES" $IDX); LON=$(campo "$LONS" $IDX); LAT=$(campo "$LATS" $IDX)
  R=$(n 100)
  if   [ "$R" -lt 78 ]; then RESP=200
  elif [ "$R" -lt 88 ]; then RESP=404
  elif [ "$R" -lt 95 ]; then RESP=301
  else                       RESP=500; fi
  BYTES=$(( $(n 8000) + 200 ))
  URL=$(campo "$URLS" $(( $(n 8) + 1 )))
  SO=$(campo "$SOS" $(( $(n 7) + 1 )))
  EXT=$(campo "$EXTS" $(( $(n 5) + 1 )))
  UA=$(campo "$UAS" $(( $(n 3) + 1 )))
  IP="$(( $(n 223) + 1 )).$(n 256).$(n 256).$(n 256)"
  RAM=$(( ($(n 16) + 2) * 1073741824 ))
  printf '{"index":{}}\n' >> "$BULK"
  printf '{"@timestamp":"%s","bytes":%s,"response":"%s","url":"%s","clientip":"%s","extension":"%s","geo":{"src":"%s","dest":"BR","coordinates":{"lon":%s,"lat":%s}},"machine":{"os":"%s","ram":%s},"user_agent":{"original":"%s"}}\n' \
    "$ISO" "$BYTES" "$RESP" "$URL" "$IP" "$EXT" "$PAIS" "$LON" "$LAT" "$SO" "$RAM" "$UA" >> "$BULK"
  i=$(( i + 1 ))
done

curl -s -u "$AUTH" -X POST "$ES/${INDEX}/_bulk" \
  -H 'Content-Type: application/x-ndjson' --data-binary "@${BULK}" \
  -o /dev/null -w "   bulk: HTTP %{http_code}\n"
rm -f "$BULK"
curl -s -u "$AUTH" -X POST "$ES/${INDEX}/_refresh" -o /dev/null
TOTAL=$(curl -s -u "$AUTH" "$ES/${INDEX}/_count" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "   documentos: ${TOTAL}"

echo "==> Criando a data view no Kibana"
curl -s -u "$AUTH" -X POST "http://localhost:5601/api/data_views/data_view" \
  -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
  -d "{\"data_view\":{\"title\":\"${INDEX}*\",\"name\":\"ONP Web Logs\",\"timeFieldName\":\"@timestamp\"}}" \
  -o /dev/null -w "   data view: HTTP %{http_code}\n"
echo "Pronto. Discover > data view 'ONP Web Logs' > time range 'Last 15 days'."
