# Aula 03 — Logs com Elastic Observability

Projeto de apoio do **Vídeo 3** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Logs com Elastic Observability** — coletar logs de uma aplicação com
Elastic Agent + Fleet usando a integração **Custom Logs (Filestream)**,
explorar no **Discover** e usar **dashboards curados** de integração.

> Ponto de atenção (fonte oficial): a integração "Custom Logs" clássica está
> **deprecated**; a atual é a **Custom Logs (Filestream)**. Este projeto usa a
> versão atual.

---

## 1. Objetivo do projeto

Praticar o fluxo completo de logging do Elastic Observability:

- Subir uma aplicação de exemplo que gera logs realistas (INFO/WARN/ERROR).
- Coletar esses logs com Elastic Agent gerenciado por Fleet, via integração
  Custom Logs (Filestream).
- Entender data streams (`logs-<dataset>-<namespace>`).
- Explorar e filtrar no Discover com KQL.
- Conhecer os dashboards curados que as integrações trazem prontos.

## 2. Arquitetura da solução

```
┌──────────────┐  escreve   ┌─────────────────┐
│ app-gerador  ├───────────►│ volume app-logs │
└──────────────┘            └────────┬────────┘
                                     │ lê (filestream)
                            ┌────────▼────────┐
                            │    log-agent    │ (Elastic Agent)
                            └────────┬────────┘
                                     │ enrolla via
        ┌───────────────┐   ┌────────▼────────┐   ┌───────────┐
        │ elasticsearch │◄──┤   fleet-server   │   │  kibana   │
        │ logs-app_...  │   └──────────────────┘   │ (Discover)│
        └───────▲───────┘                          └─────┬─────┘
                └────────────────── lê ──────────────────┘
```

## 3. Pré-requisitos

- Docker Engine 24+ e Docker Compose v2.20+ (`docker compose version`).
- Pelo menos 4 GB de RAM livres.
- Portas livres: `9200`, `5601`, `8220`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-03-logs-elastic-observability
```

## 5. Como configurar as variáveis de ambiente

```bash
cp .env.example .env
```

Deixe `FLEET_SERVER_SERVICE_TOKEN` e `AGENT_ENROLLMENT_TOKEN` em branco por
enquanto — serão preenchidos nos passos 6.2 e 7.

## 6. Como subir a base do ambiente

```bash
docker compose up -d elasticsearch kibana app-gerador
```

Aguarde `elasticsearch` e `kibana` ficarem `healthy` (`docker compose ps`).
O `app-gerador` já começa a escrever logs em `/var/log/app/app.log`
(volume compartilhado).

### 6.1 Definindo a senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
```

Cole a senha `KIBANA_PASSWORD` do seu `.env` e reinicie o Kibana:

```bash
docker compose restart kibana
```

### 6.2 Gerando o service token do Fleet Server

```bash
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
```

Copie o token para `FLEET_SERVER_SERVICE_TOKEN` no `.env` e suba o Fleet:

```bash
docker compose up -d fleet-server
```

## 7. Como criar a policy de logs e enrolar o agente

No Kibana (http://localhost:5601):

1. **Management > Fleet > Agent policies > Create agent policy**.
   Nome: `Logs - Aula 3`. Mantenha **"Collect system logs and metrics"
   marcado** — é a integração System, que traz dashboards curados prontos
   (vamos usá-los no passo 10).
2. Abra a policy criada > **Add integration** > busque **Custom Logs
   (Filestream)** > **Add Custom Logs (Filestream)**.
3. Configure:
   - **Log file path**: `/var/log/app/app.log`
   - **Dataset name**: `app_exemplo`
   - Em "Where to add", confirme a policy `Logs - Aula 3`. Salve.
4. Na policy, clique **Add agent** e copie o **enrollment token**.
5. Cole o token em `AGENT_ENROLLMENT_TOKEN` no `.env` e suba o agente:

```bash
docker compose --profile agent up -d log-agent
```

6. Em **Fleet > Agents**, o `log-agent-onp` deve aparecer como **Healthy**.

## 8. Como validar se os serviços estão funcionando

```bash
./scripts/validar-ambiente.sh
```

Com tudo certo, o passo 6 do script mostra o contador do data stream
`logs-app_exemplo-*` crescendo.

## 9. Como acessar as interfaces

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |
| Elasticsearch (API) | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |
| Fleet Server (API interna) | https://localhost:8220 | - | - |

## 10. Como explorar os logs (roteiro da aula)

1. **Discover**: selecione a data view de logs, ajuste o time range para
   "Last 15 minutes" e filtre com KQL:
   - `data_stream.dataset : "app_exemplo"` — só os logs da nossa app.
   - `data_stream.dataset : "app_exemplo" and message : *ERROR*` — só erros.
2. **Data stream**: em **Stack Management > Index Management > Data Streams**,
   localize `logs-app_exemplo-default` e observe o padrão
   `logs-<dataset>-<namespace>`.
3. **Dashboards curados**: em **Analytics > Dashboards**, busque `[Metrics
   System]` — dashboards prontos entregues pela integração System, sem você
   montar nada. É esse o valor das integrações nomeadas.
4. **Simular pico de erros**: pare e suba o gerador para observar o
   comportamento no Discover:

```bash
docker compose restart app-gerador
```

## 11. Como parar o ambiente

```bash
docker compose --profile agent stop
```

## 12. Como remover containers e volumes

```bash
docker compose --profile agent down -v
```

O `-v` apaga `es-data` e `app-logs`. Use sem `-v` para manter os dados.

## 13. Troubleshooting

- **Agente Healthy mas nada no Discover**: confira o **Log file path** na
  integração (`/var/log/app/app.log`) e se o volume `app-logs` está montado
  no `log-agent` (está, por padrão, neste compose). Confira também o time
  range do Discover.
- **Data stream não aparece**: o dataset name define o nome — com
  `app_exemplo`, o stream é `logs-app_exemplo-default`. Verifique em Index
  Management > Data Streams.
- **Agente não conecta**: `AGENT_ENROLLMENT_TOKEN` deve ser o token da
  policy `Logs - Aula 3`, não o service token do Fleet Server.
- **Fleet Server não sobe**: token não gerado/colado (passo 6.2) ou `.env`
  não recarregado (`docker compose up -d fleet-server` de novo).
- **Elasticsearch reiniciando**: memória insuficiente ou `vm.max_map_count`
  baixo (`sudo sysctl -w vm.max_map_count=262144`).
- **`--profile` não reconhecido**: exige Docker Compose v2.20+.

## 14. Referências oficiais

- Stream any log file (Elastic Agent): https://www.elastic.co/docs/solutions/observability/logs/stream-any-log-file
- Fleet and Elastic Agent overview: https://www.elastic.co/docs/reference/fleet
- Custom Logs (Filestream) integration: https://docs.elastic.co/integrations/filestream
- Custom Logs (deprecated — por que não usamos): https://docs.elastic.co/integrations/log
- Discover (explorar dados): https://www.elastic.co/docs/explore-analyze/discover/discover-get-started
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Ambiente de estudo (TLS interno desabilitado, single-node, `FLEET_INSECURE=true`).
- O parsing dos campos do log (service, duration_ms) fica proposital para a
  **Aula 6 (Ingest Pipelines)** — aqui o log entra como `message` bruto.
- Dashboards curados demonstrados via integração System; integrações nomeadas
  (Nginx, PostgreSQL etc.) seguem o mesmo princípio.
