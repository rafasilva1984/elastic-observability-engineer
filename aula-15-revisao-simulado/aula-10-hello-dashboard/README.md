# Aula 10 — Hello Dashboard

Projeto de apoio do **Vídeo 10** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Hello Dashboard** — seu primeiro dashboard do Kibana do zero:
gráficos com o editor **Lens**, contexto com painel **Markdown** e um
**layout polido** — o fluxo essencial para construir qualquer dashboard.

---

## 1. Objetivo do projeto

Construir, de forma guiada, o dashboard **[ONP] Web Logs — Visão
Operacional** sobre o sample data de web logs:

- 1 painel **Markdown** de contexto (pergunta, como ler, dono, runbook).
- 3 visualizações **Lens**: métrica única (Sum of bytes), série temporal
  (requisições no tempo) e barra horizontal (Top 10 países).
- Layout com hierarquia, opções de exibição oficiais e salvamento com
  nomenclatura que se encontra depois.

O passo a passo detalhado da construção está em
**`docs/roteiro-dashboard.md`** (o "lab worksheet" da aula), e o texto do
painel Markdown pronto para colar em **`examples/painel-markdown.md`**.

## 2. Arquitetura da solução

```
┌──────────────┐    ┌───────────┐
│elasticsearch │◄───┤  kibana   │  Dashboards / Lens / Markdown
│ sample data  │    │  :5601    │
└──────────────┘    └───────────┘
        ▲
        └── scripts/carregar-dados.sh (Web Logs, eCommerce, Flights)
```

Sem ingestão, sem agente: o foco é 100% em visualização (escopo do curso
oficial "Hello Dashboard").

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-10-hello-dashboard
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
./scripts/carregar-dados.sh
```

O script instala os 3 datasets oficiais via API do Kibana. Para esta aula,
usaremos o **Sample web logs** (data view `kibana_sample_data_logs`).

## 8. Construindo o dashboard (o coração da aula)

Siga o roteiro guiado de 9 passos:

```bash
cat docs/roteiro-dashboard.md
```

Resumo do fluxo: **Create dashboard** → painel **Markdown** (cole
`examples/painel-markdown.md`) → **Lens Metric** (Sum of bytes) → **Lens
série temporal** (Records por @timestamp) → **Lens Horizontal bar** (Top 10
`geo.src`) → layout em 3 linhas → opções de exibição (margins, panel
titles, sync cursor, store time) → **Save** com título `[ONP] Web Logs —
Visão Operacional` + tags → **Share > Copy link**.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

E no Kibana: **Analytics > Dashboards** deve listar o `[ONP] Web Logs —
Visão Operacional` com os 4 painéis renderizando dados dos últimos 7 dias.

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

- **"No results found" nos painéis**: time range errado — o sample data
  distribui eventos ao redor da data de instalação; use **Last 7 days** e
  ative **Store time with dashboard** ao salvar.
- **Campo não aparece no Lens**: confira se a data view selecionada no
  painel é `kibana_sample_data_logs` (canto superior esquerdo do editor).
- **Editei o Markdown e não mudou em outro dashboard**: o painel foi salvo
  **by value** (só neste dashboard). Para reuso central, use **Save to
  library** (doc oficial de text panels).
- **Perdi o dashboard**: busque pelas **tags** (`onp`, `web-logs`) ou pelo
  prefixo `[ONP]` — é para isso que a convenção de nomes existe.
- **Painéis desalinhados**: arraste pelo cabeçalho do painel; segure o
  canto inferior direito para redimensionar; margens ligadas ajudam.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Create a dashboard (fluxo, opções de exibição, título/tags): https://www.elastic.co/docs/explore-analyze/dashboards/create-dashboard
- Text panels (Markdown + Visualize Library): https://www.elastic.co/docs/explore-analyze/visualize/text-panels
- Lens (drag-and-drop, sugestões): https://www.elastic.co/docs/explore-analyze/visualize/lens
- Tutorial oficial com sample data: https://www.elastic.co/docs/explore-analyze/kibana-data-exploration-learning-tutorial
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Sample data (não há ingestão real): perfeito para o escopo do curso
  oficial, que é o fluxo de construção.
- Tipos avançados de visualização (heat map, breakdowns múltiplos, tabelas)
  são o assunto do **Vídeo 11**; controls e drilldowns, do **Vídeo 12**.
