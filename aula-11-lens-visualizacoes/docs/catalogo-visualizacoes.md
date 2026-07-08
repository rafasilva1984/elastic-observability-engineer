# Catálogo guiado — 6 visualizações sobre os MESMOS dados (Aula 11)

Data view: `kibana_sample_data_logs` · Time range: **Last 7 days**
Crie cada visualização num dashboard de rascunho: **[ONP] Catálogo Lens**.

A lógica do catálogo: a PERGUNTA define o gráfico. Para cada item, anote a
pergunta que ele responde — é o critério que a prova e a vida real cobram.

## 1. Barra vertical — "Quais categorias dominam?"
- Create visualization > arraste `extension.keyword`.
- Tipo **Bar vertical**; eixo vertical: Count of records.
- Uso: comparação entre poucas categorias com rótulos curtos.

## 2. Barra horizontal — "Qual o ranking (com nomes longos)?"
- Arraste `geo.src` > tipo **Bar horizontal** > Top 10 values.
- Uso: rankings/Top N; rótulos longos ficam legíveis na horizontal.

## 3. Barra empilhada com breakdown — "Como o todo se divide no tempo?"
- Arraste `@timestamp` (eixo X) > eixo vertical Count > **Break down by**
  `response.keyword` > tipo **Bar vertical stacked**.
- Uso: parte-de-um-todo evoluindo no tempo (tráfego total × códigos HTTP).
- Doc oficial de bar charts: breakdown cria séries empilhadas ou agrupadas.

## 4. Heat map — "Onde está a densidade?"
- Tipo **Heat map** (dropdown de tipos).
- **Horizontal axis**: `@timestamp` (date histogram).
- **Vertical axis**: Top values de `geo.src`.
- **Cell value**: Count of records.
- Uso: padrões em duas dimensões de uma vez (quando × onde). A cor é a
  intensidade — bom para enxergar picos que a barra esconde.
- Bônus (doc oficial): Cell value > Color palette > **Custom** para faixas
  de cor próprias (destacar outliers).

## 5. Métrica com tendência — "Qual o número agora — e pra onde ele vai?"
- Tipo **Metric** > Primary metric: **Sum of bytes**.
- Adicione **Secondary metric** como comparação/tendência (doc oficial de
  metric charts) e experimente **dynamic coloring**.
- Uso: KPI de topo de dashboard; o secundário responde "melhorou ou piorou?".

## 6. Tabela — "Quais são os casos exatos?"
- Tipo **Table** > Rows: Top values de `url.keyword` (ou `clientip`) >
  Metrics: Count + Average of bytes.
- Uso: detalhe operacional, valores exatos, auditoria. Quando o número
  preciso importa mais que a forma.

## Anti-padrões (para mostrar no vídeo)
1. **Pizza com 15+ fatias**: vira confete — use barra horizontal Top N.
2. **Arco-íris sem significado**: cor deve carregar informação (doc oficial:
   color mapping atribui cor a TERMOS específicos — use com intenção).
3. **Muitas séries no breakdown**: acima de ~7, o gráfico vira ruído; use
   Top N + "Other".

## Tabela de decisão (cola para a prova)
| Pergunta | Gráfico |
|---|---|
| Comparar categorias | Barra vertical |
| Ranking / nomes longos | Barra horizontal |
| Evolução no tempo | Linha / Área |
| Parte-de-todo no tempo | Barra empilhada (breakdown) |
| Densidade em 2 dimensões | Heat map |
| Número-resumo (KPI) | Metric (+ secondary) |
| Valores exatos / detalhe | Tabela |
