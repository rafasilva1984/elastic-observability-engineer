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
#   6. output do Elasticsearch -> preconfigurado no Kibana (compose); aqui a
#                                 gente CONFERE e só corrige se estiver errado
#   7. integração APM          -> a versão do pacote PRECISA ser resolvida e
#                                 informada; com "version":"" o Fleet devolve
#                                 400 e a porta 8200 fica muda em silêncio
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

# ---------------------------------------------------------------------------
#  req <METODO> <url> [json]   ->  preenche as globais $HTTP e $CORPO
#
#  DUAS armadilhas já evitadas aqui:
#
#  1. NÃO chame dentro de $( ). Command substitution roda em subshell e as
#     globais setadas lá dentro morrem com ele — o shell pai recebe vazio.
#
#  2. NÃO use arquivo temporário (curl -o "$tmp" + cat "$tmp"). No Git Bash
#     com MSYS_NO_PATHCONV=1 — ou quando o curl do PATH é o nativo do Windows
#     — o caminho /tmp/... não é convertido: o curl grava em C:\tmp\... e o
#     cat lê outro lugar. Resultado: HTTP 200 com corpo vazio.
#
#  Solução: o %{http_code} vem colado no fim do corpo, na última linha.
#  Sem arquivo intermediário, sem conversão de caminho, sem subshell perdido.
# ---------------------------------------------------------------------------
HTTP=""
CORPO=""
req() {
  local metodo="$1" url="$2" dados="${3:-}" saida
  if [ -n "$dados" ]; then
    saida=$(curl -s -u "$AUTH" -X "$metodo" "$url" -H 'kbn-xsrf: true' \
      -H 'Content-Type: application/json' -d "$dados" -w $'\n%{http_code}')
  else
    saida=$(curl -s -u "$AUTH" -X "$metodo" "$url" -H 'kbn-xsrf: true' \
      -w $'\n%{http_code}')
  fi
  HTTP=$(printf '%s' "$saida" | tail -n 1)
  CORPO=$(printf '%s' "$saida" | sed '$d')
}

# porta_aberta <url> -> 0 se algo respondeu HTTP (mesmo 401/403), 1 se não
porta_aberta() {
  local c
  c=$(curl -s -m 3 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && [ "$c" != "000" ]
}

# extrai o primeiro objeto "vars":{...} de um JSON, com chaves balanceadas
extrai_vars() {
  awk '{ s = s $0 }
  END {
    p = index(s, "\"vars\":{")
    if (p == 0) { exit 1 }
    start = p + 7
    depth = 0
    for (i = start; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (c == "{") depth++
      else if (c == "}") { depth--; if (depth == 0) { print substr(s, start, i - start + 1); exit 0 } }
    }
    exit 1
  }'
}

# remove package policies cujo nome comece com o prefixo dado; imprime quantas
remove_pp() {
  local prefixo="$1" ids i n=0
  req GET "$KB/api/fleet/package_policies?perPage=200"
  ids=$(printf '%s' "$CORPO" | tr '{' '\n' | grep "\"name\":\"${prefixo}" \
        | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
  for i in $ids; do req DELETE "$KB/api/fleet/package_policies/$i"; n=$((n+1)); done
  echo "$n"
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
req POST "$ES/_security/user/kibana_system/_password" "{\"password\":\"${KIBANA_PASSWORD}\"}"
if [ "$HTTP" = "200" ]; then
  ok "senha do kibana_system definida"
else
  erro "falha ao definir a senha (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 200)"
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

req POST "$KB/api/fleet/setup"
case "$HTTP" in
  200) ok "fleet/setup executado" ;;
  *)   erro "fleet/setup retornou HTTP $HTTP — o restante provavelmente vai falhar" ;;
esac

# policy do Fleet Server (sem ela: "Waiting on policy" para sempre)
req GET "$KB/api/fleet/agent_policies/fleet-server-policy"
if [ "$HTTP" = "200" ]; then
  ok "policy fleet-server-policy já existe"
else
  req POST "$KB/api/fleet/agent_policies" \
    '{"id":"fleet-server-policy","name":"Fleet Server Policy","namespace":"default","has_fleet_server":true,"monitoring_enabled":["logs","metrics"]}'
  case "$HTTP" in
    200|201) ok "policy fleet-server-policy criada" ;;
    409)     ok "policy fleet-server-policy já existia" ;;
    *)       erro "não criei a policy do Fleet Server (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 200)" ;;
  esac
