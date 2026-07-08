#!/usr/bin/env bash
# Reseta os artefatos criados pelas tarefas do simulado, para repetir a
# rodada do zero. Objetos criados via UI (dashboards, policies do Fleet,
# regras de alerta) devem ser removidos pela própria UI ou por
# Stack Management > Saved Objects.
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }
ES="http://localhost:9200"; AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Removendo artefatos das tarefas (ignora o que não existir)"
curl -s -u "$AUTH" -X DELETE "$ES/logs-simulado" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_ingest/pipeline/simulado-logs-app" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_data_stream/logs-simulado.ilm-default" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_index_template/simulado-ilm" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_ilm/policy/simulado-ciclo" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/logs-montado" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_snapshot/sim-repo/sim-snap" > /dev/null
curl -s -u "$AUTH" -X DELETE "$ES/_snapshot/sim-repo" > /dev/null
curl -s -u "$AUTH" -X PUT "$ES/_cluster/settings" -H "Content-Type: application/json" \
  -d '{ "persistent": { "indices.lifecycle.poll_interval": null } }' > /dev/null
echo "Reset concluído (T12 incluída: montado+snapshot+repo). Dashboards/policies/regras/jobs de ML: remover via UI."
echo "Sample data permanece (reinstale com ./scripts/preparar-arena.sh se quiser)."
