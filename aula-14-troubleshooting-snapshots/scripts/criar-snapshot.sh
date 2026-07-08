#!/usr/bin/env bash
# Cria um índice de "auditoria" com dados, tira o snapshot dele e APAGA o
# índice — deixando o dado existindo SÓ no repositório (cenário real de
# retenção fria). Boas práticas oficiais: force-merge antes do snapshot.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)"
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Índice auditoria-2025 com 5 eventos"
for i in 1 2 3 4 5; do
  curl -s -u "$AUTH" -X POST "$ES/auditoria-2025/_doc" -H 'Content-Type: application/json' \
    -d "{\"@timestamp\":\"2025-0$i-15T10:00:00Z\",\"evento\":\"acesso_admin_$i\",\"usuario\":\"ops$i\"}" > /dev/null
done
curl -s -u "$AUTH" -X POST "$ES/auditoria-2025/_refresh" > /dev/null

echo "==> Force-merge para 1 segmento (recomendação oficial p/ searchable snapshots)"
curl -s -u "$AUTH" -X POST "$ES/auditoria-2025/_forcemerge?max_num_segments=1" > /dev/null

echo "==> Snapshot snap-auditoria"
curl -s -u "$AUTH" -X PUT "$ES/_snapshot/onp-repo/snap-auditoria?wait_for_completion=true" \
  -H 'Content-Type: application/json' -d '{ "indices": "auditoria-2025" }' | grep -o '"state":"[A-Z]*"'

echo "==> Apagando o índice original (o dado agora vive SÓ no repositório)"
curl -s -u "$AUTH" -X DELETE "$ES/auditoria-2025" > /dev/null
echo "Pronto: dado frio no repositório, cluster limpo."
