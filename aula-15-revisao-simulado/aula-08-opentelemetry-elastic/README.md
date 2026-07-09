# Aula 08 — OpenTelemetry com Elastic

Projeto de apoio do **Vídeo 8** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Coletando dados de aplicação com OpenTelemetry** — microsserviços em
**duas linguagens** (Node e Python) com auto-instrumentação OTel, um
**OTel Collector** no meio (receivers → processors → exporters) e o
**APM Server do Elastic recebendo OTLP nativamente**.

---

## 1. Objetivo do projeto

- Instrumentar dois serviços com OTel **sem alterar código** (auto-instrumentação
  por env/comando): `vitrine` (Node, OTLP/HTTP) → `catalogo` (Python, OTLP/gRPC).
- Subir um **OTel Collector contrib** com a config oficial recomendada pela
  Elastic: receiver `otlp`, processors `memory_limiter` + `batch`, exporter
  `otlp/elastic` com `Authorization: Bearer <secret token>`.
- Ver **um único trace atravessando as duas linguagens** na APM app.
- Verificar a configuração dos agentes entre linguagens (objetivo literal do
  curso oficial).

## 2. Arquitetura da solução

```
┌─────────┐   ┌──────────────┐  HTTP  ┌───────────────┐
│ trafego ├──►│ vitrine (Node)├──────►│catalogo(Python)│
└─────────┘   │ auto-instr.  │ trace  │ auto-instr.    │
              └──────┬───────┘ cont.  └──────┬─────────┘
              OTLP/HTTP :4318          OTLP/gRPC :4317
                     └────────┬───────────────┘
                        ┌─────▼─────────┐
                        │ otel-collector │ receivers→processors→exporters
                        └─────┬─────────┘
                     OTLP (Bearer secret token)
                        ┌─────▼─────────┐    ┌────────────┐   ┌────────┐
                        │ fleet-server   │───►│elasticsearch│◄──┤ kibana │
                        │ (APM Server)   │    └────────────┘   └────────┘
                        └────────────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`, `8220`,
`8200`, `4317`, `4318`, `5003`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-08-opentelemetry-elastic
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

`APM_SECRET_TOKEN` deve ser **o mesmo** configurado na integração APM no
Kibana (passo 7): é ele que o Collector envia como `Bearer`.

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
# Cria a policy do Fleet Server no Kibana (obrigatório no 9.x — sem isso o
# Fleet Server fica preso em "Waiting on policy"). Rode ANTES de subir o Fleet:
./scripts/setup-fleet.sh
```

Em seguida, suba o Fleet Server:

```bash
docker compose up -d fleet-server
```

## 7. Integração Elastic APM (o receptor OTLP)

No Kibana: **Integrations > Elastic APM > Add** — host `0.0.0.0:8200`,
**Secret token = APM_SECRET_TOKEN do .env**, na policy do Fleet Server
(idêntico ao Vídeo 7). O APM Server resultante **aceita OTLP nativamente**.

## 8. Subindo Collector, serviços e tráfego

```bash
docker compose up -d --build otel-collector catalogo vitrine trafego
```

O que acontece:
- `otel-collector` carrega `config/otel-collector.yml` e escuta 4317 (gRPC)
  e 4318 (HTTP).
- `catalogo` (Python) roda com `opentelemetry-instrument` e exporta via
  **gRPC → 4317**.
- `vitrine` (Node) roda com `--require @opentelemetry/auto-instrumentations-node/register`
  e exporta via **HTTP → 4318**.
- Ambos configurados 100% por env: `OTEL_SERVICE_NAME`,
  `OTEL_RESOURCE_ATTRIBUTES`, `OTEL_EXPORTER_OTLP_ENDPOINT`.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
curl http://localhost:5003/produtos
```

## 10. Como explorar (roteiro da aula)

1. **APM > Services**: `vitrine` e `catalogo` listados — repare no ícone/
   metadado da linguagem de cada um (Node vs Python).
2. Abra uma transação `GET /produtos` da vitrine: o **waterfall mostra o
   trace atravessando as duas linguagens** — Node chama, Python continua.
3. **Verificação entre linguagens** (objetivo do curso oficial): nos
   metadados do serviço, confira `service.name`, `service.version` e
   `deployment.environment` vindos de `OTEL_RESOURCE_ATTRIBUTES` — iguais
   nos dois serviços, definidos do mesmo jeito, em linguagens diferentes.
4. **Collector em ação**: `docker compose logs -f otel-collector` mostra o
   exporter `debug` confirmando spans recebidos/exportados.

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **Serviços não aparecem na APM app**: token divergente entre `.env` e a
  integração (Collector recebe `401` do APM Server — veja
  `docker compose logs otel-collector`).
- **Collector reinicia**: erro de sintaxe no `otel-collector.yml` — YAML é
  sensível a indentação; valide o arquivo.
- **`vitrine` sem traces**: a env `OTEL_EXPORTER_OTLP_ENDPOINT` do Node
  aponta para **4318 (HTTP)**; a do Python para **4317 (gRPC)**. Trocar as
  portas entre eles é o erro clássico.
- **`service.name` como "unknown_service"**: `OTEL_SERVICE_NAME` ausente.
- **APM Server 8200 mudo**: integração APM não adicionada (passo 7) ou host
  sem `0.0.0.0`.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Use OpenTelemetry with Elastic APM (visão geral + EDOT): https://www.elastic.co/docs/solutions/observability/apm/opentelemetry
- Contrib OTel Collectors/SDKs → Elastic (exporter otlp/elastic, Bearer, processors recomendados): https://www.elastic.co/docs/solutions/observability/apm/opentelemetry/upstream-opentelemetry-collectors-language-sdks
- Collector configuration (receivers/processors/exporters/pipelines): https://opentelemetry.io/docs/collector/configuration/
- OTel Collector contrib (imagem): https://github.com/open-telemetry/opentelemetry-collector-contrib

## Limitações deste exemplo

- Ambiente de estudo (TLS desabilitado, `tls.insecure: true` no exporter).
- Usamos o Collector **contrib** para ensinar o padrão vendor-neutral; a
  doc oficial sinaliza que contrib tem **suporte de comunidade** — a
  distribuição com suporte da Elastic é o **EDOT** (mencionado no vídeo).
- Logs OTel desabilitados no lab (`OTEL_LOGS_EXPORTER=none`) para manter o
  foco em traces/métricas, escopo do curso oficial.
