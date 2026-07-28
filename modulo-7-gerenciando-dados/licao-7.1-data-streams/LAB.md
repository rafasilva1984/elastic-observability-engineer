# Lab 7.1 — Criar um data stream e converter um alias

> Espelha o **Lab 7.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Você já viu data streams sendo criados automaticamente pelo agente. Agora vai criar um na mão e enxergar as engrenagens.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Anatomia do que já existe

No Dev Tools: `GET _data_stream/logs-app_exemplo-default`. Identifique o nome, os índices de apoio (`.ds-…`), a geração e o template usado.

**Como validar:** Você aponta o índice de apoio atual e a geração dele.

### Exercício 2 — Criar do zero

Crie um index template com `data_stream: {}` para o padrão `onp-treino-*` e indexe um documento em `onp-treino-app`. Repare: você indexa no NOME do stream, não no índice.

**Como validar:** `GET _data_stream/onp-treino-app` mostra o stream com um índice de apoio `.ds-…-000001`.

### Exercício 3 — Forçar o rollover

Rode `POST onp-treino-app/_rollover` e depois liste os índices de apoio de novo.

**Como validar:** Aparece uma segunda geração (`…-000002`) e a escrita passou para ela.

### Exercício 4 — Append-only na prática

Tente ATUALIZAR um documento antigo pelo nome do data stream e observe o erro. Depois descubra na documentação a forma correta de corrigir um documento em data stream.

**Como validar:** Você explica por que data stream é para dado imutável de série temporal.

### Exercício 5 — Convenção de nomes

Liste `GET _data_stream/*` e decomponha 3 nomes em tipo, dataset e namespace. Diga o que muda operacionalmente ao trocar o namespace.

**Como validar:** Você associa namespace a separação de ambiente/time e ao ciclo de vida.

---

## 🔒 Desafio autônomo

Converta um índice comum em data stream: crie um índice `onp-legado` com alguns documentos e um alias de escrita, e siga a documentação oficial para migrá-lo para data stream. Depois responda: por que a Elastic empurra data streams em vez de índices com alias para dados de observabilidade? Cite dois ganhos concretos.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Anatomia do que já existe
- [ ] Criar do zero
- [ ] Forçar o rollover
- [ ] Append-only na prática
- [ ] Convenção de nomes
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
