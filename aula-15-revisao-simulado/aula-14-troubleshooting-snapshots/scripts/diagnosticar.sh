#!/usr/bin/env bash
# O checklist oficial de "no data" do APM, automatizado na ordem certa
# (de fora para dentro). Fonte: Common problems with APM (doc oficial).
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> 1. O APM Server está de pé? (curl :8200)"
curl -s -m 5 http://localhost:8200 | head -3 || echo "   MUDO: integração APM ausente/parada na policy do Fleet Server"
echo ""
echo "==> 2. O agente do serviço está conseguindo entregar? (logs do pagamento)"
docker logs pagamento-onp 2>&1 | grep -iE "apm|401|403|secret|unauthorized" | tail -5 || echo "   (sem erros de APM no log)"
echo ""
echo "==> 3. O APM Server está recebendo/reclamando? (logs do fleet-server)"
docker compose logs fleet-server 2>&1 | grep -iE "apm-server.*(request|error|auth)" | tail -5 || echo "   (nada relevante)"
echo ""
echo "==> 4. Está chegando dado NOVO? (docs de traces nos últimos 5 min)"
curl -s -u "$AUTH" "$ES/traces-apm*/_count" -H 'Content-Type: application/json' \
  -d '{"query":{"range":{"@timestamp":{"gte":"now-5m"}}}}' | grep -o '"count":[0-9]*'
echo ""
echo "Leitura: 401 no passo 2 + contagem parada no passo 4 = secret token."
