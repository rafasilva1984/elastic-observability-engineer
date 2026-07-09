# Aula 05 — Monitorando Kubernetes com Elastic Agent

Projeto de apoio do **Vídeo 5** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Monitorando Kubernetes com Elastic Agent** — DaemonSet gerenciado por
Fleet, integração Kubernetes, kube-state-metrics e análise na Infrastructure
app e nos dashboards curados `[Metrics Kubernetes]`.

---

## 1. Objetivo do projeto

Monitorar um cluster Kubernetes local de ponta a ponta:

- Elastic Stack + Fleet Server via Docker Compose.
- Cluster **k3d** (1 server + 2 agents) conectado à mesma rede Docker.
- **kube-state-metrics** (requisito oficial para os metricsets de estado).
- **Elastic Agent como DaemonSet** via manifesto oficial baixado do Kibana.
- Workload de exemplo com um pod saudável e um em CrashLoopBackOff proposital.

## 2. Arquitetura da solução

```
        cluster k3d (rede onp-net)                Docker Compose (rede onp-net)
┌─────────────────────────────────────────┐   ┌─────────────────────────────┐
│ node1  node2  node3                     │   │  ┌────────────┐             │
│  ├─ elastic-agent (DaemonSet, 1/node)   │──►│  │fleet-server│             │
│  │    └─ pod líder coleta métricas de   │   │  └─────┬──────┘             │
│  │       cluster + kube-state-metrics   │   │        ▼                    │
│  ├─ kube-state-metrics (estado)         │   │  ┌────────────┐  ┌────────┐ │
│  └─ loja-web + pod-problematico         │   │  │elasticsearch│◄─┤ kibana │ │
└─────────────────────────────────────────┘   │  └────────────┘  └────────┘ │
                                              └─────────────────────────────┘
```

Pontos oficiais importantes: o DaemonSet garante **1 agente por node**; um dos
pods segura o **leader lock** e coleta as métricas de cluster (eventos e
kube-state-metrics); o manifesto oficial usa **hostNetwork: true**, e é por
isso que o nome `fleet-server` resolve via DNS do Docker a partir dos nodes.

## 3. Pré-requisitos

