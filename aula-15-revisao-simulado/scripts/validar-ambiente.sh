#!/usr/bin/env bash
# Validação da arena - Vídeo 12
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. Cluster"
curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health?pretty | grep '"status"'
echo ""; echo "==> 3. Kibana"
curl -s -o /dev/null -w "Kibana: HTTP %{http_code}\n" http://localhost:5601/api/status
echo ""; echo "==> 4. Fleet Server"
curl -s -o /dev/null -w "Fleet (8220): HTTP %{http_code}\n" -k https://localhost:8220/api/status
echo ""; echo "==> 5. APM Server (só após a Tarefa 7 do simulado)"
curl -s http://localhost:8200 | head -3 || echo "8200 mudo = Tarefa 7 pendente (esperado antes dela)"
echo ""; echo "==> 6. Sample data"
curl -s -u "elastic:${ELASTIC_PASSWORD}" "http://localhost:9200/_cat/indices/kibana_sample*?h=index,docs.count" || echo "Rode ./scripts/preparar-arena.sh"
