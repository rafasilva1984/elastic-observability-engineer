#!/usr/bin/env bash
# Cria o índice logs-aula5 com o pipeline como default_pipeline (assim TODO
# documento indexado passa pelo pipeline automaticamente) e indexa as linhas
# de examples/logs-brutos.log.
# Uso: ./scripts/indexar-logs.sh

set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Criando índice logs-aula5 com index.default_pipeline=onp-logs-app"
curl -s -u "$AUTH" -X PUT "$ES/logs-aula5" -H "Content-Type: application/json" -d '
{ "settings": { "index.default_pipeline": "onp-logs-app" } }' >/dev/null || true

echo "==> Indexando linhas de examples/logs-brutos.log"
while IFS= read -r linha; do
  [ -z "$linha" ] && continue
  msg=$(printf '%s' "$linha" | sed 's/\\/\\\\/g; s/"/\\"/g')
  curl -s -u "$AUTH" -X POST "$ES/logs-aula5/_doc" \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"$msg\"}" >/dev/null
done < examples/logs-brutos.log

curl -s -u "$AUTH" -X POST "$ES/logs-aula5/_refresh" >/dev/null
TOTAL=$(curl -s -u "$AUTH" "$ES/logs-aula5/_count" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "Documentos indexados: $TOTAL"
echo ""
echo "Explore no Kibana > Discover (crie a data view logs-aula5) ou rode:"
echo "  ./scripts/validar-ambiente.sh"
