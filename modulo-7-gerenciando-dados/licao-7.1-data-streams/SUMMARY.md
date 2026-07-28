# Summary — Lição 7.1 · Data streams

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- O Elastic Agent usa data streams para armazenar dados no Elasticsearch
- Um data stream é uma coleção de índices de apoio atrás de um alias
- Todos os índices de apoio compartilham o mesmo template (index templates)
- Data stream é projetado para dado escrito uma vez e nunca atualizado
- Os data streams criados pelo Elastic Agent seguem a convenção ECS
- O rollover é o processo que cria um novo índice de apoio

## Quiz

1. O Elastic Agent envia dados para múltiplos índices?
   <details><summary>resposta</summary>

   **Sim** — via data streams. Cada integração/dataset tem o seu, seguindo `tipo-dataset-namespace`, o que permite retenção e permissão diferentes por tipo de dado.
   </details>

2. Por que usamos o Elastic Common Schema (ECS) em dados de observabilidade?
   <details><summary>resposta</summary>

   Porque campos com nomes padronizados permitem **correlacionar** sinais de fontes diferentes (log, métrica, trace) e reaproveitar dashboards, alertas e queries — sem tradução manual.
   </details>

3. Qual o nome do processo que cria um novo índice de apoio?
   <details><summary>resposta</summary>

   **Rollover.** Ele fecha o índice atual para escrita e cria a próxima geração, mantendo o nome do data stream estável para quem escreve e consulta.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
