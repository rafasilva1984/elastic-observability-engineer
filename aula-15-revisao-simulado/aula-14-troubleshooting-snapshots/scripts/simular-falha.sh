#!/usr/bin/env bash
# Recria o serviço pagamento com o secret token ERRADO (override).
# Efeito esperado: o serviço continua funcionando... mas SOME do APM.
set -euo pipefail
docker compose -f docker-compose.yml -f docker-compose.quebra.yml up -d --force-recreate pagamento
echo "Falha injetada: pagamento está com token errado."
echo "Aguarde ~1 min e observe o service map: o pagamento desaparece."
