#!/usr/bin/env bash
# Testa o pipeline com a Simulate API ANTES de indexar (prática oficial
# recomendada). Envia 1 documento válido e 1 fora do padrão para ver o
# grok funcionando e o on_failure em ação.
# Uso: ./scripts/simular-pipeline.sh

set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

curl -s -u "elastic:${ELASTIC_PASSWORD}" -X POST \
  "http://localhost:9200/_ingest/pipeline/onp-logs-app/_simulate?pretty" \
  -H "Content-Type: application/json" -d '
{
  "docs": [
    { "_source": { "message": "2026-07-03T11:00:05Z ERROR service=pagamento user=904 client_ip=189.45.201.10 duration_ms=2150 msg=\"falha ao processar pagamento\"" } },
    { "_source": { "message": "LINHA COMPLETAMENTE FORA DO PADRAO - sem estrutura nenhuma" } }
  ]
}'
echo ""
echo "Esperado: doc 1 com campos estruturados (service.name, event.duration"
echo "numérico, client.geo); doc 2 com tags=[falha_parsing] e error.message."
