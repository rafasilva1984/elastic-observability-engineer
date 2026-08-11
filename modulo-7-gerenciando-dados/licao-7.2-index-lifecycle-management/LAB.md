# Lab 7.2 — Aplicar uma política de ILM para gerenciar rollovers

> Espelha o **Lab 7.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Em produção as fases levam dias. No lab, vamos acelerar o relógio para ver o ciclo inteiro em minutos — e você vai provar cada transição.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Acelerar o relógio

No Dev Tools: `PUT _cluster/settings` com `indices.lifecycle.poll_interval: "10s"` (persistent). Explique por que o padrão de 10 minutos existe.

**Como validar:** O setting é aceito e você sabe o custo de deixá-lo baixo em produção.

### Exercício 2 — Criar a política

Crie a política `onp-ciclo-rapido`: hot com rollover em `max_docs: 50`, warm com `min_age: 2m` (readonly + forcemerge), delete com `min_age: 4m`.

**Como validar:** `GET _ilm/policy/onp-ciclo-rapido` retorna as três fases.

### Exercício 3 — Ligar ao template

Crie um index template para `onp-ilm-*` com `data_stream: {}` e `index.lifecycle.name: onp-ciclo-rapido`.

**Como validar:** O template aparece e referencia a política.

> **Pegadinha real:** inclua também `index.number_of_replicas: 0` nas settings do template.
> Nosso cluster de lab é **single-node** — se o índice nascer com o padrão de 1 réplica, ela
> nunca vai ser alocada (não há um segundo nó pra colocá-la), e a ação `migrate` da fase warm
> fica **travada para sempre** em "Waiting for all shard copies to be active"
> (`GET _cluster/allocation/explain` confirma `"can_allocate":"no"`). O índice nunca sai da warm,
> a fase delete nunca chega, e o ciclo completo deste lab não fecha. Sem essa flag você não vai
> ver erro nenhum na hora — só vai ficar esperando uma transição que nunca vem.

### Exercício 4 — Gerar e observar

Indexe 60+ documentos no data stream `onp-ilm-teste` e acompanhe com `GET .ds-onp-ilm-teste-*/_ilm/explain?human` a cada 30 segundos.

**Como validar:** Você vê o rollover acontecer (geração 000002) e as fases mudando.

### Exercício 5 — Ler o explain

No explain, identifique: `phase`, `action`, `step`, `age` e o tempo até a próxima ação. Se algo travar, o explain diz o motivo.

**Como validar:** Você consegue explicar, olhando só o explain, o que o índice está esperando.

---

## 🔒 Desafio autônomo

Adicione uma fase **cold** (min_age 3m) entre warm e delete e mude o delete para 6m — SEM apagar a política. Observe: o índice que já estava em andamento muda de comportamento imediatamente? Explique o que acontece (dica: a definição da fase atual fica em cache no índice). Depois responda a pergunta de prova: se você quer o índice 5 dias na warm e depois cold, qual `min_age` você põe na cold?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Acelerar o relógio
- [ ] Criar a política
- [ ] Ligar ao template
- [ ] Gerar e observar
- [ ] Ler o explain
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
