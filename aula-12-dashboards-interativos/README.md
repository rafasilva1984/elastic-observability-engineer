# Aula 12 — Dashboards Interativos

Projeto de apoio do **Vídeo 12** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Dashboards Interativos** — controls (Options list, Range slider,
Time slider) para quem **consome** filtrar sem editar, e drilldowns
(Dashboard, URL e Discover) para navegar por clique **preservando o
contexto** — no padrão executivo → operacional.

---

## 1. Objetivo do projeto

Construir, de forma guiada, um **par de dashboards conectados** sobre o
sample data de web logs:

- **[ONP] Web Ops — Executivo**: visão geral (KPI, tráfego, top países)
  com **3 controls** (dropdown de país, range slider de bytes, time
  slider) e **chain controls** ligado.
- **[ONP] Web Ops — Operacional**: detalhe (tabela por URL, série por
  status) — alcançado por **dashboard drilldown** com filtros e período
  herdados da origem.
- **URL drilldown** no operacional simulando a abertura de um ticket em
  sistema externo via template com `{{event.value}}`.

O passo a passo completo está em **`docs/roteiro-interatividade.md`**.

## 2. Arquitetura da solução

```
┌──────────────────────────────┐   dashboard drilldown    ┌──────────────────────────────┐
│ [ONP] Web Ops — Executivo    │  (filtros + período vão  │ [ONP] Web Ops — Operacional  │
│ controls: país · bytes · time│ ────── junto ──────────► │ tabela por URL · série/status│
│ KPI · tráfego · top países   │                          │        │ URL drilldown        │
└──────────────────────────────┘                          └────────┼─────────────────────┘
                                                                   ▼
                                                    sistema externo ({{event.value}})
┌──────────────┐    ┌───────────┐
│elasticsearch │◄───┤  kibana   │  (sample data kibana_sample_data_logs)
└──────────────┘    └───────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-12-dashboards-interativos
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

## 6. Subindo o ambiente

```bash
docker compose up -d
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

## 7. Carregando o sample data

```bash
./scripts/carregar-sample-data.sh
```

## 8. Construindo a interatividade (o coração da aula)

```bash
cat docs/roteiro-interatividade.md
```

Ordem das 5 partes: **A** operacional (o destino) → **B** executivo (a
origem) → **C** controls + settings (chain/apply/validate) → **D**
dashboard drilldown com contexto → **E** URL drilldown com template.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

Validação funcional (a que importa): no executivo, selecione um país no
control → todos os painéis filtram; clique numa barra > `Ver detalhe
operacional` → o operacional abre **já filtrado** por aquele país e no
mesmo período; no operacional, clique num status > `Abrir ticket` → a URL
externa abre com o valor clicado no lugar de `{{event.value}}`.

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

- **Range slider não aceita o campo**: Range sliders são para campos
  **numéricos** apenas (regra oficial) — para `geo.src` use Options list.
- **Drilldown chegou "vazio" no destino**: faltou marcar **Use filters and
  query from origin dashboard** / **Use date range from origin dashboard**
  na configuração do dashboard drilldown.
- **Opção de drilldown não aparece no clique**: o valor vem de campo
  computado (fórmula Lens, ES|QL EVAL/STATS, agregação) — limitação
  documentada: drilldowns exigem campo real da fonte.
- **URL drilldown abre errado**: variável incompatível com o trigger
  (Single click usa `{{event.value}}`; Range selection usa
  `{{event.from}}`/`{{event.to}}`). E teste sempre **após salvar** o
  dashboard (orientação oficial).
- **Control não estreita o outro**: **Chain controls** desligado, ou a
  ordem está invertida — o encadeamento é da esquerda para a direita.
- **Time slider "não funciona"**: ele depende do time range global
  (desligar "Apply global time range to controls" o quebra — comportamento
  documentado).
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Add filter controls (tipos, settings, chaining): https://www.elastic.co/guide/en/kibana/current/add-controls.html
- Add drilldowns (Dashboard, URL, Discover; variáveis; limitações): https://www.elastic.co/docs/explore-analyze/dashboards/drilldowns
- Create a dashboard: https://www.elastic.co/docs/explore-analyze/dashboards/create-dashboard
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Sample data (sem ingestão real): o foco é interatividade.
- A URL do drilldown externo usa um repositório público como alvo didático;
  em produção, aponte para seu Jira/ServiceNow/runbook com as variáveis de
  contexto adequadas.
- O compose usa licença **trial** (`xpack.license.self_generated.type=trial`)
  para garantir todos os recursos em ambiente de estudo.
