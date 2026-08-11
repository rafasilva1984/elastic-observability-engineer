# Lab 5.3 — Criar alertas

> Espelha o **Lab 5.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Vamos criar os dois tipos de regra, com ação real, e comparar as filosofias lado a lado no painel de alertas.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Conector de índice

Em **Stack Management > Alerts and Insights > Connectors**, crie um conector do tipo **Index** apontando para `onp-alertas`. É o canal mais simples e sem dependência externa.

**Como validar:** O conector aparece na lista e passa no teste.

### Exercício 2 — Regra de threshold

Crie uma regra **Custom threshold** sobre os logs da aplicação (`logs-app_exemplo-default`, da lição 2.2): contagem de documentos cujo `message` contém `ERROR` acima de 5 em 5 minutos, checando a cada minuto, com ação no conector Index. (Se você já aplicou o pipeline da lição 4.1 aos dados reais no desafio autônomo, pode filtrar por `log.level: ERROR` em vez do texto cru — o resultado é o mesmo.)

**Como validar:** A regra fica ativa e, quando dispara, um documento aparece em `onp-alertas`.

### Exercício 3 — Regra de anomalia

Na lista de jobs de ML, use **Create alert rule** sobre um job da lição 5.1: severity **75**, result type *bucket*, check ≈ bucket span.

**Como validar:** A regra aparece ativa em Observability > Alerts > Rules.

### Exercício 4 — Calibrar antes de ligar

Antes de salvar a regra de anomalia, use o botão **Test**: quantos alertas ela teria disparado no período? Ajuste a severity e teste de novo.

**Como validar:** Você escolhe a severity com base em número, não em achismo.

### Exercício 5 — Ler o painel

Abra **Observability > Alerts**. Compare os alertas gerados pelas duas regras: o que cada uma pegou?

**Como validar:** Você explica, com exemplos do seu lab, quando usar cada filosofia.

---

## 🔒 Desafio autônomo

Monte uma regra que use uma **variável de contexto** na mensagem da ação — por exemplo, incluindo o link direto para a investigação (`{{context.anomalyExplorerUrl}}` ou equivalente) e o valor que disparou o alerta. Prove que o documento gravado em `onp-alertas` contém esses dados. Depois responda: por que um alerta sem link de investigação custa caro no plantão?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Conector de índice
- [ ] Regra de threshold
- [ ] Regra de anomalia
- [ ] Calibrar antes de ligar
- [ ] Ler o painel
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
