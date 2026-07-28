# Summary — Lição 2.3 · Metrics Monitoring

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Logs contam o que aconteceu e quando; métricas coletam uma informação periodicamente
- O Elastic Agent coleta múltiplas métricas de sistemas e serviços
- A app de Infrastructure permite visualizar métricas para diagnosticar problemas
- O Inventory filtra por hosts, containers Docker ou pods do Kubernetes monitorados
- O Metrics Explorer cria visualizações de série temporal a partir de agregações
- Métrica é o sinal PREDITIVO: avisa a tendência antes do incidente

## Quiz

1. Verdadeiro ou falso: métricas contêm apenas valores numéricos.
   <details><summary>resposta</summary>

   **Falso.** O valor medido é numérico, mas o documento carrega dimensões/labels (host, container, serviço) que são justamente o que permite agrupar e comparar.
   </details>

2. Verdadeiro ou falso: dá para diagnosticar problemas de infraestrutura pela app de Infrastructure.
   <details><summary>resposta</summary>

   **Verdadeiro.** Inventory para o agora, Hosts para comparar e Metrics Explorer para investigar a série no tempo.
   </details>

3. Verdadeiro ou falso: é possível criar visualizações de métricas pelo Metrics Explorer.
   <details><summary>resposta</summary>

   **Verdadeiro.** Ele monta séries temporais por agregação, com agrupamento — e o resultado pode virar painel.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
