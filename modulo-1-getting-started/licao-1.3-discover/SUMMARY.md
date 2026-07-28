# Summary — Lição 1.3 · Discover

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Discover é a primeira parada no Kibana para entender qualquer dado
- Ele revela o que está e — mais importante — o que NÃO está sendo populado
- Discover exige data view para enxergar os índices do Elasticsearch
- Filtro é contexto persistente; query é exploração. Os dois convivem
- O time range é a causa nº 1 de "não tem dado" — e também a primeira ferramenta de performance
- Buscas salvas preservam colunas, filtros e período: investigação vira ativo reutilizável

## Quiz

1. Cite três coisas em que o Discover ajuda ao trabalhar com dados de observabilidade.
   <details><summary>resposta</summary>

   Entender a **estrutura** do dado (quais campos existem e como estão preenchidos); **investigar** eventos específicos com KQL e filtros; e **validar a coleta** — provar que o dado está chegando (ou descobrir que não está).
   </details>

2. Verdadeiro ou falso: o Discover exige data views para explorar dados do Elasticsearch.
   <details><summary>resposta</summary>

   **Verdadeiro.** A data view define quais índices consultar e qual é o campo de tempo. Sem ela, o Discover não sabe o que abrir.
   </details>

3. Verdadeiro ou falso: o Discover permite filtrar campos por valores específicos.
   <details><summary>resposta</summary>

   **Verdadeiro.** Por KQL na barra, por filtro estruturado ou clicando direto no valor de um campo na lista lateral.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
