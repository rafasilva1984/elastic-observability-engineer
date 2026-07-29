#!/usr/bin/env bash
# Confere se a plataforma está 100% no ar.
#
# Nota sobre a checagem do APM: NÃO use "curl http://localhost:8200 | grep -q ."
# Com secret_token configurado, o APM Server responde 401 com corpo VAZIO — o
# grep falha e a checagem acusa erro num serviço que está perfeito. O jeito
# correto é olhar o código HTTP: qualquer coisa diferente de 000 significa que
# a porta está aberta e alguém respondeu.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
ES="http://localhost:9200"; KB="http://localhost:5601"; AUTH="elastic:${ELASTIC_PASSWORD}"
falhas=0

chk() { if eval "$2" > /dev/null 2>&1; then printf '  \033[1;32mok\033[0m    %s\n' "$1";
        else printf '  \033[1;31mfalha\033[0m %s\n' "$1"; falhas=$((falhas+1)); fi; }

# responde <url> -> verdadeiro se a porta está aberta e devolveu qualquer HTTP
responde() {
  local c
  c=$(curl -s -m 5 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && [ "$c" != "000" ]
}

echo "== Plataforma =="
chk "Elasticsearch respondendo"      "curl -s -u '$AUTH' $ES/_cluster/health | grep -q status"
chk "Kibana disponível"              "curl -s $KB/api/status | grep -q '\"level\":\"available\"'"
chk "Fleet Server online"            "curl -s -u '$AUTH' '$KB/api/fleet/agents?perPage=50' -H 'kbn-xsrf: true' | grep -q '\"status\":\"online\"'"
chk "output aponta p/ elasticsearch" "curl -s -u '$AUTH' $KB/api/fleet/outputs -H 'kbn-xsrf: true' | grep -q 'http://elasticsearch:9200'"

echo "== APM =="
chk "integração apm-onp na policy"   "curl -s -u '$AUTH' '$KB/api/fleet/package_policies?perPage=200' -H 'kbn-xsrf: true' | grep -q '\"name\":\"apm-onp\"'"
chk "porta 8200 aberta"              "responde http://localhost:8200"

echo "== Dados =="
chk "índice onp-web-logs com dados"  "curl -s -u '$AUTH' $ES/onp-web-logs/_count | grep -qv '\"count\":0'"
chk "logs da app (data stream)"      "curl -s -u '$AUTH' '$ES/_data_stream/logs-*' | grep -q name"
chk "métricas do host"               "curl -s -u '$AUTH' '$ES/metrics-system*/_count' | grep -qv '\"count\":0'"

echo "== Aplicações =="
chk "loja-web (:8080)"               "curl -s -m 5 -o /dev/null -w '%{http_code}' http://localhost:8080 | grep -q 200"
chk "loja-api (:5000)"               "curl -s -m 5 http://localhost:5000/health | grep -q ok"

echo
if [ "$falhas" -eq 0 ]; then
  echo "Tudo certo — pode começar as lições."
else
  echo "$falhas item(ns) com falha."
  echo
  echo "  Coleta tem intervalo: se a falha for em 'métricas do host' ou"
  echo "  'logs da app', espere 1-2 min e rode de novo."
  echo
  echo "  Se a falha for em APM, rode ./scripts/subir.sh de novo — ele é"
  echo "  idempotente e vai recriar só o que falta."
  exit 1
fi
