# Aula 07 — APM com Elastic

Projeto de apoio do **Vídeo 7** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **APM com Elastic** — traces, transações e spans numa aplicação
multisserviço real, com APM Server rodando via **integração APM no Elastic
Agent (Fleet)**, distributed tracing automático e investigação de causa raiz
na APM app (endpoint lento e erro proposital incluídos).

---

## 1. Objetivo do projeto

- Subir o APM Server pelo **fluxo oficial atual**: integração Elastic APM na
  policy do Fleet Server (a doc oficial indica esse caminho como o mais
  simples para começar).
- Instrumentar dois serviços Python (Flask) com o **agente APM oficial**:
  `loja-api` → chama → `pagamento`.
- Ver **distributed tracing** funcionando sem nenhuma configuração extra.
- Investigar na APM app: transação lenta (`/lento`, 2,5s) até o span, e
  exceção agrupada (`/erro`) na aba Errors.

## 2. Arquitetura da solução

```
┌─────────┐  HTTP   ┌───────────┐  HTTP   ┌────────────┐
│ trafego ├────────►│ loja-api  ├────────►│ pagamento  │
└─────────┘         │ (agente   │ trace   │ (agente    │
                    │  APM py)  │ continua│  APM py)   │
                    └─────┬─────┘         └─────┬──────┘
                          │  eventos APM (8200) │
                          ▼                     ▼
                    ┌──────────────────────────────┐
                    │ fleet-server (Elastic Agent)  │
                    │  = APM Server via integração  │
                    └──────────────┬───────────────┘
                                   ▼
                    ┌────────────┐   ┌─────────┐
                    │elasticsearch│◄──┤ kibana  │ (APM app)
                    └────────────┘   └─────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`, `8220`,
`8200`, `5000`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-07-apm-com-elastic
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

Note o `APM_SECRET_TOKEN`: você vai usar **o mesmo valor** na configuração
da integração no Kibana (passo 7). É ele que autoriza os agentes.

## 6. Subindo a base

```bash
docker compose up -d elasticsearch kibana
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

### 6.2 Service token + Fleet Server

```bash
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
# cole em FLEET_SERVER_SERVICE_TOKEN no .env
docker compose up -d fleet-server
```

## 7. Adicionando a integração Elastic APM (o APM Server nasce aqui)

No Kibana:

1. **Integrations > Elastic APM > Add Elastic APM**.
2. **Host** e **URL**: use `0.0.0.0:8200` como host (obrigatório em Docker,
   conforme a doc oficial, para escutar em todas as interfaces).
3. Em **Agent authorization > Secret token**: cole o valor de
   `APM_SECRET_TOKEN` do seu `.env`.
4. Em "Where to add": selecione a policy existente do Fleet Server
   (`Fleet Server policy`). Salve.

Em ~30s o Elastic Agent do fleet-server passa a rodar o APM Server na 8200
(`curl http://localhost:8200` responde com metadados do servidor).

## 8. Subindo a aplicação instrumentada e o tráfego

```bash
docker compose up -d --build pagamento loja-api trafego
```

O agente APM de cada serviço lê `ELASTIC_APM_SERVER_URL`,
`ELASTIC_APM_SECRET_TOKEN`, `ELASTIC_APM_SERVICE_NAME` e
`ELASTIC_APM_ENVIRONMENT` do ambiente. O `trafego` alimenta os 3 endpoints
em loop: `/checkout` (normal, com chamada entre serviços), `/lento` (2,5s) e
`/erro` (exceção proposital).

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
curl http://localhost:5000/checkout
```

## 10. Como investigar (roteiro da aula)

1. **Observability > APM > Services**: `loja-api` e `pagamento` listados com
   latência, throughput e taxa de erro.
2. **Service map**: o mapa mostra `loja-api → pagamento` — desenhado a
   partir dos traces, sem configuração.
3. **Transactions** de `loja-api`: `GET /lento` com ~2,5s de duração. Abra o
   **trace waterfall** e ache o tempo "gasto no próprio serviço" — a causa
   raiz da lentidão.
4. `GET /checkout`: o waterfall mostra o span HTTP e a transação
   **continuando no serviço pagamento** — distributed tracing em ação.
5. **Errors**: a `RuntimeError` do `/erro` agrupada, com stack trace e
   ocorrências ao longo do tempo.
6. **Preview de alerting** (escopo introdutório): APM > Alerts > regra de
   latência sobre `loja-api`.

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **`curl :8200` falha**: a integração APM ainda não foi adicionada à policy
  do Fleet Server (passo 7), ou o host da integração não é `0.0.0.0:8200`.
- **Serviços não aparecem na APM app**: `APM_SECRET_TOKEN` do `.env`
  diferente do secret token configurado na integração — os agentes são
  rejeitados silenciosamente (cheque `docker compose logs loja-api`).
- **Só a loja-api aparece**: confira as envs `ELASTIC_APM_*` do serviço
  `pagamento` no compose.
- **Nomes de serviço "estranhos"**: `ELASTIC_APM_SERVICE_NAME` ausente — o
  agente usa um nome padrão. Nomes de serviço devem ser únicos.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Fleet-managed APM Server: https://www.elastic.co/docs/solutions/observability/apm/apm-server/fleet-managed
- Transactions (conceito, sampling): https://www.elastic.co/docs/solutions/observability/apm/transactions
- Elastic APM agents (Python/Flask e demais): https://www.elastic.co/docs/solutions/observability/apm/apm-agents
- Agente Python (referência): https://www.elastic.co/docs/reference/apm/agents/python
- Docker Compose: https://docs.docker.com/compose/

## Limitações deste exemplo

- Ambiente de estudo (TLS desabilitado, `FLEET_INSECURE=true`).
- Sampling padrão (100%): em produção, ajustar `transaction_sample_rate` —
  tema tratado como boa prática no vídeo.
- Instrumentação com agente Elastic clássico; a alternativa OpenTelemetry
  (inclusive EDOT) é o assunto do **Vídeo 8**.
