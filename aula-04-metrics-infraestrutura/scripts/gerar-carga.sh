#!/usr/bin/env bash
# Gera carga de CPU DENTRO do "host" monitorado por 3 minutos, para o pico
# aparecer no Inventory/Hosts (system.cpu). Ctrl+C não é preciso: expira só.
set -euo pipefail
echo "Gerando carga de CPU em host-app-onp por 180s..."
docker exec -d host-app-onp sh -c 'end=$(( $(date +%s) + 180 )); while [ $(date +%s) -lt $end ]; do :; done' 
docker exec -d host-app-onp sh -c 'end=$(( $(date +%s) + 180 )); while [ $(date +%s) -lt $end ]; do :; done'
echo "2 loops de CPU rodando. Acompanhe em Infrastructure > Inventory (waffle esquentando)."
