# Desafios — Aula 10 · Hello Dashboard

## 🟢 Desafio guiado
Refaça o [ONP] Web Logs — Visão Operacional sem o vídeo
(docs/roteiro-dashboard.md, de memória).

## 🔒 Desafio autônomo — "De onde vêm os erros?"
**Missão:** construa do zero, SEM roteiro, o dashboard
`[ONP] Web Logs — Erros`, que responde: *de onde vêm os erros HTTP?*
Exigências:
1. Painel Markdown com pergunta, dono e como ler.
2. KPI de total de erros (`response >= 400`).
3. Série temporal SÓ de erros.
4. Top 10 países considerando só erros.
5. Display options profissionais + store time + tags.

### Critérios de aceite
- [ ] O filtro de erro está no LUGAR CERTO (painéis ou dashboard —
      justifique a escolha)
- [ ] Hierarquia KPI → tendência → detalhe respeitada
- [ ] Nome, descrição e tags padronizados

### Validação
Reabrir o dashboard: 4 painéis, dados coerentes entre si (o KPI bate com
a soma da série).

### Dica (só se travar)
Filtro fixado no dashboard afeta tudo; filtro por painel, só o painel.

⏱ 30 min · Revisão: Vídeo 10 · doc: create-dashboard
