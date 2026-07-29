#!/usr/bin/env bash
# Coleta tudo que importa sobre o APM nesta plataforma.
# Se o subir.sh falhar no passo 7, rode isto e mande a saída inteira.
#
# Uso:  ./scripts/diagnostico-apm.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
KB="http://localhost:5601"; AUTH="elastic:${ELASTIC_PASSWORD}"

titulo() { printf '\n\033[1;36m===== %s =====\033[0m\n' "$*"; }

titulo "1. versão do stack"
echo "STACK_VERSION do .env: ${STACK_VERSION}"
curl -s -u "$AUTH" http://localhost:9200 | grep -o '"number":"[^"]*"'

titulo "2. pacote apm — resposta CRUA de /api/fleet/epm/packages/apm"
echo "-- HTTP code:"
curl -s -u "$AUTH" "$KB/api/fleet/epm/packages/apm" -H 'kbn-xsrf: true' \
  -o /dev/null -w '%{http_code}\n'
echo "-- primeiros 1500 caracteres do corpo:"
curl -s -u "$AUTH" "$KB/api/fleet/epm/packages/apm" -H 'kbn-xsrf: true' | head -c 1500
echo
echo "-- todas as ocorrências de version/latestVersion:"
curl -s -u "$AUTH" "$KB/api/fleet/epm/packages/apm" -H 'kbn-xsrf: true' \
  | grep -o '"\(latestVersion\|version\)":"[^"]*"' | sort -u

titulo "3. pacote apm na LISTA de pacotes"
curl -s -u "$AUTH" "$KB/api/fleet/epm/packages?perPage=500" -H 'kbn-xsrf: true' \
  | tr '{' '\n' | grep '"name":"apm"' | head -3

titulo "4. package policies existentes"
curl -s -u "$AUTH" "$KB/api/fleet/package_policies?perPage=200" -H 'kbn-xsrf: true' \
  | grep -o '"name":"[^"]*"' | sort -u

titulo "5. agent policies"
curl -s -u "$AUTH" "$KB/api/fleet/agent_policies?perPage=50" -H 'kbn-xsrf: true' \
  | grep -o '"id":"[^"]*"' | sort -u

titulo "6. outputs"
curl -s -u "$AUTH" "$KB/api/fleet/outputs" -H 'kbn-xsrf: true'
echo

titulo "7. porta 8200 (código HTTP; 000 = fechada)"
curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://localhost:8200

titulo "8. componentes carregados pelo Fleet Server (procure 'apm')"
docker compose logs --tail 400 fleet-server 2>/dev/null \
  | grep -o '"component_ids":"[^"]*"' | tail -3
docker compose logs --tail 400 fleet-server 2>/dev/null \
  | grep -i 'apm' | tail -10

titulo "9. últimos erros do fleet-server"
docker compose logs --since 5m fleet-server 2>/dev/null \
  | grep '"log.level":"error"' | tail -10

echo
echo "Fim do diagnóstico. Copie TUDO acima."
