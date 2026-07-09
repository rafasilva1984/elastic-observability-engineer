#!/usr/bin/env bash
# Validação do ambiente - Aula 4 (Kubernetes com Elastic Agent)
# Uso: ./scripts/validar-ambiente.sh

set -uo pipefail

if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
else
  echo "Arquivo .env não encontrado."; exit 1
fi

echo "==> 1. Containers do Elastic Stack"
docker compose ps

echo ""
echo "==> 2. Saúde do Elasticsearch"
curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health?pretty | grep -E '"status"|"number_of_nodes"'

echo ""
echo "==> 3. Nodes do cluster Kubernetes (k3d)"
kubectl get nodes 2>/dev/null || echo "Cluster k3d não encontrado (rode ./scripts/criar-cluster.sh)."

echo ""
echo "==> 4. kube-state-metrics"
kubectl -n kube-system get pods -l app.kubernetes.io/name=kube-state-metrics 2>/dev/null || \
  echo "kube-state-metrics ausente (rode ./scripts/instalar-kube-state-metrics.sh)."

echo ""
echo "==> 5. DaemonSet do Elastic Agent (1 pod por node esperado)"
kubectl -n kube-system get pods -l app=elastic-agent 2>/dev/null || \
  echo "Elastic Agent ainda não aplicado (README, passo 8)."

echo ""
echo "==> 6. Workload de exemplo (restarts do pod-problematico devem crescer)"
kubectl get pods -l 'app in (loja-web,pod-problematico)' 2>/dev/null || \
  echo "Workload não aplicado (kubectl apply -f k8s/app-exemplo.yaml)."

echo ""
echo "==> 7. Data streams de Kubernetes no Elasticsearch"
curl -s -u "elastic:${ELASTIC_PASSWORD}" \
  "http://localhost:9200/_cat/indices/*kubernetes*?v&h=index,docs.count" 2>/dev/null | head -12 || \
  echo "Ainda sem dados de Kubernetes."

echo ""
echo "Com tudo OK: Kibana > Observability > Infrastructure mostra o inventário"
echo "de pods, e o dashboard [Metrics Kubernetes] Cluster Overview tem dados."
