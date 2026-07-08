# Roteiro guiado — construindo o "Hello Dashboard" (Aula 10)

Dashboard final: **[ONP] Web Logs — Visão Operacional**
Data view: `kibana_sample_data_logs` · Time range: **Last 7 days**

## Passo 0 — Preparar
- Ambiente no ar (`docker compose up -d`) e sample data carregado
  (`./scripts/carregar-sample-data.sh`).

## Passo 1 — Criar o dashboard
- Menu > **Dashboards > Create dashboard** (você entra em modo de edição
  automaticamente — comportamento oficial).

## Passo 2 — Painel de contexto (Markdown)
- **Add panel > Markdown/Text** > cole o conteúdo de
  `examples/painel-markdown.md` > Apply.
- Bônus (doc oficial): menu do painel > **Save to library** para reusar este
  Markdown em outros dashboards (edições refletem em todos).

## Passo 3 — Métrica única (KPI)
- **Create visualization** (abre o Lens).
- Arraste `bytes` para o workspace > mude o tipo para **Metric** >
  função **Sum of bytes**.
- Título do painel: `Total de bytes servidos`. **Save and return**.

## Passo 4 — Série temporal
- **Create visualization** > arraste `@timestamp` (eixo X). O Lens sugere a
  contagem de registros no tempo (Records). Tipo: **Area** ou **Line**.
- Título: `Requisições ao longo do tempo`. Save and return.

## Passo 5 — Top N (barra horizontal)
- **Create visualization** > arraste `geo.src` > tipo **Horizontal bar** >
  em Breakdown/Vertical axis, **Top 10 values of geo.src**.
- Título: `Top 10 países de origem`. Save and return.

## Passo 6 — Layout com hierarquia
- Linha 1: Markdown (esquerda, ~2/3) + Métrica (direita, ~1/3).
- Linha 2: Série temporal em largura total.
- Linha 3: Top 10 países.
- Arraste pelo cabeçalho para mover; canto inferior direito para
  redimensionar.

## Passo 7 — Opções de exibição (doc oficial de criação de dashboard)
- Engrenagem/Settings do dashboard:
  - **Use margins between panels**: ON
  - **Show panel titles**: ON
  - **Sync cursor across panels**: ON (o cursor acompanha nas séries)
  - **Store time with dashboard**: ON (salva o Last 7 days junto)

## Passo 8 — Salvar com nome que se encontra
- **Save** > Título: `[ONP] Web Logs — Visão Operacional`
- Description: pergunta que o painel responde + dono.
- Tags: `onp`, `web-logs` (facilitam a busca — recomendação da doc:
  título/descrição/tags ajudam a localizar depois).

## Passo 9 — Compartilhar
- **Share > Copy link** e envie ao time. Filtros e time range acompanham.

## Desafio pós-aula
- Adicione um filtro fixado `response >= 400` num painel duplicado da série
  temporal e compare "tráfego total × só erros" lado a lado.
