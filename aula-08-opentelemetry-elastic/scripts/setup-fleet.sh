#!/usr/bin/env bash
# Prepara o Fleet no Kibana 9.x — as TRÊS coisas que o container não faz
# sozinho e sem as quais o Fleet Server nunca fica saudável:
#   1. inicializa o Fleet (setup)
#   2. cria a policy do Fleet Server (senão fica em "Waiting on policy")
#   3. registra o Fleet Server HOST (senão dá "Missing URL for Fleet Server
#      host" e nenhum enrollment token é gerado)
#
# A encryption key (4ª peça) fica no docker-compose.yml (serviço kibana).
# O FLEET_URL dos agentes usa https:// + FLEET_INSECURE=true (o Fleet Server
# fala TLS mesmo em lab; http:// puro dá "TLS handshake error").
#
# Uso (rode ANTES de subir o Fleet Server):
#   ./scripts/setup-fleet.sh
set -uo pipefail
if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado. Copie .env.example para .env."; exit 1
fi
KB="http://localhost:5601"
AUTH="elastic:${ELASTIC_PASSWORD}"
POLICY_ID="fleet-server-policy"
FS_HOST_URL="https://fleet-server:8220"

echo "==> Aguardando o Kibana ficar disponível..."
for i in $(seq 1 40); do
  if curl -s "${KB}/api/status" | grep -q '"level":"available"'; then
    echo "Kibana disponível."; break
  fi
  echo "   ...ainda subindo (tentativa ${i}/40)"; sleep 5
done

echo "==> [1/3] Inicializando o Fleet (setup)"
curl -s -u "${AUTH}" -X POST "${KB}/api/fleet/setup" \
  -H "kbn-xsrf: true" -o /dev/null -w "   fleet/setup: HTTP %{http_code}\n"

echo "==> [2/3] Policy do Fleet Server '${POLICY_ID}'"
existe=$(curl -s -u "${AUTH}" "${KB}/api/fleet/agent_policies/${POLICY_ID}" \
  -H "kbn-xsrf: true" | grep -c "\"id\":\"${POLICY_ID}\"")
if [ "${existe}" -eq 0 ]; then
  curl -s -u "${AUTH}" -X POST "${KB}/api/fleet/agent_policies" \
    -H "kbn-xsrf: true" -H "Content-Type: application/json" \
    -d "{\"id\":\"${POLICY_ID}\",\"name\":\"Fleet Server Policy\",\"namespace\":\"default\",\"has_fleet_server\":true}" \
    -o /dev/null -w "   criar policy: HTTP %{http_code}\n"
else
  echo "   policy já existe — ok."
fi

echo "==> [3/3] Registrando o Fleet Server host (${FS_HOST_URL})"
tem_host=$(curl -s -u "${AUTH}" "${KB}/api/fleet/fleet_server_hosts" \
  -H "kbn-xsrf: true" | grep -c "${FS_HOST_URL}")
if [ "${tem_host}" -eq 0 ]; then
  curl -s -u "${AUTH}" -X POST "${KB}/api/fleet/fleet_server_hosts" \
    -H "kbn-xsrf: true" -H "Content-Type: application/json" \
    -d "{\"id\":\"fleet-server-onp\",\"name\":\"Fleet Server ONP\",\"host_urls\":[\"${FS_HOST_URL}\"],\"is_default\":true}" \
    -o /dev/null -w "   registrar host: HTTP %{http_code}\n"
else
  echo "   host já registrado — ok."
fi

echo ""
echo "Pronto! Fleet configurado. Agora suba o Fleet Server:"
echo "   docker compose up -d fleet-server"
echo "   docker compose logs -f fleet-server   # espere 'HEALTHY'"
echo ""
echo "Depois, se a aula tiver agente(s) no compose (synthetics, host-app, etc.):"
echo "   docker compose up -d   # sobe todo o resto"
