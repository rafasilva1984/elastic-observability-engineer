#!/usr/bin/env bash
# Remove containers E volumes (apaga TODOS os dados) e zera os tokens do .env.
cd "$(dirname "$0")/.." || exit 1
printf 'Isso apaga todos os dados do lab. Continuar? [s/N] '; read -r r
case "$r" in s|S|y|Y) ;; *) echo "Cancelado."; exit 0;; esac
docker compose --profile agente down -v
if [ -f .env ]; then
  sed -i.bak 's|^FLEET_SERVER_SERVICE_TOKEN=.*|FLEET_SERVER_SERVICE_TOKEN=|' .env
  sed -i.bak 's|^AGENT_ENROLLMENT_TOKEN=.*|AGENT_ENROLLMENT_TOKEN=|' .env
  rm -f .env.bak
fi
echo "Ambiente limpo. Para recriar do zero: ./scripts/subir.sh"
