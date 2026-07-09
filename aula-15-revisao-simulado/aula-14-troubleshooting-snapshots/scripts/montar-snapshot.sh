#!/usr/bin/env bash
# Monta o índice DIRETO do snapshot (searchable snapshot) e pesquisa nele.
# storage=full_copy (fully mounted) — funciona em qualquer node; o modo
# shared_cache (partially mounted) é o do tier frozen. Fonte: doc oficial.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)"
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Montando auditoria-2025 como auditoria-2025-montado (full_copy)"
curl -s -u "$AUTH" -X POST \
  "$ES/_snapshot/onp-repo/snap-auditoria/_mount?wait_for_completion=true&storage=full_copy" \
  -H 'Content-Type: application/json' \
  -d '{ "index": "auditoria-2025", "renamed_index": "auditoria-2025-montado" }' | head -c 200
echo ""
echo "==> Pesquisando no índice MONTADO (o dado nunca voltou 'inteiro' pro cluster)"
curl -s -u "$AUTH" "$ES/auditoria-2025-montado/_count" | grep -o '"count":[0-9]*'
curl -s -u "$AUTH" "$ES/auditoria-2025-montado/_search?q=usuario:ops3&size=1" | grep -o '"evento":"[a-z_0-9]*"'
echo ""; echo "Snapshot pesquisável: retenção fria SEM perder a busca."
