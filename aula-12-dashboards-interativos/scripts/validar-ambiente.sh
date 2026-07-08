#!/usr/bin/env bash
# Validação do ambiente - Vídeo 1 (Introdução ao Kibana)
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
echo "==> 4. Índices de sample data (devem aparecer após rodar carregar-dados.sh)"
curl -s -u "elastic:${ELASTIC_PASSWORD}" \
  "http://localhost:9200/_cat/indices/kibana_sample_data_*?v&h=index,docs.count,store.size" || \
  echo "Nenhum índice de sample data ainda. Rode ./scripts/carregar-dados.sh"

echo ""
echo "Validação concluída."
