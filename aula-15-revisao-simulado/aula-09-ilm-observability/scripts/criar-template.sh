#!/usr/bin/env bash
# Template do data stream (padrão do tutorial oficial):
#  - index_patterns casa com o nome do stream
#  - data_stream: {} declara que é data stream
#  - index.lifecycle.name aplica a política aos backing indices
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

curl -s -u "elastic:${ELASTIC_PASSWORD}" -X PUT \
  "http://localhost:9200/_index_template/onp-ilm-demo" \
  -H "Content-Type: application/json" -d '
{
  "index_patterns": ["logs-onp.ilm-*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "onp-ciclo-rapido",
      "number_of_replicas": 0
    }
  }
}' | grep -q '"acknowledged":true' && echo "Template onp-ilm-demo criado (streams logs-onp.ilm-*)." || echo "Falhou."
