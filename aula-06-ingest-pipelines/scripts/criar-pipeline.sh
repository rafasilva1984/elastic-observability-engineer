#!/usr/bin/env bash
# Cria o ingest pipeline "onp-logs-app" via API.
# Processors, na ordem: grok -> convert -> date -> geoip -> remove
# Falhas de parsing são tratadas no on_failure (parsing resiliente).
#
# Fonte oficial da sintaxe:
# https://www.elastic.co/docs/reference/enrich-processor/grok-processor
#
# Uso: ./scripts/criar-pipeline.sh

set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

curl -s -u "elastic:${ELASTIC_PASSWORD}" -X PUT \
  "http://localhost:9200/_ingest/pipeline/onp-logs-app" \
  -H "Content-Type: application/json" -d '
{
  "description": "Estrutura os logs da app de exemplo (Aula 5 - Observabilidade na Prática)",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": [
          "%{TIMESTAMP_ISO8601:log_tempo} %{LOGLEVEL:log.level} service=%{WORD:service.name} user=%{NUMBER:user.id} client_ip=%{IP:client.ip} duration_ms=%{NUMBER:event.duration} msg=\"%{GREEDYDATA:log.mensagem}\""
        ]
      }
    },
    {
      "convert": {
        "field": "event.duration",
        "type": "long"
      }
    },
    {
      "date": {
        "field": "log_tempo",
        "formats": ["ISO8601"],
        "target_field": "@timestamp"
      }
    },
    {
      "geoip": {
        "field": "client.ip",
        "target_field": "client.geo",
        "ignore_missing": true
      }
    },
    {
      "remove": {
        "field": "log_tempo",
        "ignore_missing": true
      }
    }
  ],
  "on_failure": [
    {
      "append": {
        "field": "tags",
        "value": ["falha_parsing"]
      }
    },
    {
      "set": {
        "field": "error.message",
        "value": "{{ _ingest.on_failure_message }}"
      }
    }
  ]
}' | grep -q '"acknowledged":true' && echo "Pipeline onp-logs-app criado com sucesso." || echo "Falha ao criar o pipeline."
