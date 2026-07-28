#!/usr/bin/env bash
# =============================================================================
#  subir.sh — sobe a plataforma inteira do curso, do zero, SEM passo manual.
# =============================================================================
#  Por que este script existe: no Elastic Stack 9.x, várias etapas que
#  pareciam automáticas precisam ser feitas explicitamente. Cada uma delas
#  já está resolvida aqui:
#
#   1. senha do kibana_system  -> definida via API (sem prompt interativo)
#   2. service token do Fleet  -> criado via API e gravado no .env
#   3. Fleet setup             -> POST /api/fleet/setup
#   4. policy do Fleet Server  -> sem ela o servidor fica em "Waiting on policy"
#   5. Fleet Server host       -> sem ele: "Missing URL for Fleet Server host"
#   6. output do Elasticsearch -> senão os agentes tentam localhost:9200 e
#                                 descartam os dados ("Drop batch")
#   7. integração APM          -> adicionada à policy do Fleet Server (8200)
#   8. policy + token do agente-> enrollment automático
#
#  Uso:  ./scripts/subir.sh
# =============================================================================
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# ----------------------------------------------------------------- helpers
azul()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[1;32mok\033[0m  %s\n' "$*"; }
erro()  { printf '  \033[1;31mERRO\033[0m %s\n' "$*"; }
passo() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }

# docker compose (v2) ou docker-compose (v1)
if docker compose version > /dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose > /dev/null 2>&1; then
  DC="docker-compose"
else
  erro "Docker Compose não encontrado. Instale o Docker Desktop / Docker Engine 24+."
  exit 1
fi

# .env
if [ ! -f .env ]; then
  cp .env.example .env
  ok ".env criado a partir do .env.example"
fi
set -a; . ./.env; set +a

ES="http://localhost:9200"
KB="http://localhost:5601"
AUTH="elastic:${ELASTIC_PASSWORD}"

# grava/atualiza uma chave no .env (delimitador | porque tokens têm /)
grava_env() {
  local chave="$1" valor="$2"
  if grep -q "^${chave}=" .env; then
    sed -i.bak "s|^${chave}=.*|${chave}=${valor}|" .env && rm -f .env.bak
  else
    echo "${chave}=${valor}" >> .env
  fi
}

# extrai o primeiro valor de uma chave JSON (sem depender de jq)
json_valor() {
  grep -o "\"$1\":\"[^\"]*\"" | head -1 | cut -d'"' -f4
}

espera() { # espera <descrição> <comando de teste> <tentativas>
  local desc="$1" cmd="$2" max="${3:-40}" i=1
  printf '  aguardando %s' "$desc"
  while [ "$i" -le "$max" ]; do
    if eval "$cmd" > /dev/null 2>&1; then printf ' pronto\n'; return 0; fi
    printf '.'; sleep 5; i=$((i+1))
  done
  printf '\n'; erro "tempo esgotado esperando $desc"; return 1
}

azul "================================================================"
azul "  Observabilidade na Prática — plataforma do curso (stack ${STACK_VERSION})"
azul "================================================================"

# ---------------------------------------------------------------- 1. base
passo "1/9  Subindo o Elasticsearch"
$DC up -d elasticsearch > /dev/null 2>&1
espera "o Elasticsearch ficar saudável" \
  "curl -s -u '$AUTH' $ES/_cluster/health | grep -q '\"status\":\"green\"\\|\"status\":\"yellow\"'" 40 || exit 1
ok "cluster no ar em $ES"

passo "2/9  Definindo a senha do usuário kibana_system (via API)"
resp=$(curl -s -u "$AUTH" -X POST "$ES/_security/user/kibana_system/_password" \
  -H 'Content-Type: application/json' \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}" -w '\n%{http_code}')
if [ "$(echo "$resp" | tail -1)" = "200" ]; then
  ok "senha do kibana_system definida"
else
  erro "falha ao definir a senha: $(echo "$resp" | head -1)"; exit 1
fi

passo "3/9  Subindo o Kibana"
$DC up -d kibana > /dev/null 2>&1
espera "o Kibana ficar disponível (pode levar 1-2 min)" \
  "curl -s $KB/api/status | grep -q '\"level\":\"available\"'" 60 || exit 1
ok "Kibana no ar em $KB"

# ------------------------------------------------------------- 2. fleet
passo "4/9  Preparando o Fleet (setup, policy, host e output)"

curl -s -u "$AUTH" -X POST "$KB/api/fleet/setup" -H "kbn-xsrf: true" > /dev/null
ok "fleet/setup executado"

# policy do Fleet Server (sem ela: "Waiting on policy" para sempre)
if curl -s -u "$AUTH" "$KB/api/fleet/agent_policies/fleet-server-policy" \
     -H "kbn-xsrf: true" | grep -q '"id":"fleet-server-policy"'; then
  ok "policy fleet-server-policy já existe"
else
  curl -s -u "$AUTH" -X POST "$KB/api/fleet/agent_policies" \
    -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
    -d '{"id":"fleet-server-policy","name":"Fleet Server Policy","namespace":"default","has_fleet_server":true,"monitoring_enabled":["logs","metrics"]}' > /dev/null
  ok "policy fleet-server-policy criada"
fi

# host do Fleet Server (sem ele: "Missing URL for Fleet Server host")
if curl -s -u "$AUTH" "$KB/api/fleet/fleet_server_hosts" -H "kbn-xsrf: true" \
     | grep -q "https://fleet-server:8220"; then
  ok "Fleet Server host já registrado"
else
  curl -s -u "$AUTH" -X POST "$KB/api/fleet/fleet_server_hosts" \
    -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
    -d '{"id":"fleet-server-onp","name":"Fleet Server ONP","host_urls":["https://fleet-server:8220"],"is_default":true}' > /dev/null
  ok "Fleet Server host registrado (https://fleet-server:8220)"
fi

# output do Elasticsearch (senão os agentes usam localhost:9200 e descartam dados)
curl -s -u "$AUTH" -X PUT "$KB/api/fleet/outputs/fleet-default-output" \
  -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
  -d '{"name":"default","type":"elasticsearch","hosts":["http://elasticsearch:9200"],"is_default":true,"is_default_monitoring":true}' > /dev/null
ok "output apontando para http://elasticsearch:9200"

passo "5/9  Criando o service token do Fleet Server"
if [ -z "${FLEET_SERVER_SERVICE_TOKEN:-}" ]; then
  # remove token antigo de mesmo nome (idempotência) e cria um novo
  curl -s -u "$AUTH" -X DELETE "$ES/_security/service/elastic/fleet-server/credential/token/token-onp" > /dev/null 2>&1
  TOKEN=$(curl -s -u "$AUTH" -X POST "$ES/_security/service/elastic/fleet-server/credential/token/token-onp" | json_valor value)
  if [ -z "$TOKEN" ]; then erro "não foi possível criar o service token"; exit 1; fi
  grava_env FLEET_SERVER_SERVICE_TOKEN "$TOKEN"
  export FLEET_SERVER_SERVICE_TOKEN="$TOKEN"
  ok "service token criado e gravado no .env"
else
  ok "service token já presente no .env"
fi

passo "6/9  Subindo o Fleet Server"
$DC up -d fleet-server > /dev/null 2>&1
espera "o Fleet Server registrar-se (HEALTHY)" \
  "curl -s -u '$AUTH' '$KB/api/fleet/agents?perPage=50' -H 'kbn-xsrf: true' | grep -q '\"status\":\"online\"'" 40 || {
    erro "o Fleet Server não ficou online. Veja: $DC logs fleet-server"; exit 1; }
ok "Fleet Server online"

passo "7/9  Adicionando a integração APM (porta 8200)"
if curl -s -u "$AUTH" "$KB/api/fleet/package_policies" -H "kbn-xsrf: true" | grep -q '"name":"apm-onp"'; then
  ok "integração APM já existe"
else
  curl -s -u "$AUTH" -X POST "$KB/api/fleet/package_policies" \
    -H "kbn-xsrf: true" -H 'Content-Type: application/json' -d "{
      \"name\":\"apm-onp\",\"namespace\":\"default\",\"policy_id\":\"fleet-server-policy\",
      \"package\":{\"name\":\"apm\",\"version\":\"\"},
      \"inputs\":[{\"type\":\"apm\",\"enabled\":true,\"streams\":[],\"vars\":{
        \"host\":{\"value\":\"0.0.0.0:8200\",\"type\":\"text\"},
        \"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\",\"type\":\"text\"}}}]}" > /dev/null
  ok "integração APM adicionada (0.0.0.0:8200 + secret token)"
fi

# ------------------------------------------------------- 3. agente + apps
passo "8/9  Criando a policy do host e enrolando o agente"
if ! curl -s -u "$AUTH" "$KB/api/fleet/agent_policies/onp-host-policy" \
       -H "kbn-xsrf: true" | grep -q '"id":"onp-host-policy"'; then
  curl -s -u "$AUTH" -X POST "$KB/api/fleet/agent_policies" \
    -H "kbn-xsrf: true" -H 'Content-Type: application/json' \
    -d '{"id":"onp-host-policy","name":"ONP - Host","namespace":"default","monitoring_enabled":["logs","metrics"]}' > /dev/null
  ok "policy ONP - Host criada (já nasce com a integração System)"
else
  ok "policy ONP - Host já existe"
fi
ENROLL=$(curl -s -u "$AUTH" "$KB/api/fleet/enrollment_api_keys?perPage=100" -H "kbn-xsrf: true" \
  | tr '}' '\n' | grep '"policy_id":"onp-host-policy"' | json_valor api_key)
if [ -n "$ENROLL" ]; then
  grava_env AGENT_ENROLLMENT_TOKEN "$ENROLL"
  export AGENT_ENROLLMENT_TOKEN="$ENROLL"
  ok "enrollment token do host obtido"
  $DC --profile agente up -d agente-host > /dev/null 2>&1
  ok "agente-host subindo (aparece em Fleet > Agents em ~1 min)"
else
  erro "não foi possível obter o enrollment token — suba o agente depois com:"
  echo "      $DC --profile agente up -d agente-host"
fi

passo "9/9  Subindo as aplicações de demonstração e os dados de exemplo"
$DC up -d loja-web pagamento loja-api gerador-logs gerador-trafego > /dev/null 2>&1
ok "loja-web (:8080), loja-api (:5000), pagamento, geradores de log e tráfego"
./scripts/carregar-dados.sh > /dev/null 2>&1 && ok "dados de exemplo indexados" \
  || erro "falha ao carregar dados — rode ./scripts/carregar-dados.sh manualmente"

azul ""
azul "================================================================"
azul "  Plataforma no ar!"
azul "================================================================"
printf '  Kibana         %s   (elastic / %s)\n' "$KB" "$ELASTIC_PASSWORD"
printf '  Elasticsearch  %s\n' "$ES"
printf '  Loja (web)     http://localhost:8080\n'
printf '  Loja (API)     http://localhost:5000\n'
echo
echo "  Confira tudo:   ./scripts/validar.sh"
echo "  Comece pela:    ../modulo-1-getting-started/licao-1.1-elastic-observability/"
echo
