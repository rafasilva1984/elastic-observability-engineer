#!/usr/bin/env bash
# Para os containers, PRESERVANDO os dados (volumes).
cd "$(dirname "$0")/.." || exit 1
docker compose --profile agente stop
echo "Parado. Para voltar: ./scripts/subir.sh"
