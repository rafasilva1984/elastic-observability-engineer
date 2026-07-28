# Summary — Lição 5.2 · Custom ML jobs

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- O Elastic ML tem assistentes para single metric, multi-metric, population, advanced, categorization, rare e geo
- Um job single metric usa um único detector para definir o tipo de análise e o campo analisado
- Um job multi-metric pode usar mais de um detector e é mais eficiente que rodar vários jobs sobre o mesmo dado
- O split divide a análise por campo; os influencers apontam quem contribuiu para a anomalia
- Population compara a entidade com as demais — ideal para 'quem está fora do padrão do grupo'
- Primeiro a pergunta, depois o tipo de job. O contrário gera modelo bonito e inútil

## Quiz

1. Verdadeiro ou falso: um job multi-metric pode encontrar anomalias em campos que parecem não relacionados.
   <details><summary>resposta</summary>

   **Verdadeiro.** Ele analisa múltiplos detectores sobre o mesmo dado e correlaciona os resultados — inclusive revelando relações que ninguém suspeitava.
   </details>

2. Verdadeiro ou falso: o detector de um job single-metric define o tipo de análise sobre um único KPI.
   <details><summary>resposta</summary>

   **Verdadeiro.** Detector = função (count, sum, mean…) + campo. Um detector, um KPI.
   </details>

3. Verdadeiro ou falso: um job de categorization detecta atividade incomum em mensagens de log.
   <details><summary>resposta</summary>

   **Verdadeiro.** Ele agrupa mensagens semelhantes em categorias e sinaliza quando surge (ou some) um padrão — funciona justamente onde o dado não está estruturado.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
