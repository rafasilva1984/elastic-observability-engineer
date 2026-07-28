# Summary — Lição 7.2 · Index Lifecycle Management

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Data tiers permitem ao Elasticsearch gerenciar onde o dado fica armazenado
- Data streams são criados no tier hot
- O ILM permite configurar e automatizar o padrão de rollover facilmente
- Políticas de ciclo de vida definem 'o que fazer' e 'quando fazer'
- Cada política pode ter cinco fases: hot, warm, cold, frozen e delete
- Você define políticas pela API ou pelo Kibana
- `min_age` conta a partir do rollover — a causa clássica de 'o Elastic não apaga meu dado'

## Quiz

1. Verdadeiro ou falso: quando um índice hot faz rollover, as escritas vão automaticamente para o novo índice de apoio.
   <details><summary>resposta</summary>

   **Verdadeiro.** É exatamente o propósito do rollover: o alias de escrita passa a apontar para a nova geração, sem quem escreve perceber.
   </details>

2. Cite as cinco fases do ILM.
   <details><summary>resposta</summary>

   **hot** (escrita e consulta intensa), **warm** (consulta ocasional), **cold** (raramente consultado), **frozen** (snapshot pesquisável) e **delete**.
   </details>

3. Se você quer o índice 5 dias na fase warm e depois passar para cold, qual `min_age` você define na cold?
   <details><summary>resposta</summary>

   **5 dias** — porque `min_age` é contado a partir do **rollover**, não a partir da entrada na fase anterior. Confundir isso é o erro mais comum.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
