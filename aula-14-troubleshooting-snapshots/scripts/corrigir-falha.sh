#!/usr/bin/env bash
# Volta o serviço pagamento ao token correto do .env.
set -euo pipefail
docker compose up -d --force-recreate pagamento
echo "Token corrigido. Em ~1 min o pagamento volta ao service map."
