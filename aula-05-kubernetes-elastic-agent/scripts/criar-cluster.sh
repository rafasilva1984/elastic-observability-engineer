#!/usr/bin/env bash
# Cria o cluster Kubernetes local (k3d) conectado à rede onp-net do
# Docker Compose, para que os pods do Elastic Agent resolvam
# "fleet-server" e "elasticsearch" pelo DNS do Docker.
#
# Pré-requisitos: k3d (https://k3d.io) e kubectl instalados.
# Uso: ./scripts/criar-cluster.sh

set -euo pipefail

command -v k3d >/dev/null || { echo "k3d não encontrado. Instale: https://k3d.io"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl não encontrado."; exit 1; }

echo "==> Criando cluster k3d 'onp' (1 server + 2 agents) na rede onp-net"
k3d cluster create onp \
  --servers 1 \
  --agents 2 \
  --network onp-net \
  --wait

echo ""
echo "==> Nodes do cluster:"
kubectl get nodes -o wide

echo ""
echo "Cluster pronto. Contexto kubectl: k3d-onp"
echo "Próximo passo: ./scripts/instalar-kube-state-metrics.sh"
