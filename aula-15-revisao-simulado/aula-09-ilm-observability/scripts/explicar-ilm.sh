#!/usr/bin/env bash
# O "observatório" do ciclo: mostra os backing indices, a fase de cada um
# e o detalhe do ILM Explain (API oficial de diagnóstico do ILM).
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Backing indices do data stream (gerações):"
curl -s -u "$AUTH" "$ES/_cat/indices/.ds-logs-onp.ilm-*?v&h=index,docs.count,pri.store.size&s=index"

echo ""
echo "==> Fase de cada backing index (ILM Explain, resumido):"
curl -s -u "$AUTH" "$ES/.ds-logs-onp.ilm-*/_ilm/explain?human" \
  | python3 -c "
import json,sys
d=json.load(sys.stdin)
for idx,info in sorted(d.get('indices',{}).items()):
    print(f\"  {idx}: fase={info.get('phase')} ação={info.get('action')} step={info.get('step')} idade={info.get('age')}\")"
echo ""
echo "Rode em loop para assistir ao ciclo:  watch -n 5 ./scripts/explicar-ilm.sh"
