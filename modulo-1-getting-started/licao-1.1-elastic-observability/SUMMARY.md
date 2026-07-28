# Summary — Lição 1.1 · Elastic Observability

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Observabilidade é um ATRIBUTO do sistema: quanto do estado interno dá para entender pelos sinais externos
- Ela ajuda a detectar comportamentos indesejados e a chegar na causa raiz rápido
- Não é só uptime: uptime responde "está no ar?", observabilidade responde "por que está assim?"
- Não é tecnologia nova: o que mudou foi a complexidade que a tornou obrigatória
- Os três sinais se complementam: log = o que aconteceu, métrica = quanto e a tendência, trace = onde no fluxo
- A Elastic entrega uma implementação unificada: mesma plataforma para coletar, armazenar, analisar e alertar

## Quiz

1. Verdadeiro ou falso: observabilidade é só monitorar disponibilidade.
   <details><summary>resposta</summary>

   **Falso.** Disponibilidade (uptime) é uma parte pequena. Observabilidade é conseguir responder perguntas novas sobre o comportamento interno do sistema — inclusive as que você não previu ao instrumentar.
   </details>

2. Verdadeiro ou falso: observabilidade é uma tecnologia nova.
   <details><summary>resposta</summary>

   **Falso.** O conceito vem da teoria de controle. O que é recente é a NECESSIDADE, empurrada por arquiteturas distribuídas e efêmeras.
   </details>

3. Verdadeiro ou falso: a Elastic entrega uma solução unificada de observabilidade e alertas.
   <details><summary>resposta</summary>

   **Verdadeiro.** Logs, métricas, traces, uptime e alertas na mesma plataforma — e é isso que evita o war room com quatro ferramentas discordando.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
