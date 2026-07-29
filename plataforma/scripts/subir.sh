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
#   6. output do Elasticsearch -> preconfigurado no kibana (compose); aqui só
#                                 CONFERIMOS, porque output preconfigurado não
#                                 aceita alteração via API (400 é o esperado)
#   7. integração APM          -> a versão do pacote PRECISA ser resolvida e
#                                 informada; com "version":"" o Fleet devolve
#                                 400 e a porta 8200 fica morta em silêncio
#   8. policy + token do agente-> enrollment automático
#
#  Regra deste script: nenhum passo que altera estado pode falhar em silêncio.
#  Toda chamada confere o HTTP e o resumo final lista o que não deu certo.
#
#  É idempotente: rodar de novo num ambiente já no ar é seguro.
#
#  Uso:  ./scripts/subir.sh
# =============================================================================
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# ----------------------------------------------------------------- helpers
azul()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[1;32mok\033[0m    %s\n' "$*"; }
aviso() { printf '  \033[1;33maviso\033[0m %s\n' "$*"; }
erro()  { printf '  \033[1;31mERRO\033[0m  %s\n' "$*"; FALHAS=$((FALHAS+1)); }
passo() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }

FALHAS=0

# docker compose (v2) ou docker-compose (v1)
if docker compose version > /dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose > /dev/null 2>&1; then
  DC="docker-compose"
else
  printf '  \033[1;31mERRO\033[0m  Docker Compose não encontrado. Instale o Docker Engine 24+.\n'
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

# req <METODO> <url> [json]  ->  imprime o HTTP code; corpo fica em $CORPO
CORPO=""
req() {
  local metodo="$1" url="$2" dados="${3:-}" tmp codigo
  tmp=$(mktemp)
  if [ -n "$dados" ]; then
    codigo=$(curl -s -u "$AUTH" -X "$metodo" "$url" \
      -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
      -d "$dados" -o "$tmp" -w '%{http_code}')
  else
    codigo=$(curl -s -u "$AUTH" -X "$metodo" "$url" \
      -H 'kbn-xsrf: true' -o "$tmp" -w '%{http_code}')
  fi
  CORPO=$(cat "$tmp"); rm -f "$tmp"
  echo "$codigo"
}

# porta_aberta <url>  -> 0 se algo respondeu HTTP (mesmo 401/403), 1 se não
porta_aberta() {
  local c
  c=$(curl -s -m 3 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && [ "$c" != "000" ]
}

espera() { # espera <descrição> <comando de teste> <tentativas>
  local desc="$1" cmd="$2" max="${3:-40}" i=1
  printf '  aguardando %s' "$desc"
  while [ "$i" -le "$max" ]; do
    if eval "$cmd" > /dev/null 2>&1; then printf ' pronto\n'; return 0; fi
    printf '.'; sleep 5; i=$((i+1))
  done
  printf '\n'; return 1
}

azul "================================================================"
azul "  Observabilidade na Prática — plataforma do curso (stack ${STACK_VERSION})"
azul "================================================================"

# ---------------------------------------------------------------- 1. base
passo "1/9  Subindo o Elasticsearch"
$DC up -d elasticsearch > /dev/null 2>&1
espera "o Elasticsearch ficar saudável" \
  "curl -s -u '$AUTH' $ES/_cluster/health | grep -q '\"status\":\"green\"\\|\"status\":\"yellow\"'" 40 \
  || { erro "Elasticsearch não subiu. Veja: $DC logs elasticsearch"; exit 1; }
ok "cluster no ar em $ES"

passo "2/9  Definindo a senha do usuário kibana_system (via API)"
codigo=$(req POST "$ES/_security/user/kibana_system/_password" \
  "{\"password\":\"${KIBANA_PASSWORD}\"}")
if [ "$codigo" = "200" ]; then
  ok "senha do kibana_system definida"
else
  erro "falha ao definir a senha (HTTP $codigo): $(echo "$CORPO" | head -c 200)"
  exit 1
fi

passo "3/9  Subindo o Kibana"
$DC up -d kibana > /dev/null 2>&1
espera "o Kibana ficar disponível (pode levar 1-2 min)" \
  "curl -s $KB/api/status | grep -q '\"level\":\"available\"'" 60 \
  || { erro "Kibana não ficou disponível. Veja: $DC logs kibana"; exit 1; }
ok "Kibana no ar em $KB"

# ------------------------------------------------------------- 2. fleet
passo "4/9  Preparando o Fleet (setup, policy, host e output)"

codigo=$(req POST "$KB/api/fleet/setup")
case "$codigo" in
  200) ok "fleet/setup executado" ;;
  *)   erro "fleet/setup retornou HTTP $codigo — o restante provavelmente vai falhar" ;;
