# Lab 3.1 — Investigar a performance da loja com o Applications UI

> Espelha o **Lab 3.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O `gerador-trafego-onp` chama a loja-api continuamente: 70% caminho feliz, 20% endpoint lento e 10% erro. O APM Server já está na 8200 e as apps estão instrumentadas com o agente oficial de Python.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Visão geral dos serviços

Abra **Observability > Applications > Services**. Identifique `loja-api` e `pagamento`: latência média, throughput e taxa de erro de cada um.

**Como validar:** Os dois serviços aparecem com dados dos últimos 15 minutos.

### Exercício 2 — Service map

Abra o **Service map**. Descreva a arquitetura que ele desenhou e diga de onde veio essa informação (ninguém a cadastrou).

**Como validar:** O mapa mostra `loja-api → pagamento`.

### Exercício 3 — Achar o endpoint lento

Em `loja-api > Transactions`, ordene por *Latency*. Abra o `/api/lento` e leia o **waterfall**: qual span domina o tempo?

**Como validar:** Você nomeia o span responsável e a duração dele.

### Exercício 4 — Investigar o erro

Abra a aba **Errors** do `loja-api`. Encontre a exceção, veja a mensagem, o stack trace e quantas ocorrências teve.

**Como validar:** Você identifica a exceção `RuntimeError` e a mensagem do gateway.

### Exercício 5 — Do trace ao log

Numa transação com erro, use os links de correlação para chegar aos logs do mesmo período/serviço.

**Como validar:** Você navega do trace para o contexto sem sair da investigação.

---

## 🔒 Desafio autônomo

Crie uma regra de alerta de **latency threshold** para o serviço `loja-api` usando um limiar acima da média que você observou (não invente o número: leia a média real primeiro). Depois responda: por que alertar em latência média é pior do que alertar no percentil 95? Se a sua versão do Kibana permitir, ajuste a regra para usar p95.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Visão geral dos serviços
- [ ] Service map
- [ ] Achar o endpoint lento
- [ ] Investigar o erro
- [ ] Do trace ao log
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
