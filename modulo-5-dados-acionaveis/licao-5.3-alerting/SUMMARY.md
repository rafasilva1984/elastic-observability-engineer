# Summary — Lição 5.3 · Alerting

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Alerting permite definir regras que detectam condições complexas e disparam ações quando elas ocorrem
- O alerting é integrado às apps de Observability
- As regras podem ser gerenciadas centralmente no Kibana, pela Rules UI em Stack Management
- O alerting traz um conjunto de conectores e regras prontos para uso
- Regra de anomalia usa severity 75 por padrão e check próximo ao bucket span
- Regra que nasce barulhenta morre silenciada: calibre com o Test antes de ligar

## Quiz

1. Cite os três blocos de construção do Alerting.
   <details><summary>resposta</summary>

   **Regra** (a condição a ser detectada), **conector** (o canal: índice, e-mail, webhook…) e **ação** (o que é enviado quando a regra dispara).
   </details>

2. Verdadeiro ou falso: dá para usar o Elastic Alerting para enviar e-mail quando um host está ficando sem disco.
   <details><summary>resposta</summary>

   **Verdadeiro.** É uma regra de threshold sobre a métrica de filesystem, com um conector de e-mail na ação.
   </details>

3. Verdadeiro ou falso: você precisa de APIs específicas e JSON para criar regras de alerta.
   <details><summary>resposta</summary>

   **Falso.** A Rules UI do Kibana cria tudo pela interface. A API existe e é ótima para automação, mas não é obrigatória.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