fi

# host do Fleet Server (sem ele: "Missing URL for Fleet Server host")
req GET "$KB/api/fleet/fleet_server_hosts"
if printf '%s' "$CORPO" | grep -q 'fleet-server:8220'; then
  ok "Fleet Server host já registrado"
else
  req POST "$KB/api/fleet/fleet_server_hosts" \
    '{"id":"fleet-server-onp","name":"Fleet Server ONP","host_urls":["https://fleet-server:8220"],"is_default":true}'
  case "$HTTP" in
    200|201) ok "Fleet Server host registrado (https://fleet-server:8220)" ;;
    409)     ok "Fleet Server host já existia" ;;
    *)       erro "não registrei o Fleet Server host (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 200)" ;;
  esac
fi

# output do Elasticsearch.
# O compose preconfigura isso no Kibana (XPACK_FLEET_AGENTS_ELASTICSEARCH_HOST),
# então na prática ele já nasce certo. Aqui a gente só CONFERE, e só tenta
# corrigir se de fato estiver errado.
req GET "$KB/api/fleet/outputs"
if printf '%s' "$CORPO" | grep -q 'elasticsearch:9200'; then
  if printf '%s' "$CORPO" | grep -q '"is_preconfigured":true'; then
    ok "output aponta para http://elasticsearch:9200 (preconfigurado)"
  else
    ok "output aponta para http://elasticsearch:9200"
  fi
else
  aviso "output NÃO aponta para elasticsearch:9200 — tentando corrigir"
  req PUT "$KB/api/fleet/outputs/fleet-default-output" \
    '{"name":"default","type":"elasticsearch","hosts":["http://elasticsearch:9200"],"is_default":true,"is_default_monitoring":true}'
  if [ "$HTTP" = "200" ]; then
    ok "output corrigido para http://elasticsearch:9200"
  else
    erro "output continua errado (HTTP $HTTP). Os agentes vão descartar dados."
    echo "        corpo: $(printf '%s' "$CORPO" | head -c 250)"
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

# ---------------------------------------------------------------------------
#  POR QUE ESTE PASSO É TÃO ELABORADO
#
#  Quando você manda `vars` explicitamente, o Fleet usa SÓ aquelas e NÃO
#  preenche os padrões do pacote. Cada bloco opcional do apm-server que ficar
#  sem sua flag renderiza com nulos e o APM Server recusa a config inteira:
#
#     faltou tls_enabled           -> "certificate file not configured
#                                      accessing 'apm-server.ssl'"
#     faltou tail_sampling_enabled -> "no policies specified accessing
#                                      'apm-server.sampling.tail'"
#
#  O pacote tem dezenas de vars. Em vez de listá-las (e quebrar a cada versão
#  nova da Elastic), perguntamos ao próprio Fleet quais são: criamos uma
#  package policy descartável SEM `inputs` numa agent policy temporária sem
#  agentes, lemos o conjunto completo de padrões, e trocamos só `host` e
#  `secret_token`.
#
#  `host` tem de ser 0.0.0.0:8200 — o padrão localhost:8200 prende o processo
#  no loopback do container, inalcançável pelo Docker e pelos outros serviços.
# ---------------------------------------------------------------------------
POLICY_TMP="onp-apm-template-tmp"

req GET "$KB/api/fleet/package_policies?perPage=200"
if printf '%s' "$CORPO" | grep -q '"name":"apm-onp"'; then
  ok "integração APM já existe na policy"
