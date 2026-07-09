#!/usr/bin/env bash
# Validação do ambiente - Aula 3 (Logs com Elastic Observability)
# Uso: ./scripts/validar-ambiente.sh

set -uo pipefail

if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado. Copie .env.example para .env antes de continuar."
  exit 1
fi

echo "==> 1. Status dos containers"
docker compose ps

echo ""
echo "==> 2. Saúde do cluster Elasticsearch"
curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health?pretty

echo ""
echo "==> 3. Status do Kibana"
curl -s http://localhost:5601/api/status | grep -o '"level":"[a-z]*"' || echo "Kibana ainda não respondeu."

echo ""
echo "==> 4. Fleet Server respondendo na 8220"
curl -sk -o /dev/null -w "HTTP status do Fleet Server: %{http_code}\n" https://localhost:8220/api/status || \
  echo "Fleet Server ainda não está pronto (ver README passo 6.2)."

echo ""
echo "==> 5. Gerador de logs escrevendo"
docker exec app-gerador-onp sh -c 'tail -3 /var/log/app/app.log' 2>/dev/null || \
  echo "app-gerador ainda não escreveu logs."

echo ""
echo "==> 6. Data stream de logs recebendo documentos (após enrolar o agente)"
curl -s -u "elastic:${ELASTIC_PASSWORD}" \
  "http://localhost:9200/logs-app_exemplo-*/_count?pretty" 2>/dev/null || \
  echo "Data stream logs-app_exemplo-* ainda não existe (ver README passos 7 e 8)."

echo ""
echo "Validação concluída. Com tudo OK, explore os logs no Kibana > Discover"
echo "filtrando por data_stream.dataset : \"app_exemplo\"."
