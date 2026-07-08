#!/usr/bin/env bash
# Carrega os sample data sets oficiais do Kibana (eCommerce, Flights, Web Logs)
# via API, sem precisar clicar na interface.
#
# Uso: ./scripts/carregar-sample-data.sh
#
# Fonte oficial dos sample data sets:
# https://www.elastic.co/docs/explore-analyze/kibana-data-exploration-learning-tutorial

set -uo pipefail

if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado. Copie .env.example para .env antes de continuar."
  exit 1
fi

KB="http://localhost:5601"
AUTH="elastic:${ELASTIC_PASSWORD}"

echo "==> Aguardando o Kibana ficar disponível..."
for i in $(seq 1 30); do
  if curl -s "${KB}/api/status" | grep -q '"level":"available"'; then
    echo "Kibana disponível."
    break
  fi
  echo "   ...ainda subindo (tentativa ${i}/30)"
  sleep 5
done

# A API de sample data do Kibana usa o header kbn-xsrf obrigatório.
for ds in ecommerce flights logs; do
  echo "==> Carregando sample data: ${ds}"
  curl -s -X POST -u "${AUTH}" \
    -H "kbn-xsrf: true" \
    "${KB}/api/sample_data/${ds}" \
    -o /dev/null -w "   status HTTP: %{http_code}\n"
done

echo ""
echo "Pronto. Acesse o Kibana em ${KB} e explore os dados em Discover, Lens e Dashboards."
echo "Índices criados: kibana_sample_data_ecommerce, kibana_sample_data_flights, kibana_sample_data_logs"