else
  # (a) versão do pacote
  req GET "$KB/api/fleet/epm/packages/apm"
  APM_VER=$(printf '%s' "$CORPO" | grep -o '"latestVersion":[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
  [ -z "$APM_VER" ] && APM_VER=$(printf '%s' "$CORPO" | grep -o '"version":[[:space:]]*"[0-9][^"]*"' | head -1 | cut -d'"' -f4)
  if [ -z "$APM_VER" ]; then
    erro "não descobri a versão do pacote apm (HTTP $HTTP)"
    echo "        corpo: $(printf '%s' "$CORPO" | head -c 250)"
  else
    ok "pacote apm versão ${APM_VER}"
    req POST "$KB/api/fleet/epm/packages/apm/${APM_VER}" '{"force":true}'
    case "$HTTP" in
      200|201|409) ok "pacote instalado" ;;
      *)           aviso "instalação retornou HTTP $HTTP (seguindo)" ;;
    esac

    # (b) lê os padrões numa policy temporária sem agentes
    remove_pp "apm-tmp" > /dev/null
    req POST "$KB/api/fleet/agent_policies/delete" "{\"agentPolicyId\":\"${POLICY_TMP}\"}"
    req POST "$KB/api/fleet/agent_policies" \
      "{\"id\":\"${POLICY_TMP}\",\"name\":\"ONP APM template (temporária)\",\"namespace\":\"default\"}"
    req POST "$KB/api/fleet/package_policies" \
      "{\"name\":\"apm-tmp\",\"namespace\":\"default\",\"policy_id\":\"${POLICY_TMP}\",
        \"package\":{\"name\":\"apm\",\"version\":\"${APM_VER}\"}}"

    APM_VARS=""
    if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
      APM_VARS=$(printf '%s' "$CORPO" | extrai_vars)
    fi
    remove_pp "apm-tmp" > /dev/null
    req POST "$KB/api/fleet/agent_policies/delete" "{\"agentPolicyId\":\"${POLICY_TMP}\"}"

    if [ -z "$APM_VARS" ] || ! printf '%s' "$APM_VARS" | grep -q '"host"'; then
      erro "não consegui ler os padrões do pacote apm — pulando a integração"
      echo "        rode depois: ./scripts/corrigir-apm.sh"
    else
      QTD=$(printf '%s' "$APM_VARS" | grep -o '"[a-z_]*":{' | wc -l | tr -d ' ')
      ok "${QTD} variáveis lidas com os padrões do pacote"

      # (c) sobrescreve só o que precisa
      APM_VARS=$(printf '%s' "$APM_VARS" | sed 's|"host":{"value":"[^"]*"|"host":{"value":"0.0.0.0:8200"|')
      if printf '%s' "$APM_VARS" | grep -q '"secret_token":{"value"'; then
        APM_VARS=$(printf '%s' "$APM_VARS" | sed "s|\"secret_token\":{\"value\":\"[^\"]*\"|\"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\"|")
      else
        APM_VARS=$(printf '%s' "$APM_VARS" | sed "s|\"secret_token\":{|\"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\",|")
      fi
      printf '%s' "$APM_VARS" | grep -q '0\.0\.0\.0:8200' \
        && ok "host = 0.0.0.0:8200" || aviso "não confirmei a troca do host"

      # (d) cria a integração real
      req POST "$KB/api/fleet/package_policies" \
        "{\"name\":\"apm-onp\",\"namespace\":\"default\",\"policy_id\":\"fleet-server-policy\",
          \"package\":{\"name\":\"apm\",\"version\":\"${APM_VER}\"},
          \"inputs\":[{\"type\":\"apm\",\"policy_template\":\"apmserver\",\"enabled\":true,
            \"streams\":[],\"vars\":${APM_VARS}}]}"
      case "$HTTP" in
        200|201) ok "integração APM criada" ;;
        409)     ok "integração APM já existia" ;;
        *)       erro "APM não foi adicionado (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 400)" ;;
      esac
    fi
  fi
fi

# (e) confirma de verdade. 'curl | grep -q .' não serve: com secret token o
#     APM devolve corpo vazio. O que vale é o código HTTP (401 ou 200).
if espera "o APM Server abrir a porta 8200" "porta_aberta http://localhost:8200" 36; then
  ok "APM Server respondendo em http://localhost:8200"
