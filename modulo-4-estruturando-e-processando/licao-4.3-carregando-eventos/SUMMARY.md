# Summary — Lição 4.3 · Loading events

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Endereços IP enriquecem documentos com informação geográfica via processor `geoip`
- Strings de user agent podem ser parseadas com o processor `user_agent`
- O processor `enrich` enriquece documentos com dados de outro índice
- A enrich policy precisa ser criada e EXECUTADA antes de ser usada no pipeline
- Enriquecer na ingestão custa CPU uma vez; enriquecer na consulta custa toda vez
- Dado enriquecido muda a pergunta que você consegue fazer no incidente

## Quiz

1. Verdadeiro ou falso: dá para saber a cidade de origem de uma requisição a partir do IP.
   <details><summary>resposta</summary>

   **Verdadeiro**, com o processor `geoip` — que ainda entrega coordenadas prontas para visualização em mapa.
   </details>

2. Quanto tempo leva para colocar um parser de user agent em produção: 2 minutos, 2 dias ou 2 semanas?
   <details><summary>resposta</summary>

   **2 minutos.** É um processor pronto (`user_agent`) — não precisa escrever regex. Esse é justamente o argumento contra parsers artesanais.
   </details>

3. Como se cria um índice de enriquecimento?
   <details><summary>resposta</summary>

   Você cria um índice normal com os dados de referência, define uma **enrich policy** apontando para ele e **executa** a policy — o Elasticsearch então materializa o índice de sistema usado pelo processor.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
