#!/usr/bin/env bash
# Instala o kube-state-metrics no cluster — REQUISITO OFICIAL da integração
# Kubernetes do Elastic Agent para os metricsets de estado (state_*).
#
# Fonte oficial: a documentação da Elastic instrui a implantar o
# kube-state-metrics a partir do repositório oficial do projeto
# (https://github.com/kubernetes/kube-state-metrics).
#
# Uso: ./scripts/instalar-kube-state-metrics.sh

set -euo pipefail

echo "==> Aplicando kube-state-metrics (manifests padrão do repositório oficial)"
kubectl apply -k "github.com/kubernetes/kube-state-metrics"

echo ""
echo "==> Aguardando o deployment ficar disponível..."
kubectl -n kube-system rollout status deployment/kube-state-metrics --timeout=180s

echo ""
kubectl -n kube-system get pods -l app.kubernetes.io/name=kube-state-metrics
echo ""
echo "kube-state-metrics instalado. Próximo passo: baixar o manifesto do"
echo "Elastic Agent no Kibana (README, passo 8) e aplicar com kubectl."
