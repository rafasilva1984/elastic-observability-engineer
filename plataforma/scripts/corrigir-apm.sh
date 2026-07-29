#!/usr/bin/env bash
# =============================================================================
#  corrigir-apm.sh — cria a integração APM na plataforma que JÁ está no ar.
# =============================================================================
#  Uso:
#     ./scripts/corrigir-apm.sh              cria/recria a integração
#     ./scripts/corrigir-apm.sh --remover    remove a integração (rollback)
#
#  ---------------------------------------------------------------------------
#  A ESTRATÉGIA (e por que ela é assim)
#
#  Quando você manda `vars` explicitamente no POST, o Fleet usa SÓ aquelas e
#  NÃO preenche os padrões do pacote. Cada bloco opcional do apm-server que
#  ficar sem sua flag renderiza com valores nulos e o APM Server recusa a
#  configuração inteira. Descobrimos isso na marra, um erro por vez:
#
#     faltou tls_enabled            -> "certificate file not configured
#                                       accessing 'apm-server.ssl'"
#     faltou tail_sampling_enabled  -> "no policies specified accessing
#                                       'apm-server.sampling.tail'"
#
#  O pacote APM tem dezenas de vars. Perseguir uma por uma é jogo perdido.
#  Então este script faz o contrário:
#
#     1. cria uma package policy DESCARTÁVEL sem `inputs`, numa agent policy
#        temporária onde nenhum agente está enrolado (zero perturbação);
#     2. o Fleet devolve o conjunto COMPLETO de vars, com todos os padrões;
#     3. extraímos esse objeto e trocamos apenas `host` e `secret_token`;
#     4. apagamos os temporários e criamos a integração real com esses vars.
#
#  Resultado: qualquer var nova que a Elastic acrescentar em versões futuras
#  vem junto sozinha. O script não precisa saber quais são.
#
#  Por que `host` tem de virar 0.0.0.0:8200: o padrão é localhost:8200, e
#  dentro do container isso é 127.0.0.1 — inalcançável tanto pelo mapeamento
#  de portas do Docker quanto pelos outros containers da rede.
#
#  Nada de arquivo temporário no curl: no Git Bash com MSYS_NO_PATHCONV=1 o
#  caminho /tmp/... não é convertido, o curl grava em C:\tmp\... e o cat lê
#  outro lugar (HTTP 200 com corpo vazio).
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
KB="http://localhost:5601"; AUTH="elastic:${ELASTIC_PASSWORD}"
ACAO="${1:-criar}"
POLICY_TMP="onp-apm-template-tmp"

ok()    { printf '  \033[1;32mok\033[0m    %s\n' "$*"; }
aviso() { printf '  \033[1;33maviso\033[0m %s\n' "$*"; }
erro()  { printf '  \033[1;31mERRO\033[0m  %s\n' "$*"; }
passo() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }

HTTP=""; CORPO=""
req() {   # SEMPRE como comando simples — nunca dentro de $( ), que é subshell
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

porta_aberta() {
  local c; c=$(curl -s -m 3 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && [ "$c" != "000" ]
}

# extrai o primeiro objeto "vars":{...} com contagem de chaves balanceada
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

# remove package policies cujo nome comece com o prefixo dado
remove_pp() {
  local prefixo="$1" ids i n=0
  req GET "$KB/api/fleet/package_policies?perPage=200"
  ids=$(printf '%s' "$CORPO" | tr '{' '\n' | grep "\"name\":\"${prefixo}" \
        | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
  for i in $ids; do
    req DELETE "$KB/api/fleet/package_policies/$i"
    n=$((n+1))
  done
  echo "$n"
}

# ----------------------------------------------------------------- rollback
if [ "$ACAO" = "--remover" ]; then
  passo "Removendo a integração APM (rollback)"
  N=$(remove_pp "apm-onp")
  ok "${N} integração(ões) removida(s)"
  req POST "$KB/api/fleet/agent_policies/delete" "{\"agentPolicyId\":\"${POLICY_TMP}\"}"
  echo
  echo "  Em ~30s o agente volta para Healthy no Kibana."
  echo "  Para recriar:  ./scripts/corrigir-apm.sh"
  exit 0
fi

# ------------------------------------------------------------------ criar
passo "0/6  Ambiente"
echo "  curl:  $(command -v curl)"
echo "  shell: ${BASH_VERSION:-?}   MSYS_NO_PATHCONV=${MSYS_NO_PATHCONV:-<vazio>}"

passo "1/6  Descobrindo a versão do pacote apm"
req GET "$KB/api/fleet/epm/packages/apm"
[ -z "$CORPO" ] && { erro "HTTP $HTTP com corpo vazio."; exit 1; }
VER=$(printf '%s' "$CORPO" | grep -o '"latestVersion":[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
[ -z "$VER" ] && VER=$(printf '%s' "$CORPO" | grep -o '"version":[[:space:]]*"[0-9][^"]*"' | head -1 | cut -d'"' -f4)
[ -z "$VER" ] && { erro "não achei a versão: $(printf '%s' "$CORPO" | head -c 300)"; exit 1; }
ok "pacote apm versão ${VER}"

passo "2/6  Instalando o pacote"
req POST "$KB/api/fleet/epm/packages/apm/${VER}" '{"force":true}'
case "$HTTP" in
  200|201|409) ok "pacote pronto (HTTP $HTTP)" ;;
  *)           aviso "instalação retornou HTTP $HTTP (seguindo)" ;;
esac

passo "3/6  Limpando tentativas anteriores"
N=$(remove_pp "apm-onp"); ok "${N} integração(ões) apm-onp removida(s)"
N=$(remove_pp "apm-tmp");  ok "${N} temporária(s) removida(s)"
req POST "$KB/api/fleet/agent_policies/delete" "{\"agentPolicyId\":\"${POLICY_TMP}\"}"

passo "4/6  Lendo os padrões do pacote no próprio Fleet"
# agent policy temporária: nenhum agente enrolado nela, então nada roda
req POST "$KB/api/fleet/agent_policies" \
  "{\"id\":\"${POLICY_TMP}\",\"name\":\"ONP APM template (temporária)\",\"namespace\":\"default\"}"
case "$HTTP" in
  200|201|409) ok "policy temporária pronta" ;;
  *)           erro "não criei a policy temporária (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 300)"; exit 1 ;;
esac

# package policy SEM `inputs`: o Fleet preenche todos os padrões
req POST "$KB/api/fleet/package_policies" \
  "{\"name\":\"apm-tmp\",\"namespace\":\"default\",\"policy_id\":\"${POLICY_TMP}\",
    \"package\":{\"name\":\"apm\",\"version\":\"${VER}\"}}"
if [ "$HTTP" != "200" ] && [ "$HTTP" != "201" ]; then
  erro "não consegui criar a temporária (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 400)"
  exit 1
fi

VARS=$(printf '%s' "$CORPO" | extrai_vars)
if [ -z "$VARS" ] || ! printf '%s' "$VARS" | grep -q '"host"'; then
  erro "não consegui extrair o objeto vars da resposta."
  echo "        início da resposta: $(printf '%s' "$CORPO" | head -c 400)"
  exit 1
fi
QTD=$(printf '%s' "$VARS" | grep -o '"[a-z_]*":{' | wc -l | tr -d ' ')
ok "${QTD} variáveis lidas com os padrões do pacote (${#VARS} bytes)"

# limpa os temporários — não precisamos mais deles
remove_pp "apm-tmp" > /dev/null
req POST "$KB/api/fleet/agent_policies/delete" "{\"agentPolicyId\":\"${POLICY_TMP}\"}"
ok "temporários removidos"

passo "5/6  Sobrescrevendo host e secret_token"
VARS=$(printf '%s' "$VARS" | sed 's|"host":{"value":"[^"]*"|"host":{"value":"0.0.0.0:8200"|')
if printf '%s' "$VARS" | grep -q '"secret_token":{"value"'; then
  VARS=$(printf '%s' "$VARS" | sed "s|\"secret_token\":{\"value\":\"[^\"]*\"|\"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\"|")