esac

# policy do Fleet Server (sem ela: "Waiting on policy" para sempre)
codigo=$(req GET "$KB/api/fleet/agent_policies/fleet-server-policy")
if [ "$codigo" = "200" ]; then
  ok "policy fleet-server-policy já existe"
else
  codigo=$(req POST "$KB/api/fleet/agent_policies" \
    '{"id":"fleet-server-policy","name":"Fleet Server Policy","namespace":"default","has_fleet_server":true,"monitoring_enabled":["logs","metrics"]}')
  case "$codigo" in
    200|201) ok "policy fleet-server-policy criada" ;;
    409)     ok "policy fleet-server-policy já existia" ;;
    *)       erro "não criei a policy do Fleet Server (HTTP $codigo): $(echo "$CORPO" | head -c 200)" ;;
  esac
fi

# host do Fleet Server (sem ele: "Missing URL for Fleet Server host")
codigo=$(req GET "$KB/api/fleet/fleet_server_hosts")
if echo "$CORPO" | grep -q "https://fleet-server:8220"; then
  ok "Fleet Server host já registrado"
else
  codigo=$(req POST "$KB/api/fleet/fleet_server_hosts" \
    '{"id":"fleet-server-onp","name":"Fleet Server ONP","host_urls":["https://fleet-server:8220"],"is_default":true}')
  case "$codigo" in
    200|201) ok "Fleet Server host registrado (https://fleet-server:8220)" ;;
    409)     ok "Fleet Server host já existia" ;;
    *)       erro "não registrei o Fleet Server host (HTTP $codigo): $(echo "$CORPO" | head -c 200)" ;;
  esac
fi

# output do Elasticsearch.
# O compose já preconfigura isso no Kibana (XPACK_FLEET_AGENTS_ELASTICSEARCH_HOST).
# Output preconfigurado é IMUTÁVEL via API: um PUT devolve 400. Então aqui a
# gente só CONFERE — e só tenta corrigir se estiver errado e for editável.
codigo=$(req GET "$KB/api/fleet/outputs")
if echo "$CORPO" | grep -q '"hosts":\["http://elasticsearch:9200"\]'; then
  if echo "$CORPO" | grep -q '"is_preconfigured":true'; then
    ok "output aponta para http://elasticsearch:9200 (preconfigurado, imutável)"
  else
    ok "output aponta para http://elasticsearch:9200"
  fi
else
  aviso "output NÃO aponta para elasticsearch:9200 — tentando corrigir"
  codigo=$(req PUT "$KB/api/fleet/outputs/fleet-default-output" \
    '{"name":"default","type":"elasticsearch","hosts":["http://elasticsearch:9200"],"is_default":true,"is_default_monitoring":true}')
  if [ "$codigo" = "200" ]; then
    ok "output corrigido para http://elasticsearch:9200"
  else
    erro "output continua errado (HTTP $codigo). Os agentes vão descartar dados."
    echo "        corpo: $(echo "$CORPO" | head -c 250)"
  fi
fi

passo "5/9  Criando o service token do Fleet Server"
if [ -z "${FLEET_SERVER_SERVICE_TOKEN:-}" ]; then
  # remove token antigo de mesmo nome (idempotência) e cria um novo
  curl -s -u "$AUTH" -X DELETE \
    "$ES/_security/service/elastic/fleet-server/credential/token/token-onp" > /dev/null 2>&1
  TOKEN=$(curl -s -u "$AUTH" -X POST \
    "$ES/_security/service/elastic/fleet-server/credential/token/token-onp" | json_valor value)
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
  "curl -s -u '$AUTH' '$KB/api/fleet/agents?perPage=50' -H 'kbn-xsrf: true' | grep -q '\"status\":\"online\"'" 40 \
  || { erro "o Fleet Server não ficou online. Veja: $DC logs fleet-server"; exit 1; }
ok "Fleet Server online"
aviso "nos primeiros ~40s o log do fleet-server mostra erros de 'localhost:9200'."
echo "        É a janela de bootstrap: o agente sobe o monitoring antes de"
echo "        receber a policy. Some sozinho. Não é defeito."

# ------------------------------------------------------------------- APM
passo "7/9  Adicionando a integração APM (porta 8200)"

codigo=$(req GET "$KB/api/fleet/package_policies?perPage=200")
if echo "$CORPO" | grep -q '"name":"apm-onp"'; then
  ok "integração APM já existe na policy"
