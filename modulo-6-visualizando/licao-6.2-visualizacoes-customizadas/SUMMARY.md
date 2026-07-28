# Summary — Lição 6.2 · Custom visualizations

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Crie visualizações customizadas para ver exatamente o dado que você precisa
- Lens é o editor padrão para criar visualizações
- Maps permite visualizar dados com base em informação geográfica
- No modo de edição você reorganiza os painéis do dashboard
- A pergunta define o gráfico: se você precisa explicar como ler, o gráfico está errado
- Cardinalidade alta no eixo é query pesada E visual ilegível ao mesmo tempo

## Quiz

1. Qual o nome do editor padrão para criar visualizações?
   <details><summary>resposta</summary>

   **Lens** — orientado a arrastar e soltar, com sugestão automática de tipo de gráfico.
   </details>

2. Qual editor permite visualizar dados com base em informação geográfica?
   <details><summary>resposta</summary>

   **Maps**, que trabalha com camadas sobre campos do tipo `geo_point` / `geo_shape`.
   </details>

3. Verdadeiro ou falso: visualizações de mapa exigem dado geográfico.
   <details><summary>resposta</summary>

   **Verdadeiro.** Sem um campo mapeado como `geo_point` (ou coordenadas derivadas, por exemplo via `geoip` na ingestão), não há o que plotar.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
