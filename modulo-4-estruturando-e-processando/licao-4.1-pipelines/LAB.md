# Lab 4.1 — Criar ingest pipelines

> Espelha o **Lab 4.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Os logs da aplicação (`logs-app_exemplo-default`, da lição 2.2) estão chegando como texto puro em `message`. Vamos estruturá-los. O formato é: `2026-07-03T11:00:00Z LEVEL service=checkout user=123 duration_ms=45 msg="texto"`.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Primeiro pipeline

Em **Stack Management > Ingest Pipelines**, crie `onp-app-logs` com um único processor **grok** que extraia timestamp, nível e o resto da linha. Comece simples: `%{TIMESTAMP_ISO8601:log_tempo} %{LOGLEVEL:log.level} %{GREEDYDATA:resto}`.

**Como validar:** O Simulate devolve os três campos separados.

### Exercício 2 — Simulate como gate

Use a **Simulate API** (Dev Tools ou o botão *Test pipeline*) com uma linha real do log e uma linha inventada fora do padrão.

**Como validar:** A linha válida é estruturada; a inválida gera erro — e você vê exatamente qual processor falhou.

### Exercício 3 — Completar a extração

Evolua o grok, um campo por vez, até extrair `service.name`, `user.id`, `event.duration` e a mensagem. Construa **incremental**: nunca escreva o padrão inteiro de uma vez.

**Como validar:** O Simulate mostra todos os campos separados corretamente.

### Exercício 4 — Tolerância a falha

Adicione um bloco `on_failure` ao pipeline que, em caso de erro, gere a tag `falha_parsing` e preserve a mensagem original.

**Como validar:** A linha inválida agora é indexada com a tag, em vez de ser rejeitada.

### Exercício 5 — Condicional

Adicione um processor que só execute quando `log.level == "ERROR"` (use a opção `if`), por exemplo adicionando o campo `alerta: true`.

**Como validar:** O Simulate mostra o campo apenas nos documentos ERROR.

---

## 🔒 Desafio autônomo

Aplique o pipeline de verdade à coleta: configure a integração Custom Logs da policy **ONP - Host** para usar o pipeline `onp-app-logs` (procure na doc oficial onde a integração aceita um pipeline customizado — dica: sufixo `@custom`). Prove que os NOVOS documentos chegam estruturados enquanto os antigos continuam crus. Responda: por que os antigos não mudam?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Primeiro pipeline
- [ ] Simulate como gate
- [ ] Completar a extração
- [ ] Tolerância a falha
- [ ] Condicional
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
