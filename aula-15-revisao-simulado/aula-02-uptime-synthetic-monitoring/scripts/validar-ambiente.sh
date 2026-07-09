#!/usr/bin/env bash
# Script de validação do ambiente - Aula 1 (Uptime / Synthetic Monitoring)
# Uso: ./scripts/validar-ambiente.sh

set -uo pipefail

if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado. Copie .env.example para .env antes de continuar."
  exit 1
fi

echo "==> 1. Verificando status dos containers"
docker compose ps

echo ""
echo "==> 2. Verificando saúde do cluster Elasticsearch"
curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health?pretty

echo ""
echo "==> 3. Verificando status do Kibana"
curl -s http://localhost:5601/api/status | grep -o '"level":"[a-z]*"' || echo "Kibana ainda não respondeu. Aguarde alguns segundos e tente novamente."

echo ""
echo "==> 4. Verificando se o app-exemplo (Nginx) está respondendo"
curl -s -o /dev/null -w "HTTP status do app-exemplo: %{http_code}\n" http://localhost:8080

echo ""
echo "==> 5. Verificando se o Fleet Server está respondendo na porta 8220"
curl -sk -o /dev/null -w "HTTP status do Fleet Server: %{http_code}\n" https://localhost:8220/api/status || \
  echo "Fleet Server ainda não está pronto, ou o FLEET_SERVER_SERVICE_TOKEN não foi configurado (ver README passo 6)."

echo ""
echo "==> 6. Verificando se o Elastic Agent (Private Location) está rodando"
docker compose --profile synthetics ps synthetics-agent 2>/dev/null || \
  echo "synthetics-agent ainda não foi iniciado (ver README passo 7)."

echo ""
echo "Validação concluída. Para confirmar que a Private Location está com status"
echo "'Healthy' e que os monitores estão coletando dados, confira no Kibana em"
echo "Observability > Synthetics."
