# Desafios — Aula 13 · Machine Learning e Alerting

## 🟢 Desafio guiado
Refaça as partes A–E sem o vídeo (docs/roteiro-ml-alerting.md).

## 🔒 Desafio autônomo — "Population + Custom ML Job"
*(cobre os módulos oficiais EOE 5.1 e 5.2)*

**Missão:** sem passo a passo:
1. Crie um job **population** sobre `kibana_sample_data_logs`: count
   dividido pela população `clientip` (é o exemplo do tutorial oficial —
   descubra o IP que se comporta diferente dos demais).
2. Crie um job **multi-metric**: Sum de `bytes` com split por `geo.src`
   e `clientip` como influencer.
3. Para o job da população, crie uma regra de anomalia com **Anomaly
   filter** (KQL) que só alerte para o IP vilão que você encontrou.
4. Responda: qual a diferença entre o score do BUCKET e o score do
   RECORD que você viu nas telas?

### Critérios de aceite
- [ ] IP anômalo identificado no Anomaly Explorer (swim lane vermelha)
- [ ] Influencers aparecendo no job multi-metric
- [ ] Regra com anomaly filter ativa e testada (botão Test)
- [ ] Resposta bucket × record escrita em 2 frases

### Validação
Prints do Anomaly Explorer (população) + regra com o filtro KQL.

### Dica (só se travar)
O tutorial oficial usa exatamente essa população — e o filtro usa
`partition_field_value`/campos do resultado, não do documento.

⏱ 40 min · Revisão: Vídeo 13 · doc: ml-getting-started + anomaly rule
