#!/usr/bin/env bash
# Cria e VERIFICA o repositório de snapshots tipo fs (exige path.repo,
# já configurado no compose). Fonte: doc oficial de snapshot-and-restore.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)"
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"
curl -s -u "$AUTH" -X PUT "$ES/_snapshot/onp-repo" -H 'Content-Type: application/json' \
  -d '{ "type": "fs", "settings": { "location": "/snapshots" } }'
echo ""
curl -s -u "$AUTH" -X POST "$ES/_snapshot/onp-repo/_verify" | head -c 300
echo ""; echo "Repositório onp-repo criado e verificado."
