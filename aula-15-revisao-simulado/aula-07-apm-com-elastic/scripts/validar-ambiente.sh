#!/usr/bin/env bash
# Validação - Aula 6 (APM com Elastic)
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. Saúde do cluster"
curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health?pretty | grep '"status"'
echo ""; echo "==> 3. APM Server respondendo (via integração no Elastic Agent)"
curl -s http://localhost:8200 | head -5 || echo "APM Server ainda não ativo (integração adicionada no Kibana? passo 7)"
echo ""; echo "==> 4. Aplicação respondendo"
curl -s -o /dev/null -w "loja-api /health: %{http_code}\n" http://localhost:5000/health
echo ""; echo "==> 5. Data streams de APM recebendo"
curl -s -u "elastic:${ELASTIC_PASSWORD}" "http://localhost:9200/_cat/indices/*apm*?v&h=index,docs.count" | head -8 || echo "Sem dados APM ainda."
echo ""
echo "Com tudo OK: Kibana > Observability > APM lista loja-api e pagamento,"
echo "com o service map ligando os dois."
