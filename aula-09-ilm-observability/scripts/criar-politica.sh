#!/usr/bin/env bash
# Cria a política "onp-ciclo-rapido":
#  hot   -> rollover com max_docs: 50 (agressivo, para VER o ciclo)
#  warm  -> 2min após o rollover: readonly + forcemerge (1 segmento)
#  delete-> 4min após o rollover: apagar
# Ponto de prova (doc oficial): min_age das fases seguintes conta a partir
# do ROLLOVER, não da criação do índice.
set -euo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

curl -s -u "elastic:${ELASTIC_PASSWORD}" -X PUT \
  "http://localhost:9200/_ilm/policy/onp-ciclo-rapido" \
  -H "Content-Type: application/json" -d '
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": { "max_docs": 50 },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "2m",
        "actions": {
          "readonly": {},
          "forcemerge": { "max_num_segments": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "delete": {
        "min_age": "4m",
        "actions": { "delete": {} }
      }
    }
  }
}' | grep -q '"acknowledged":true' && echo "Política onp-ciclo-rapido criada." || echo "Falhou."
