# Summary — Lição 3.1 · Applications (APM)

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Elastic APM é um sistema de monitoração de performance construído sobre o Elastic Stack
- Permite monitorar serviços e aplicações em tempo real
- O Applications UI dá a visão de saúde e performance da aplicação
- Trace distribuído permite analisar a performance ao longo de toda a arquitetura de microsserviços, numa visão só
- O Service map é a representação visual, em tempo real, dos serviços instrumentados
- Trace transforma discussão em fato: o tempo aparece onde ele realmente está

## Quiz

1. Verdadeiro ou falso: dá para visualizar a arquitetura da aplicação pelo Service map.
   <details><summary>resposta</summary>

   **Verdadeiro.** E o melhor: ele é desenhado a partir do tráfego real instrumentado, não de um diagrama que alguém desenhou e esqueceu de atualizar.
   </details>

2. Verdadeiro ou falso: a app de APM fornece as mesmas métricas de host que a integração System.
   <details><summary>resposta</summary>

   **Falso.** APM traz métricas de APLICAÇÃO (latência, throughput, erro). Métricas de host vêm da integração System — os dois se encontram na investigação, mas a origem é diferente.
   </details>

3. Verdadeiro ou falso: é possível achar requisições lentas analisando traces no APM.
   <details><summary>resposta</summary>

   **Verdadeiro.** É exatamente para isso que serve o waterfall: ele mostra onde o tempo foi gasto dentro da requisição.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
