# Summary — Lição 6.1 · Dashboards

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Integrações normalmente já adicionam dashboards e visualizações prontos
- Filtros podem transitar entre o Discover e os Dashboards
- Dashboards customizados reúnem visualizações de múltiplos data streams
- Painel por valor vive dentro do dashboard; painel da biblioteca é compartilhado (editar afeta todos)
- Salvar com o período embutido faz o painel abrir pronto para leitura
- Dashboard sem dono e sem pergunta nasce órfão — e vira cemitério em um ano

## Quiz

1. Verdadeiro ou falso: integrações normalmente adicionam dashboards.
   <details><summary>resposta</summary>

   **Verdadeiro.** É um dos maiores ganhos de usar integrações: além da coleta, vêm painéis curados pela Elastic para aquele serviço.
   </details>

2. Verdadeiro ou falso: dashboards de integração não podem ser editados.
   <details><summary>resposta</summary>

   **Falso.** Podem — mas a boa prática é **clonar** antes de mexer, porque uma atualização da integração pode sobrescrever o original.
   </details>

3. Verdadeiro ou falso: filtros criados no Discover podem seguir para os Dashboards.
   <details><summary>resposta</summary>

   **Verdadeiro.** O contexto de filtro acompanha a navegação, o que mantém a investigação coerente entre as telas.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
