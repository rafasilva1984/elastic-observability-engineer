# Aula 04 — Metrics e Infraestrutura

Projeto de apoio do **Vídeo 4** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.
*(Cobre o módulo Metrics do lab oficial — EOE 2.3.)*

Tema: **Métricas de infraestrutura** — um host monitorado pela integração
**System** do Elastic Agent, analisado nas UIs oficiais: **Infrastructure
Inventory** (waffle map), **Hosts** e **Metrics Explorer** — com um pico de
CPU gerado ao vivo e um alerta reagindo a ele.

---

## 1. Objetivo do projeto

- Criar a agent policy `ONP - Hosts` e ver que ela **já nasce com a
  integração System** (logs + métricas do host) — ponto de prova.
- Inscrever um "host" (container com Elastic Agent) via Fleet.
- Navegar Inventory (cor do waffle = CPU), detalhe do host, página Hosts
  (baseada em Lens) e Metrics Explorer (`system.load.*`).
- Gerar um **pico de CPU real** (`scripts/gerar-carga.sh`) e capturá-lo
  com uma **regra de alerta** de threshold.

## 2. Arquitetura da solução

```
┌────────────┐   ┌─────────┐   ┌──────────────┐   enroll   ┌──────────────┐
│elasticsearch│◄──┤ kibana  │◄──┤ fleet-server │◄───────────┤ host-app-onp │
│ metrics-*   │   │ :5601   │   │   :8220      │            │ Elastic Agent│
└────────────┘   └─────────┘   └──────────────┘            │ + System     │
      ▲  Infrastructure UI lê metrics-* (doc oficial)       │ integration  │
      └──────────────────────────────────────────────────── └──────────────┘
                                        scripts/gerar-carga.sh (pico de CPU)
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 6 GB RAM. Portas `9200`, `5601`, `8220`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-04-metrics-infraestrutura
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

## 6. Subindo o ambiente (em camadas)

```bash
docker compose up -d elasticsearch kibana
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i   # senha do .env
docker compose restart kibana
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
# cole o token em FLEET_SERVER_SERVICE_TOKEN no .env
docker compose up -d fleet-server
```

## 7. Policy + host monitorado

Siga `docs/roteiro-metrics.md` (Passo 1): crie a policy `ONP - Hosts`,
copie o **enrollment token** para `HOST_ENROLLMENT_TOKEN` no `.env` e:

```bash
docker compose up -d host-app
```

## 8. Executando a exploração (o coração da aula)

```bash
cat docs/roteiro-metrics.md   # Passos 2–6: Inventory, Hosts, carga, Explorer, alerta
./scripts/gerar-carga.sh      # pico de CPU por 3 min
```

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

Correto: data streams `metrics-system.*` crescendo; `host-app-onp` no
Inventory; waffle esquentando durante a carga.

## 10. Como acessar

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` |
| Elasticsearch | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` |

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **Host não aparece no Inventory**: agente inscreveu? `docker logs
  host-app-onp` deve mostrar "Successfully enrolled"; token errado no
  `.env` é a causa nº 1. Depois, aguarde 1–2 min de coleta.
- **Inventory vazio mas Fleet mostra o agente healthy**: confira se a
  integração System está na policy com **Collect metrics** ligado (a UI
  lê `metrics-*` — doc oficial).
- **Waffle não esquenta na carga**: o intervalo padrão de coleta de CPU é
  10s e o Inventory agrega por janela — espere ~1 min e confira o time
  range (Last 15 minutes).
- **Métricas com nome "legacy"**: comportamento oficial — fórmulas
  antigas viram `legacy` quando a Elastic muda a definição; regras
  antigas continuam funcionando.
- **Fleet Server unhealthy**: service token ausente/errado no `.env`.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Get started with system metrics: https://www.elastic.co/docs/solutions/observability/infra-and-hosts/get-started-with-system-metrics
- Inventory por tipo de recurso (waffle, overlay, Anomaly Explorer): https://www.elastic.co/docs/solutions/observability/infra-and-hosts/view-infrastructure-metrics-by-resource-type
- Analyze infrastructure and host metrics (metrics-*, Hosts/Lens): https://www.elastic.co/docs/solutions/observability/infra-and-hosts/analyze-infrastructure-host-metrics
- Referência de host metrics (fórmulas, legacy): https://www.elastic.co/docs/reference/observability/observability-host-metrics
- Fleet/Elastic Agent em containers: https://www.elastic.co/docs/reference/fleet

## Limitações deste exemplo

- O "host" é um container: as métricas refletem o namespace dele (CPU/mem
  do container) — perfeito para didática; num servidor real, o agente vê
  a máquina toda.
- A visão **Docker containers** do Inventory exige a integração Docker
  (fica como exploração extra — a doc oficial descreve a visão).
- Coleta via EDOT Collector (hostmetrics OTel) é a recomendação mais nova
  da doc para infra — citada no vídeo; o lab usa System integration por
  ser o caminho do exame.
