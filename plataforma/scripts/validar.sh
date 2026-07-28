#!/usr/bin/env bash
# Confere se a plataforma está 100% no ar.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a
ES="http://localhost:9200"; KB="http://localhost:5601"; AUTH="elastic:${ELASTIC_PASSWORD}"
falhas=0
chk() { if eval "$2" > /dev/null 2>&1; then printf '  \033[1;32mok\033[0m   %s\n' "$1";
        else printf '  \033[1;31mfalha\033[0m %s\n' "$1"; falhas=$((falhas+1)); fi; }

echo "== Plataforma =="
chk "Elasticsearch respondendo"      "curl -s -u '$AUTH' $ES/_cluster/health | grep -q status"
chk "Kibana disponível"              "curl -s $KB/api/status | grep -q '\"level\":\"available\"'"
chk "Fleet Server online"            "curl -s -u '$AUTH' '$KB/api/fleet/agents?perPage=50' -H 'kbn-xsrf: true' | grep -q '\"status\":\"online\"'"
chk "APM Server ouvindo na 8200"     "curl -s -m 5 http://localhost:8200 | grep -q ."
chk "output aponta p/ elasticsearch" "curl -s -u '$AUTH' $KB/api/fleet/outputs -H 'kbn-xsrf: true' | grep -q 'http://elasticsearch:9200'"
echo "== Dados =="
chk "índice onp-web-logs com dados"  "curl -s -u '$AUTH' $ES/onp-web-logs/_count | grep -qv '\"count\":0'"
chk "logs da app (data stream)"      "curl -s -u '$AUTH' '$ES/_data_stream/logs-*' | grep -q name"
chk "métricas do host"               "curl -s -u '$AUTH' '$ES/metrics-system*/_count' | grep -qv '\"count\":0'"
echo "== Aplicações =="
chk "loja-web (:8080)"               "curl -s -m 5 -o /dev/null -w '%{http_code}' http://localhost:8080 | grep -q 200"
chk "loja-api (:5000)"               "curl -s -m 5 http://localhost:5000/health | grep -q ok"
echo
[ "$falhas" -eq 0 ] && echo "Tudo certo — pode começar as lições." \
  || echo "$falhas item(ns) com falha. Dica: aguarde 1-2 min e rode de novo (coleta tem intervalo)."