- Docker Engine 24+ e Docker Compose v2.20+.
- **k3d** (https://k3d.io) e **kubectl** instalados.
- 6 GB de RAM livres (Stack + cluster de 3 nodes).
- Portas livres: `9200`, `5601`, `8220`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-05-kubernetes-elastic-agent
```

## 5. Como configurar as variáveis de ambiente

```bash
cp .env.example .env
```

Deixe `FLEET_SERVER_SERVICE_TOKEN` em branco por enquanto.

## 6. Como subir o Elastic Stack

```bash
docker compose up -d elasticsearch kibana
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

### 6.2 Service token e Fleet Server

```bash
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
# cole o token em FLEET_SERVER_SERVICE_TOKEN no .env
# Cria a policy do Fleet Server no Kibana (obrigatório no 9.x — sem isso o
# Fleet Server fica preso em "Waiting on policy"). Rode ANTES de subir o Fleet:
./scripts/setup-fleet.sh
```

Em seguida, suba o Fleet Server:

```bash
docker compose up -d fleet-server
```

## 7. Como criar o cluster Kubernetes e instalar o kube-state-metrics

```bash
./scripts/criar-cluster.sh
./scripts/instalar-kube-state-metrics.sh
```

O primeiro script cria o cluster k3d **na rede `onp-net`** (essencial). O
segundo aplica o kube-state-metrics do repositório oficial — **sem ele, os
metricsets `state_*` da integração não funcionam** (requisito documentado).

## 8. Como implantar o Elastic Agent (DaemonSet) via Fleet

No Kibana (http://localhost:5601):

1. **Fleet > Agent policies > Create agent policy** — nome
   `Kubernetes - Aula 5` (mantenha "Collect system logs and metrics").
2. Na policy, **Add integration > Kubernetes > Add Kubernetes** — mantenha os
   padrões (métricas de nodes/pods/containers via kubelet, estado via
   kube-state-metrics, logs de containers) e salve na policy.
3. Na policy, **Add agent > Kubernetes** — o Kibana gera o manifesto
   `elastic-agent-managed-kubernetes.yaml` já com `FLEET_ENROLLMENT_TOKEN`
   preenchido. Baixe o arquivo.
4. Edite no manifesto a env `FLEET_URL` para:

```yaml
- name: FLEET_URL
  value: "https://fleet-server:8220"
```

   E, logo abaixo dela, garanta a env de ambiente de estudo:

```yaml
- name: FLEET_INSECURE
  value: "true"
```

5. Aplique e acompanhe (1 pod por node = 3 pods):

```bash
kubectl apply -f elastic-agent-managed-kubernetes.yaml
kubectl -n kube-system get pods -l app=elastic-agent -w
```

6. Em **Fleet > Agents**, os 3 agentes aparecem **Healthy**.

## 9. Como aplicar o workload de exemplo

```bash
kubectl apply -f k8s/app-exemplo.yaml
kubectl get pods -w
```

O `loja-web` fica `Running`; o `pod-problematico` entra em ciclo de
`CrashLoopBackOff` de propósito — é ele que vamos "encontrar" pelo Elastic.

## 10. Como explorar (roteiro da aula)

1. **Infrastructure app**: Observability > Infrastructure > Inventory. Troque
   a visão para **Kubernetes Pods**, agrupe por namespace e localize o
   `pod-problematico`. Clique nele para o drill-down de métricas.
2. **Dashboards curados**: Analytics > Dashboards > busque
   `[Metrics Kubernetes] Cluster Overview` — visão de nodes, pods, CPU,
   memória e **restarts crescendo** no pod problemático.
3. **Discover**: `data_stream.dataset : "kubernetes.container_logs"` mostra os
   logs dos containers do cluster (incluindo o "falhando!" do pod).
4. **Preview ML + Alerting** (escopo introdutório): em Machine Learning, os
   jobs de anomalia sobre métricas; em Observability > Alerts, uma regra de
   threshold sobre `kubernetes.pod.cpu.usage.node.pct`.

## 11. Como parar o ambiente

```bash
k3d cluster stop onp
docker compose stop
```

## 12. Como remover tudo

```bash
k3d cluster delete onp
docker compose down -v
```

## 13. Troubleshooting

- **Agentes Offline no Fleet**: `FLEET_URL` incorreta no manifesto (deve ser
  `https://fleet-server:8220`) ou cluster criado fora da rede `onp-net`
  (delete e recrie com o script).
- **Sem métricas `state_*` (pods/deployments)**: kube-state-metrics ausente —
  requisito oficial. Rode o script do passo 7.
- **Só 1 agente aparece coletando métricas de cluster**: comportamento
  esperado — é o **pod líder** (leader election), documentado pela Elastic.
- **Pods do agente em CrashLoop**: memória insuficiente no host; o manifesto
  oficial permite ajustar `resources.limits` (documentado).
- **`kubectl apply -k github.com/...` falha**: exige kubectl com kustomize
  embutido (1.21+); atualize o kubectl.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Run Elastic Agent on Kubernetes managed by Fleet: https://www.elastic.co/docs/reference/fleet/running-on-kubernetes-managed-by-fleet
- Kubernetes integration: https://docs.elastic.co/integrations/kubernetes
- kube-state-metrics (repositório oficial): https://github.com/kubernetes/kube-state-metrics
- Scaling Elastic Agent on Kubernetes (leader election): https://www.elastic.co/guide/en/fleet/current/scaling-on-kubernetes.html
- k3d: https://k3d.io
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Ambiente de estudo (TLS interno desabilitado, `FLEET_INSECURE=true`).
- k3d simula multi-node em containers — suficiente para a integração e para
  o exame, mas métricas de hardware são as do host Docker.
- Em clusters gerenciados (AKS/GKE/EKS), o agente **não** coleta métricas do
  control plane (kube-scheduler/controller-manager) — limitação documentada
  pela Elastic.
