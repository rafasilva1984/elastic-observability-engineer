# Summary — Lição 7.3 · Searchable snapshots

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- A Snapshot and Restore API permite criar e gerenciar backups de um cluster em execução
- Snapshots são cópias point-in-time e incrementais
- Dá para automatizar snapshots com Snapshot Lifecycle Management (SLM)
- Searchable snapshots permitem manter dado antigo no cluster sem consumir muitos recursos
- Searchable snapshots podem ser automatizados como parte de uma política de ILM
- `full_copy` mantém cópia local; `shared_cache` (frozen) usa cache compartilhado e quase nenhum disco

## Quiz

1. Qual é a única configuração necessária ao configurar um searchable snapshot no ILM?
   <details><summary>resposta</summary>

   O **repositório de snapshots** (`snapshot_repository`) na ação `searchable_snapshot`. O resto o ILM cuida.
   </details>

2. Verdadeiro ou falso: pesquisar dados em um searchable snapshot é mais lento.
   <details><summary>resposta</summary>

   **Verdadeiro**, especialmente no modo `shared_cache` (frozen), porque os dados são buscados do repositório sob demanda. É o trade-off consciente: custo baixíssimo em troca de latência maior.
   </details>

3. Verdadeiro ou falso: dá para tirar um snapshot do cluster inteiro numa única requisição REST.
   <details><summary>resposta</summary>

   **Verdadeiro.** Um `PUT _snapshot/<repo>/<nome>` sem especificar índices cobre todos os índices e o estado do cluster.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
