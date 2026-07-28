# Lab 1.1 — Explorar a loja ONP e sua telemetria

> Espelha o **Lab 1.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A plataforma já está gerando os três sinais: a loja-web recebe checagens, a loja-api produz traces e o gerador escreve logs. Seu trabalho aqui é **enxergar cada sinal** e saber dizer qual pergunta ele responde.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 20 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Conhecer a aplicação observada

Abra `http://localhost:8080` (a loja) e `http://localhost:5000` (a API). Chame `http://localhost:5000/api/pedidos`, `/api/lento` e `/api/erro`. Anote o comportamento de cada um.

**Como validar:** Os três endpoints respondem (o `/api/erro` devolve erro 500 — é proposital).

### Exercício 2 — Achar os três sinais no Kibana

No Kibana, localize: (a) **Observability > Logs** (ou Discover sobre `logs-*`), (b) **Observability > Infrastructure**, (c) **Observability > Applications**. Para cada um, escreva UMA frase: que pergunta essa tela responde?

**Como validar:** Você tem três frases distintas — se duas ficaram parecidas, releia o conteúdo da lição.

### Exercício 3 — Ligar sinal a pergunta

Responda usando a tela certa: (1) Quantos eventos de log a aplicação gerou na última hora? (2) Qual o uso de CPU do host monitorado agora? (3) Qual o tempo médio do endpoint `/api/lento`?

**Como validar:** As três respostas vieram de telas diferentes — cada sinal respondeu o que sabe responder.

### Exercício 4 — O limite de cada sinal

Tente responder **só com logs**: "qual serviço causou a lentidão do checkout?". Depois responda a mesma pergunta em Applications (trace).

**Como validar:** Você consegue explicar por que o log sozinho não fecha a resposta — e o trace fecha.

---

## 🔒 Desafio autônomo

Sem consultar o material: monte uma tabela de 3 linhas (log, métrica, trace) com as colunas **o que é**, **que pergunta responde**, **onde vejo na plataforma** e **um exemplo real que eu vi hoje no lab**. Preencha a última coluna com dados que você observou de fato, não com exemplos genéricos.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Conhecer a aplicação observada
- [ ] Achar os três sinais no Kibana
- [ ] Ligar sinal a pergunta
- [ ] O limite de cada sinal
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