else
  erro "porta 8200 não respondeu. Lições 3.1/3.2/3.3 não vão funcionar."
  echo "        diagnóstico: ./scripts/corrigir-apm.sh"
fi

passo "8/9  Criando a policy do host e enrolando o agente"

# ARMADILHA: POST /api/fleet/agent_policies cria a policy VAZIA. As
# integrações System e Elastic Agent só entram com ?sys_monitoring=true.
# Sem elas o agente enrola, fica Healthy e não coleta nada — metrics-system*
# nunca aparece e a lição 2.3 não tem dado.
req GET "$KB/api/fleet/agent_policies/onp-host-policy"
if [ "$HTTP" != "200" ]; then
  req POST "$KB/api/fleet/agent_policies?sys_monitoring=true" \
    '{"id":"onp-host-policy","name":"ONP - Host","namespace":"default","monitoring_enabled":["logs","metrics"]}'
  case "$HTTP" in
    200|201) ok "policy ONP - Host criada com System + Elastic Agent" ;;
    409)     ok "policy ONP - Host já existia" ;;
    *)       erro "não criei a policy do host (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 250)" ;;
  esac
else
  ok "policy ONP - Host já existe"
fi

# se a policy já existia mas nasceu vazia (versões anteriores deste script),
# acrescenta o System agora
req GET "$KB/api/fleet/agent_policies/onp-host-policy"
if printf '%s' "$CORPO" | grep -q '"name":"system"'; then
  ok "integração System presente na policy do host"
else
  aviso "policy do host sem integração System — acrescentando"
  req GET "$KB/api/fleet/epm/packages/system"
  SYS_VER=$(printf '%s' "$CORPO" | grep -o '"latestVersion":[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
  [ -z "$SYS_VER" ] && SYS_VER=$(printf '%s' "$CORPO" | grep -o '"version":[[:space:]]*"[0-9][^"]*"' | head -1 | cut -d'"' -f4)
  if [ -n "$SYS_VER" ]; then
    req POST "$KB/api/fleet/epm/packages/system/${SYS_VER}" '{"force":true}'
    # sem `inputs`: o Fleet preenche todos os padrões (os do System servem)
    req POST "$KB/api/fleet/package_policies" \
      "{\"name\":\"system-onp\",\"namespace\":\"default\",\"policy_id\":\"onp-host-policy\",
        \"package\":{\"name\":\"system\",\"version\":\"${SYS_VER}\"}}"
    case "$HTTP" in
      200|201|409) ok "integração System adicionada" ;;
      *)           erro "não adicionei o System (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 250)" ;;
    esac
  else
    erro "não descobri a versão do pacote system"
  fi
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

# Verifica de verdade em vez de só declarar sucesso. Cada app é um alvo de
# observação usado nas lições — se uma não subir, a lição correspondente fica
# sem dado e o aluno descobre no meio da aula.
sleep 5
for svc in loja-web loja-api pagamento gerador-logs gerador-trafego; do
  estado=$($DC ps --format '{{.Service}} {{.State}}' 2>/dev/null | grep "^${svc} " | awk '{print $2}')
  case "$estado" in
    running) ok "container ${svc}: running" ;;
    "")      erro "container ${svc}: não existe. Veja: $DC ps -a" ;;
    *)       erro "container ${svc}: ${estado}. Veja: $DC logs ${svc}" ;;
  esac
done

# checagem de porta: container rodando não garante serviço respondendo
for alvo in "loja-web http://localhost:8080" "loja-api http://localhost:5000/health"; do
  nome=${alvo%% *}; url=${alvo#* }
  if espera "$nome responder em ${url}" "porta_aberta ${url}" 12; then
    ok "${nome} respondendo"
  else
    erro "${nome} não respondeu em ${url}"
    echo "        $DC logs ${nome}"
    echo "        se for 'port is already allocated', outro serviço ocupa a porta:"
    echo "          Windows:  netstat -ano | findstr :${url##*:}"
  fi
done

if ./scripts/carregar-dados.sh; then
  ok "dados de exemplo indexados"
else
  erro "falha ao carregar dados de exemplo"
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
