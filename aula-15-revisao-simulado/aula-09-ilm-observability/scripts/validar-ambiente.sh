#!/usr/bin/env bash
# Validação - Aula 8 (ILM)
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. Saúde do cluster"
curl -s -u "$AUTH" "$ES/_cluster/health?pretty" | grep '"status"'
echo ""; echo "==> 3. Poll interval do ILM (lab: 10s)"
curl -s -u "$AUTH" "$ES/_cluster/settings?include_defaults=false&pretty" | grep -A2 lifecycle || echo "  (padrão 10m — rode ./scripts/acelerar-ilm.sh)"
echo ""; echo "==> 4. Política existe?"
curl -s -u "$AUTH" "$ES/_ilm/policy/onp-ciclo-rapido" | grep -q onp-ciclo-rapido && echo "onp-ciclo-rapido: OK" || echo "Ausente (./scripts/criar-politica.sh)"
echo ""; echo "==> 5. Template existe?"
curl -s -u "$AUTH" "$ES/_index_template/onp-ilm-demo" | grep -q onp-ilm-demo && echo "onp-ilm-demo: OK" || echo "Ausente (./scripts/criar-template.sh)"
echo ""; echo "==> 6. Data stream e gerações"
curl -s -u "$AUTH" "$ES/_data_stream/logs-onp.ilm-default?pretty" 2>/dev/null | grep -E '"name"|"generation"' || echo "Stream ainda não criado (rode ./scripts/gerar-dados.sh)"
echo ""
echo "Correto: gerações aumentando e, em ~2-4 min após cada rollover, os"
echo "índices antigos passando para warm e depois sendo deletados."
