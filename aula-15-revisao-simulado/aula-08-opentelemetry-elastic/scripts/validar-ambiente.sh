#!/usr/bin/env bash
# Validação - Aula 7 (OpenTelemetry -> Collector -> Elastic)
set -uo pipefail
[ -f .env ] && export "$(grep -v '^#' .env | xargs)" || { echo "Copie .env.example para .env"; exit 1; }

echo "==> 1. Containers"; docker compose ps
echo ""; echo "==> 2. APM Server (OTLP nativo) respondendo"
curl -s http://localhost:8200 | head -3 || echo "Integração APM ainda não adicionada (README passo 7)"
echo ""; echo "==> 3. Vitrine respondendo (e gerando trace Node -> Python)"
curl -s http://localhost:5003/produtos | head -c 200; echo ""
echo ""; echo "==> 4. Collector recebendo/exportando (últimas linhas do debug exporter)"
docker compose logs --tail 8 otel-collector
echo ""; echo "==> 5. Dados de APM/OTel no Elasticsearch"
curl -s -u "elastic:${ELASTIC_PASSWORD}" "http://localhost:9200/_cat/indices/*apm*?v&h=index,docs.count" | head -8
echo ""
echo "Com tudo OK: APM app lista 'vitrine' (Node) e 'catalogo' (Python), e o"
echo "trace do GET /produtos atravessa as duas linguagens."