else
  VARS=$(printf '%s' "$VARS" | sed "s|\"secret_token\":{|\"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\",|")
fi
printf '%s' "$VARS" | grep -q '"host":{"value":"0.0.0.0:8200"' \
  && ok "host = 0.0.0.0:8200" || { erro "não consegui trocar o host"; exit 1; }
printf '%s' "$VARS" | grep -q "\"secret_token\":{\"value\":\"${APM_SECRET_TOKEN}\"" \
  && ok "secret_token aplicado" || { erro "não consegui aplicar o secret_token"; exit 1; }

req POST "$KB/api/fleet/package_policies" \
  "{\"name\":\"apm-onp\",\"namespace\":\"default\",\"policy_id\":\"fleet-server-policy\",
    \"package\":{\"name\":\"apm\",\"version\":\"${VER}\"},
    \"inputs\":[{\"type\":\"apm\",\"policy_template\":\"apmserver\",\"enabled\":true,
      \"streams\":[],\"vars\":${VARS}}]}"
case "$HTTP" in
  200|201) ok "integração apm-onp criada na policy do Fleet Server" ;;
  409)     ok "integração já existia" ;;
  *)       erro "falhou (HTTP $HTTP): $(printf '%s' "$CORPO" | head -c 500)"; exit 1 ;;
esac

passo "6/6  Esperando o APM Server abrir a porta 8200"
echo "  O agente busca a nova revisão a cada ~10s."
echo "  Estados normais da unit: STARTING > CONFIGURING > HEALTHY"
echo

# Ao ler "Unit state changed ... (ANTIGO->NOVO)", o que importa é o da DIREITA.
# Um grep por "FAILED" casa com "(FAILED->CONFIGURING)" — que é RECUPERAÇÃO.
estado_atual() {
  docker compose logs --since 3m fleet-server 2>/dev/null \
    | grep -o 'Unit state changed apm-default[^"]*' | tail -1
}

i=1; seguidas=0; anterior=""
while [ "$i" -le 36 ]; do
  if porta_aberta http://localhost:8200; then
    CODIGO=$(curl -s -m 3 -o /dev/null -w '%{http_code}' http://localhost:8200)
    echo
    ok "APM Server no ar — http://localhost:8200 responde HTTP ${CODIGO}"
    echo
    echo "  (401 é o esperado: porta aberta, secret token exigindo auth)"
    echo
    echo "  Próximo passo:"
    echo "      docker compose restart loja-api pagamento"
    echo "      ./scripts/validar.sh"
    exit 0
  fi

  LINHA=$(estado_atual)
  NOVO=$(printf '%s' "$LINHA" | sed -n 's/.*->\([A-Z]*\)).*/\1/p' | tail -1)
  [ -z "$NOVO" ] && NOVO="aguardando"
  if [ "$NOVO" != "$anterior" ]; then printf '\n  unit: %s ' "$NOVO"; anterior="$NOVO"; fi
  if [ "$NOVO" = "FAILED" ]; then seguidas=$((seguidas+1)); else seguidas=0; fi

  if [ "$seguidas" -ge 3 ]; then
    echo
    erro "a unit do APM está em FAILED de forma persistente. Motivo:"
    printf '%s' "$LINHA" | sed -n 's/.*->[A-Z]*): //p' | fold -s -w 74 | sed 's/^/        /'
    echo
    echo "  Rollback:  ./scripts/corrigir-apm.sh --remover"
    exit 1
  fi

  printf '.'; sleep 5; i=$((i+1))
done
echo
erro "a porta 8200 não abriu em 3 minutos. Último estado da unit: ${anterior}"
echo
echo "  Acompanhe ao vivo com:"
echo "      docker compose logs -f fleet-server | grep 'Unit state changed apm'"
exit 1
