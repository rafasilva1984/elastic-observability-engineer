# Desafios — Aula 1 · Introdução ao Kibana

Formato dos labs oficiais (EOE): um desafio **guiado** (walkthrough) e um
desafio **autônomo** — sem passo a passo, com validação por estado final.
Documentação oficial liberada, como na prova.

## 🟢 Desafio guiado
Refaça a exploração da aula **sem o vídeo**: subir o ambiente, carregar o
sample data e navegar Discover/data views (README, passos 6–8).

## 🔒 Desafio autônomo — "Discover challenge"
**Missão:** usando APENAS o Discover sobre `kibana_sample_data_ecommerce`
(crie a data view se precisar), responda:
1. Quantos pedidos existem nos últimos 7 dias?
2. Qual `category` aparece mais nos pedidos?
3. Quantos pedidos têm `taxful_total_price` acima de 100?
4. Salve essa última busca como `[ONP] Pedidos > 100`.

### Critérios de aceite
- [ ] Data view de eCommerce funcional
- [ ] 3 respostas anotadas (confira no fim com agregações próprias)
- [ ] Busca salva aparecendo em Saved Objects

### Validação
Reabra a busca salva: o filtro e a data view devem vir juntos.

### Dica (só se travar)
Campo numérico aceita `campo > valor` direto na barra KQL.

⏱ 20 min · Revisão: Vídeo 1 · doc: explore-analyze/discover
