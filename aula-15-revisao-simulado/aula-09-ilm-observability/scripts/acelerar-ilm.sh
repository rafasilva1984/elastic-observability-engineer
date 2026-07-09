#!/usr/bin/env bash
# Reduz o intervalo de verificação do ILM para 10s — SOMENTE PARA LAB.
# Ponto de prova (doc oficial): o padrão de indices.lifecycle.poll_interval
# é 10 MINUTOS; por isso, em produção, uma transição pode demorar mais que
# o esperado mesmo com as condições atingidas.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

curl -s -u "elastic:${ELASTIC_PASSWORD}" -X PUT \
  "http://localhost:9200/_cluster/settings" \
  -H "Content-Type: application/json" -d '
{ "persistent": { "indices.lifecycle.poll_interval": "10s" } }' \
  | grep -q '"acknowledged":true' && echo "ILM verificando a cada 10s (padrão: 10min — ajuste de LAB)." || echo "Falhou."
