# Summary — Lição 4.1 · Pipelines

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Pipelines permitem editar documentos antes de serem indexados no Elasticsearch
- Estruturar e processar dados pode acontecer no Logstash ou no Elasticsearch
- Condicionais permitem editar documentos com base no conteúdo do próprio documento
- Processors de `on_failure` mandam o documento para outro conjunto de processors quando o pipeline falha
- O handler de `on_failure` também pode ser adicionado a um processor específico
- Simulate não é ferramenta de desenvolvimento: é gate de deploy

## Quiz

1. Em que pontos do Elastic Stack os documentos podem ser manipulados antes da indexação?
   <details><summary>resposta</summary>

   No **Logstash** (pipeline de processamento externo) e no **Elasticsearch** (ingest pipeline, executado no nó de ingestão).
   </details>

2. Verdadeiro ou falso: num ingest pipeline, se um documento causa erro, ele é perdido para sempre.
   <details><summary>resposta</summary>

   **Falso** — desde que exista `on_failure`. Sem ele, sim: o documento é rejeitado e o log some justo quando você vai precisar dele.
   </details>

3. Verdadeiro ou falso: dá para usar condicionais para decidir se um documento deve ser processado.
   <details><summary>resposta</summary>

   **Verdadeiro.** A opção `if` em cada processor aceita uma condição, avaliada por documento.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
