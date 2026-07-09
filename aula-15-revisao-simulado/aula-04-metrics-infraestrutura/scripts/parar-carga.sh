#!/usr/bin/env bash
# Encerra os loops de carga antes do tempo, se quiser.
docker exec host-app-onp sh -c "pkill -f 'date +%s' || true"
echo "Carga encerrada."
