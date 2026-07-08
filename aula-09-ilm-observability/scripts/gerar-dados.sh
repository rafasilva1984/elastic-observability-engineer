#!/usr/bin/env bash
# Indexa documentos continuamente no data stream logs-onp.ilm-default.
# Com max_docs: 50 na política, cada ~50 docs dispara um rollover.
# O data stream é criado automaticamente no primeiro documento (o template
# casa com o nome). Ctrl+C para parar.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"
DS="logs-onp.ilm-default"

echo "Indexando em ${DS} (Ctrl+C para parar)..."
i=0
while true; do
  TS=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  curl -s -u "$AUTH" -X POST "$ES/$DS/_doc" \
    -H "Content-Type: application/json" \
    -d "{\"@timestamp\": \"$TS\", \"message\": \"evento $i\", \"service.name\": \"gerador-ilm\"}" > /dev/null
  i=$((i+1))
  [ $((i % 25)) -eq 0 ] && echo "  $i documentos enviados..."
  sleep 0.2
done
