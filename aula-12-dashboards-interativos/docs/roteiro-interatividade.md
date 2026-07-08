# Roteiro guiado — Dashboards interativos (Aula 12)

Objetivo: um PAR de dashboards conectados sobre `kibana_sample_data_logs`:
o **executivo** (visão geral + controls) navega por clique para o
**operacional** (detalhe), com contexto preservado — e do operacional, um
URL drilldown simula a abertura de ticket num sistema externo.

Time range: **Last 7 days**.

## Parte A — Dashboard operacional (o destino)

1. **Create dashboard** e adicione:
   - Tabela Lens: Rows Top 20 `url.keyword` · Metrics: Count + Average of
     bytes (título: `Detalhe por URL`).
   - Série temporal: `@timestamp` × Count com Break down by
     `response.keyword` (título: `Requisições por status`).
2. Salve como **[ONP] Web Ops — Operacional** (tags `onp`, `interativo`).

## Parte B — Dashboard executivo (a origem)

1. **Create dashboard** e adicione:
   - Metric: Sum of bytes (título: `Volume servido`).
   - Série temporal: Count no tempo (título: `Tráfego`).
   - Barra horizontal: Top 10 `geo.src` (título: `Top países`).
2. Salve como **[ONP] Web Ops — Executivo**.

## Parte C — Controls (filtros para quem CONSOME)

No executivo, em Edit mode:

1. **Add > Controls > Control** (controle fixado no topo):
   - Data view `kibana_sample_data_logs` · Field `geo.src` ·
     Type **Options list** · Label `País de origem` · múltipla seleção.
2. Novo control: Field `bytes` · Type **Range slider** (numéricos
   somente — regra oficial) · Label `Tamanho da resposta`.
3. **Add time slider control** (1 por dashboard; usa o time range global —
   os botões prev/next e o play animam o dado no período).
4. Engrenagem de settings dos controls:
   - **Chain controls**: ON (seleção num control estreita as opções do
     seguinte, da esquerda para a direita — comportamento oficial).
   - **Apply selections automatically**: ON.
   - **Validate user selections**: ON.
5. Salve. Teste: selecione um país e veja TODOS os painéis filtrarem.

## Parte D — Dashboard drilldown (executivo → operacional)

1. No executivo, menu do painel `Top países` > **Create drilldown** >
   **Go to dashboard**.
2. Nome: `Ver detalhe operacional` · Destino: `[ONP] Web Ops — Operacional`.
3. Marque **Use filters and query from origin dashboard** e **Use date
   range from origin dashboard** — é isso que preserva o contexto
   (opções oficiais do dashboard drilldown).
4. Create drilldown > Save.
5. Teste: clique na barra de um país > `Ver detalhe operacional` — o
   operacional abre JÁ filtrado por aquele país, no mesmo período.

## Parte E — URL drilldown (operacional → sistema externo)

1. No operacional, menu do painel `Requisições por status` >
   **Create drilldown > Go to URL**.
2. Nome: `Abrir ticket` · Trigger: **Single click**.
3. URL template (exemplo do padrão oficial de variáveis):

```
https://github.com/elastic/kibana/issues?q=is:issue+{{event.value}}
```

   O Kibana substitui `{{event.value}}` pelo valor clicado. (Num caso
   real, seria a URL do seu Jira/ServiceNow com o campo no template.)
4. Salve o dashboard e teste no painel (orientação oficial: URL drilldown
   deve ser testado após salvar).

## Limitação oficial importante

Drilldowns dependem de um CAMPO REAL da fonte de dados: valores de campos
computados (ES|QL `EVAL`/`STATS`, fórmulas do Lens, resultados de
agregação) **não disparam** drilldown — a opção nem aparece no clique.

## Desafio pós-aula

Crie um **Discover drilldown** no painel de tabela do operacional e
compare: ele leva time range e filtros junto para a investigação crua.
