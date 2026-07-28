# Summary — Lição B · Dashboards interativos

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Controls devolvem autonomia ao consumidor do painel
- Range slider só funciona em campo numérico
- Time slider: apenas um por dashboard
- Drilldown com 'use filters from origin' preserva o contexto da investigação
- Drilldown de URL fecha o ciclo alerta → investigação → ação
- Painel que não leva a uma ação é relatório, não ferramenta de operação

## Quiz

1. Em que tipo de campo o Range slider funciona?
   <details><summary>resposta</summary>

   Apenas em campos **numéricos**. Em keyword ele nem aparece como opção — pegadinha clássica.
   </details>

2. O que 'use filters and query from origin' faz num drilldown?
   <details><summary>resposta</summary>

   Leva os filtros e a query do dashboard de origem para o de destino, preservando o contexto — sem isso o destino abre 'do zero' e a investigação se perde.
   </details>

3. Qual o limite de Time slider por dashboard?
   <details><summary>resposta</summary>

   **Um.** Ele controla a janela temporal do painel inteiro, então mais de um não faria sentido.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
