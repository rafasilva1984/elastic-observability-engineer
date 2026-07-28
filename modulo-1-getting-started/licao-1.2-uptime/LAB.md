# Lab 1.2 — Monitorar a disponibilidade da loja ONP

> Espelha o **Lab 1.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O agente da plataforma já está enrolado na policy **ONP - Host**. Você vai transformá-lo numa *private location* e criar monitores contra a loja — que está na mesma rede Docker (`http://loja-web:80`).

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Criar a private location

Em **Synthetics > Settings > Private Locations**, crie `ONP - Local` apontando para a agent policy **ONP - Host**. É ela que vai executar as checagens.

**Como validar:** A location aparece disponível ao criar um monitor.

### Exercício 2 — Monitor HTTP da loja

Crie um monitor **HTTP** para `http://loja-web:80`, frequência de 1 minuto, na location `ONP - Local`. Espere a primeira execução.

**Como validar:** O monitor sai de *Pending* e fica **Up**, com duração registrada.

### Exercício 3 — Monitor TCP da API

Crie um monitor **TCP** para `loja-api:5000`. Compare com o HTTP: o que cada um garante e o que NÃO garante?

**Como validar:** Os dois monitores aparecem Up; você sabe dizer que o TCP prova porta aberta, não aplicação saudável.

### Exercício 4 — Provocar uma queda

Derrube a loja (`docker compose stop loja-web` na pasta da plataforma), aguarde ~2 min, observe a mudança de estado e depois suba de novo (`docker compose start loja-web`).

**Como validar:** A timeline mostra a transição **Up → Down → Up** com horário.

### Exercício 5 — Alerta de disponibilidade

Crie uma regra de **Monitor status** que dispare quando o monitor ficar Down por 2 checagens consecutivas, com ação de log ou índice.

**Como validar:** A regra aparece ativa em Observability > Alerts > Rules.

---

## 🔒 Desafio autônomo

Adicione um monitor que valide **conteúdo**, não só status: o HTTP deve falhar se a resposta não contiver a palavra `Loja`. Depois edite o `index.html` da loja-web (em `plataforma/apps/loja-web/`), remova essa palavra, recarregue o container e prove que o monitor ficou Down **mesmo com HTTP 200**. Explique em uma frase por que esse tipo de checagem pega falhas que o status sozinho não pega.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Criar a private location
- [ ] Monitor HTTP da loja
- [ ] Monitor TCP da API
- [ ] Provocar uma queda
- [ ] Alerta de disponibilidade
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
