# Summary — Lição 5.1 · Machine Learning

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Muito dado de observabilidade fica sem uso porque não há observadores suficientes para olhar tudo
- Machine Learning aproveita esse dado que ninguém olha
- O ML usa dados históricos para definir o comportamento normal
- O ML usa o passado para sugerir o futuro (forecast)
- Em análise de população, o ML compara uma entidade com as demais
- O score é normalizado de 0 a 100 e existe em três níveis: bucket, influencer e record

## Quiz

1. Verdadeiro ou falso: dá para criar jobs de ML direto das apps de Observability.
   <details><summary>resposta</summary>

   **Verdadeiro.** Várias telas (Logs, Infrastructure, APM) oferecem a criação de jobs no contexto do dado que você está olhando.
   </details>

2. Quais são as duas coisas que o machine learning faz com as anomalias?
   <details><summary>resposta</summary>

   **Detecta** (identifica o desvio em relação ao modelo do normal) e **pontua** (atribui um score de severidade, permitindo priorizar e alertar).
   </details>

3. Verdadeiro ou falso: o Machine Learning pode ser usado para previsão.
   <details><summary>resposta</summary>

   **Verdadeiro.** O Forecast projeta o comportamento futuro a partir do modelo aprendido — útil para capacidade e planejamento.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