else
  # (a) descobre qual versão do pacote apm este stack oferece.
  #     ATENÇÃO: mandar "version":"" no package_policy devolve 400 e a porta
  #     8200 fica morta sem nenhum aviso. Foi exatamente esse o bug da v2.0.
  codigo=$(req GET "$KB/api/fleet/epm/packages/apm")
  APM_VER=$(echo "$CORPO" | grep -o '"latestVersion":"[^"]*"' | head -1 | cut -d'"' -f4)
  [ -z "$APM_VER" ] && APM_VER=$(echo "$CORPO" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)

  if [ -z "$APM_VER" ]; then
    erro "não descobri a versão do pacote apm (HTTP $codigo). APM não será instalado."
    echo "        corpo: $(echo "$CORPO" | head -c 250)"
  else
    ok "pacote apm disponível na versão ${APM_VER}"

    # (b) instala o pacote explicitamente
    codigo=$(req POST "$KB/api/fleet/epm/packages/apm/${APM_VER}" '{"force":true}')
    case "$codigo" in
      200|201) ok "pacote apm instalado" ;;
      409)     ok "pacote apm já estava instalado" ;;
      *)       aviso "instalação do pacote apm retornou HTTP $codigo (seguindo mesmo assim)" ;;
    esac

    # (c) cria a package policy COM a versão preenchida
    codigo=$(req POST "$KB/api/fleet/package_policies" "{
      \"name\":\"apm-onp\",
      \"namespace\":\"default\",
      \"policy_id\":\"fleet-server-policy\",
      \"package\":{\"name\":\"apm\",\"version\":\"${APM_VER}\"},
      \"inputs\":[{\"type\":\"apm\",\"enabled\":true,\"streams\":[],\"vars\":{
        \"host\":{\"value\":\"0.0.0.0:8200\",\"type\":\"text\"},
        \"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\",\"type\":\"text\"}}}]}")
    case "$codigo" in
      200|201) ok "integração APM adicionada (0.0.0.0:8200 + secret token)" ;;
      409)     ok "integração APM já existia" ;;
      *)       erro "APM NÃO foi adicionado (HTTP $codigo) — porta 8200 ficará morta"
               echo "        corpo: $(echo "$CORPO" | head -c 400)" ;;
    esac
  fi
fi

# (d) confirma de verdade: a porta 8200 tem de responder ALGO (200 ou 401).
#     'curl | grep -q .' não serve: com secret token o APM devolve corpo vazio.
espera "o APM Server abrir a porta 8200" "porta_aberta http://localhost:8200" 24 \
  && ok "APM Server respondendo em http://localhost:8200" \
  || erro "porta 8200 não respondeu. As lições 3.1/3.2/3.3 não vão funcionar."

# ------------------------------------------------------- 3. agente + apps
passo "8/9  Criando a policy do host e enrolando o agente"
codigo=$(req GET "$KB/api/fleet/agent_policies/onp-host-policy")
if [ "$codigo" != "200" ]; then
  codigo=$(req POST "$KB/api/fleet/agent_policies" \
    '{"id":"onp-host-policy","name":"ONP - Host","namespace":"default","monitoring_enabled":["logs","metrics"]}')
  case "$codigo" in
    200|201) ok "policy ONP - Host criada (já nasce com a integração System)" ;;
    409)     ok "policy ONP - Host já existia" ;;
    *)       erro "não criei a policy do host (HTTP $codigo): $(echo "$CORPO" | head -c 200)" ;;
  esac
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
  erro "não obtive o enrollment token — suba o agente depois com:"
  echo "        $DC --profile agente up -d agente-host"
fi

passo "9/9  Subindo as aplicações de demonstração e os dados de exemplo"
$DC up -d loja-web pagamento loja-api gerador-logs gerador-trafego > /dev/null 2>&1
ok "loja-web (:8080), loja-api (:5000), pagamento, geradores de log e tráfego"
if ./scripts/carregar-dados.sh > /dev/null 2>&1; then
  ok "dados de exemplo indexados"
else
  erro "falha ao carregar dados — rode ./scripts/carregar-dados.sh para ver o erro"
fi

# ------------------------------------------------------------------ fim
azul ""
azul "================================================================"
if [ "$FALHAS" -eq 0 ]; then
  azul "  Plataforma no ar!"
else
  azul "  Plataforma no ar — com ${FALHAS} problema(s) acima"
fi
azul "================================================================"
printf '  Kibana         %s   (elastic / %s)\n' "$KB" "$ELASTIC_PASSWORD"
printf '  Elasticsearch  %s\n' "$ES"
printf '  APM Server     http://localhost:8200\n'
printf '  Loja (web)     http://localhost:8080\n'
printf '  Loja (API)     http://localhost:5000\n'
echo
echo "  Confira tudo:   ./scripts/validar.sh"
echo "  Comece pela:    ../modulo-1-getting-started/licao-1.1-elastic-observability/"
echo
[ "$FALHAS" -eq 0 ] || exit 1
