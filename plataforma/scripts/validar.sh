#!/usr/bin/env bash
# =============================================================================
#  validar.sh — confere se a plataforma está 100% no ar.
# =============================================================================
#  Toda falha vem com a pista do que fazer, não só o "falha".
#
#  Duas checagens que estavam ERRADAS nas versões anteriores e foram corrigidas:
#
#  1. APM:  `curl http://localhost:8200 | grep -q .` dava falso negativo,
#           porque com secret_token o APM responde corpo VAZIO. O certo é
#           olhar o código HTTP (401 ou 200 = no ar; 000 = porta fechada).
#
#  2. Contagens: `curl .../_count | grep -qv '"count":0'` PASSA quando o
#           índice não existe (a resposta 404 também não contém "count":0).
#           Agora extraímos o número e comparamos de verdade.
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
ES="http://localhost:9200"; KB="http://localhost:5601"; AUTH="elastic:${ELASTIC_PASSWORD}"
falhas=0

ok()    { printf '  \033[1;32mok\033[0m    %s\n' "$*"; }
falha() { printf '  \033[1;31mfalha\033[0m %s\n' "$*"; falhas=$((falhas+1)); }
dica()  { printf '        \033[2m%s\033[0m\n' "$*"; }
titulo(){ printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }

chk() { if eval "$2" > /dev/null 2>&1; then ok "$1"; else falha "$1"; return 1; fi; }

responde() {  # porta aberta? qualquer HTTP serve, inclusive 401
  local c; c=$(curl -s -m 5 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && [ "$c" != "000" ]
}

conta() {     # nº de documentos de um índice/padrão (0 se não existir)
  local n; n=$(curl -s -u "$AUTH" "$ES/$1/_count" 2>/dev/null \
    | grep -o '"count":[0-9]*' | head -1 | cut -d: -f2)
  echo "${n:-0}"
}

estado_container() {
  docker compose ps --format '{{.Service}} {{.State}}' 2>/dev/null \
    | grep "^$1 " | awk '{print $2}'
}

titulo "Plataforma"
chk "Elasticsearch respondendo" "curl -s -u '$AUTH' $ES/_cluster/health | grep -q status" \
  || dica "docker compose logs elasticsearch"
chk "Kibana disponível" "curl -s $KB/api/status | grep -q '\"level\":\"available\"'" \
  || dica "docker compose logs kibana   (o Kibana leva 1-2 min)"
chk "Fleet Server online" "curl -s -u '$AUTH' '$KB/api/fleet/agents?perPage=50' -H 'kbn-xsrf: true' | grep -q '\"status\":\"online\"'" \
  || dica "docker compose logs fleet-server"
chk "output aponta p/ elasticsearch" "curl -s -u '$AUTH' $KB/api/fleet/outputs -H 'kbn-xsrf: true' | grep -q 'elasticsearch:9200'" \
  || dica "recrie: ./scripts/limpar.sh && ./scripts/subir.sh"

titulo "APM"
chk "integração apm-onp na policy" "curl -s -u '$AUTH' '$KB/api/fleet/package_policies?perPage=200' -H 'kbn-xsrf: true' | grep -q '\"name\":\"apm-onp\"'" \
  || dica "./scripts/corrigir-apm.sh"
if responde http://localhost:8200; then
  ok "porta 8200 aberta (HTTP $(curl -s -m 5 -o /dev/null -w '%{http_code}' http://localhost:8200))"
else
  falha "porta 8200 fechada"
  dica "./scripts/corrigir-apm.sh"
  dica "docker compose logs fleet-server | grep 'Unit state changed apm'"
fi

titulo "Dados"
N=$(conta "onp-web-logs")
if [ "$N" -ge 700 ]; then ok "onp-web-logs: ${N} documentos"
else
  falha "onp-web-logs: ${N} documentos (esperado 720)"
  dica "./scripts/carregar-dados.sh --forcar"
fi

chk "logs da app (data stream)" "curl -s -u '$AUTH' '$ES/_data_stream/logs-*' | grep -q name" \
  || dica "docker compose logs gerador-logs"

N=$(conta "metrics-system*")
if [ "$N" -gt 0 ]; then ok "métricas do host: ${N} documentos"
else
  falha "métricas do host: nenhum documento"
  dica "a policy do host precisa da integração System."
  dica "confira:  curl -s -u elastic:\$ELASTIC_PASSWORD \\"
  dica "            \"$KB/api/fleet/agent_policies/onp-host-policy\" \\"
  dica "            -H 'kbn-xsrf: true' | grep -o '\"name\":\"system\"'"
  dica "corrija:  ./scripts/subir.sh   (acrescenta o System se faltar)"
  dica "o agente também precisa estar rodando: docker compose ps agente-host"
  dica "e a coleta tem intervalo: espere 1-2 min após enrolar"
fi

titulo "Aplicações"
for par in "loja-web http://localhost:8080" "loja-api http://localhost:5000/health"; do
  nome=${par%% *}; url=${par#* }
  if responde "$url"; then
    ok "${nome} respondendo em ${url}"
  else
    falha "${nome} não responde em ${url}"
    est=$(estado_container "$nome")
    case "$est" in
      running) dica "container está running mas a porta não responde" ;
               dica "docker compose logs ${nome} | tail -30" ;;
      "")      dica "container não existe: docker compose up -d ${nome}" ;;
      *)       dica "container em estado '${est}': docker compose logs ${nome}" ;;
    esac
    dica "porta ocupada por outro processo? netstat -ano | findstr :${url##*:}"
  fi
done

titulo "Containers"
docker compose ps --format 'table {{.Service}}\t{{.State}}\t{{.Ports}}' 2>/dev/null \
  | sed 's/^/  /' || dica "docker compose não respondeu"

echo
if [ "$falhas" -eq 0 ]; then
  echo "Tudo certo — pode começar as lições."
else
  echo "${falhas} item(ns) com falha. As dicas acima apontam o caminho."
  exit 1
fi
