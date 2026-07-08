# Aula 11 — Visualizações com Lens

Projeto de apoio do **Vídeo 11** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Criando Visualizações com Lens** — o repertório completo de
gráficos (barras vertical/horizontal, empilhada com breakdown, heat map,
métrica com tendência e tabela) e, mais importante, **o critério para
escolher o gráfico certo para cada pergunta**.

---

## 1. Objetivo do projeto

Construir um **catálogo de 6 visualizações sobre os MESMOS dados**
(`kibana_sample_data_logs`), cada uma respondendo um tipo de pergunta:

| # | Visualização | Pergunta que responde |
|---|---|---|
| 1 | Barra vertical | Quais categorias dominam? |
| 2 | Barra horizontal (Top 10) | Qual o ranking? |
| 3 | Barra empilhada + breakdown | Como o todo se divide no tempo? |
| 4 | Heat map | Onde está a densidade (2 dimensões)? |
| 5 | Metric + secondary | Qual o número — e pra onde ele vai? |
| 6 | Tabela | Quais são os casos exatos? |

O passo a passo completo está em **`docs/catalogo-visualizacoes.md`**,
incluindo os **anti-padrões** demonstrados no vídeo e a **tabela de
decisão** pergunta→gráfico.

## 2. Arquitetura da solução

```
┌──────────────┐    ┌───────────┐
│elasticsearch │◄───┤  kibana   │  Lens: 6 tipos sobre o mesmo dataset
│ sample data  │    │  :5601    │  Dashboard rascunho: [ONP] Catálogo Lens
└──────────────┘    └───────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-11-lens-visualizacoes
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

## 8. Construindo o catálogo (o coração da aula)

```bash
cat docs/catalogo-visualizacoes.md
```

Crie um dashboard de rascunho (`[ONP] Catálogo Lens`) e construa as 6
visualizações na ordem do catálogo — cada uma anotando a **pergunta** que
ela responde. No fim, você terá o repertório e o critério.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

E no Kibana: o dashboard `[ONP] Catálogo Lens` com as 6 visualizações
renderizando dados dos últimos 7 dias.

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

- **Heat map vazio**: confira se os dois eixos têm dados no time range
  atual (orientação da doc oficial de heat maps) — quase sempre é o
  intervalo curto.
- **Breakdown virou ruído**: reduza para Top 5–7 valores; o excesso de
  séries é anti-padrão, não limitação.
- **Secondary metric não aparece**: ela é configurada dentro do painel da
  Primary metric (doc oficial de metric charts) — não é uma segunda camada.
- **Cores mudando sozinhas**: sem color mapping, a paleta é automática por
  série; para cor fixa por termo, use **Color by value** (doc oficial do
  Lens).
- **Gráfico lento em dataset grande**: use o **Sampling** nas layer
  settings (doc oficial: melhora tempo de carga trocando precisão).
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Lens (tipos, Suggestions, color mapping, sampling): https://www.elastic.co/docs/explore-analyze/visualize/lens
- Build bar charts (breakdown, stacked/grouped): https://www.elastic.co/docs/explore-analyze/visualize/charts/bar-charts
- Build heat map charts (axes, cell value, custom colors): https://www.elastic.co/docs/explore-analyze/visualize/charts/heat-map-charts
- Build metric charts (secondary metric, dynamic coloring): https://www.elastic.co/docs/explore-analyze/visualize/charts/metric-charts
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Sample data (sem ingestão): o foco é repertório visual e critério.
- Maps e Canvas não entram aqui (preview no Vídeo 1; fora do escopo do
  curso oficial "Create Visualizations").
- Interatividade (controls/drilldowns) é o **Vídeo 12**.
