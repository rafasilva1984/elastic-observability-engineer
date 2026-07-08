#!/usr/bin/env bash
# Validação - Aula 13 (Metrics)
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"
echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. Cluster"
curl -s -u "$AUTH" "$ES/_cluster/health?pretty" | grep '"status"'
echo ""; echo "==> 3. Data streams de métricas (a Infrastructure UI lê metrics-*)"
curl -s -u "$AUTH" "$ES/_cat/indices/.ds-metrics-system.*?h=index,docs.count" 2>/dev/null | head -8 || true
echo ""; echo "==> 4. Docs de CPU do host monitorado"
curl -s -u "$AUTH" "$ES/metrics-system.cpu-*/_count" 2>/dev/null | grep -o '"count":[0-9]*' || echo "Sem docs ainda (agente inscrito? token no .env?)"
echo ""
echo "Correto: data streams metrics-system.* crescendo e o host-app-onp"
echo "visível em Observability > Infrastructure > Inventory."
