#!/usr/bin/env bash
# Prepara o Fleet no Kibana 9.x e cria a policy do Fleet Server.
#
# POR QUE ESTE SCRIPT EXISTE: a partir do 9.x, passar FLEET_SERVER_POLICY_ID
# para o container NÃO cria a policy — o Fleet Server apenas assume que ela
# já existe e fica em "Waiting on policy" para sempre. Este script cria a
# policy explicitamente via API (determinístico, funciona em qualquer máquina)
# ANTES de o Fleet Server subir.
#
# Uso (o README chama isto no passo certo):
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

echo "==> Aguardando o Kibana ficar disponível..."
for i in $(seq 1 40); do
  if curl -s "${KB}/api/status" | grep -q '"level":"available"'; then
    echo "Kibana disponível."; break
  fi
  echo "   ...ainda subindo (tentativa ${i}/40)"; sleep 5
done

echo "==> Inicializando o Fleet (setup)"
curl -s -u "${AUTH}" -X POST "${KB}/api/fleet/setup" \
  -H "kbn-xsrf: true" -o /dev/null -w "   fleet/setup: HTTP %{http_code}\n"

echo "==> Verificando se a policy '${POLICY_ID}' já existe"
existe=$(curl -s -u "${AUTH}" "${KB}/api/fleet/agent_policies/${POLICY_ID}" \
  -H "kbn-xsrf: true" | grep -c "\"id\":\"${POLICY_ID}\"")

if [ "${existe}" -eq 0 ]; then
  echo "==> Criando a policy do Fleet Server (has_fleet_server=true)"
  curl -s -u "${AUTH}" -X POST "${KB}/api/fleet/agent_policies" \
    -H "kbn-xsrf: true" -H "Content-Type: application/json" \
    -d "{\"id\":\"${POLICY_ID}\",\"name\":\"Fleet Server Policy\",\"namespace\":\"default\",\"has_fleet_server\":true}" \
    -o /dev/null -w "   criar policy: HTTP %{http_code}\n"
else
  echo "   policy já existe — nada a fazer."
fi

echo ""
echo "Pronto. Agora suba o Fleet Server:"
echo "   docker compose up -d fleet-server"
echo "   docker compose logs -f fleet-server   # espere 'Fleet Server - Running' / HEALTHY"
