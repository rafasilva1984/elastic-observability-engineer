# Lab 5.2 — Criar jobs de machine learning customizados

> Espelha o **Lab 5.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Agora você decide o tipo de job. A regra é sempre a mesma: primeiro a pergunta, depois o tipo.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Single metric consciente

Crie um job single metric com `Sum(bytes)` sobre `onp-web-logs`. Anote o detector escolhido e o bucket span estimado.

**Como validar:** O job roda e você sabe dizer o que ele está vigiando.

### Exercício 2 — Multi-metric com split

Crie um job **multi-metric** com `Count` e `Sum(bytes)`, dividido por `geo.src`, usando `clientip` como influencer.

**Como validar:** O Anomaly Explorer mostra anomalias por país e lista influencers.

### Exercício 3 — Population

Crie um job **population** com `Count` sobre a população `clientip`: o objetivo é achar o IP que se comporta diferente de todos os outros.

**Como validar:** Você identifica ao menos um `clientip` destacado na análise.

### Exercício 4 — Rare

Crie um job **rare** sobre `url` ou `response`. O que ele encontra que os outros tipos não encontram?

**Como validar:** Você explica a diferença entre 'valor incomum' e 'volume anômalo'.

### Exercício 5 — Escolher o tipo certo

Para cada pergunta, diga o tipo de job e justifique: (a) o tráfego total caiu? (b) qual usuário está fora do padrão dos demais? (c) apareceu um código de erro que quase nunca aparece? (d) as mensagens de log mudaram de padrão?

**Como validar:** Quatro respostas com justificativa — esse é o conhecimento que a prova cobra.

---

## 🔒 Desafio autônomo

Crie um job de **categorization** sobre os logs da aplicação (`logs-app_exemplo-default`, campo `message`). Explique o que ele agrupou e por que esse tipo de job é o único que funciona bem em log não estruturado. Depois responda: se você tivesse estruturado esse log com o pipeline da lição 4.1, qual outro tipo de job passaria a ser possível?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Single metric consciente
- [ ] Multi-metric com split
- [ ] Population
- [ ] Rare
- [ ] Escolher o tipo certo
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
