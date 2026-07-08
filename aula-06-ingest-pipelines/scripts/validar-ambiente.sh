#!/usr/bin/env bash
# Validação - Aula 5 (Ingest Pipelines)
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. Saúde do cluster"
curl -s -u "$AUTH" "$ES/_cluster/health?pretty" | grep '"status"'
echo ""; echo "==> 3. Pipeline existe?"
curl -s -u "$AUTH" "$ES/_ingest/pipeline/onp-logs-app" | grep -q onp-logs-app && echo "onp-logs-app: OK" || echo "Pipeline ausente (rode ./scripts/criar-pipeline.sh)"
echo ""; echo "==> 4. Documentos estruturados (ERROR do serviço pagamento)"
curl -s -u "$AUTH" "$ES/logs-aula5/_search?q=log.level:ERROR%20AND%20service.name:pagamento&size=1&pretty" 2>/dev/null | head -40
echo ""; echo "==> 5. Documentos com falha de parsing (on_failure em ação)"
curl -s -u "$AUTH" "$ES/logs-aula5/_search?q=tags:falha_parsing&size=1&pretty" 2>/dev/null | grep -E '"message"|"error"|falha_parsing' | head -6
echo ""
echo "Correto: passo 4 mostra campos service.name/event.duration/client.geo;"
echo "passo 5 mostra a linha fora do padrão preservada com a tag falha_parsing."
