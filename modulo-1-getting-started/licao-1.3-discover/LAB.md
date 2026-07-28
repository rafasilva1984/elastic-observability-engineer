# Lab 1.3 — Explorar os dados da plataforma com o Discover

> Espelha o **Lab 1.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A plataforma indexou ~720 documentos de tráfego web no índice `onp-web-logs` (data view **ONP Web Logs**), além dos dados que o agente coleta. Ajuste o time range para **Last 15 days** — sem isso você vê tela vazia e culpa a ferramenta.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 25 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Reconhecer a data view

Abra **Discover**, selecione a data view `ONP Web Logs` e ajuste o período para *Last 15 days*. Explore a lista de campos à esquerda: quantos campos existem? Quais têm 100% de preenchimento?

**Como validar:** Você vê o histograma com dados distribuídos ao longo de ~14 dias.

### Exercício 2 — Responder com KQL

Responda: (1) quantas requisições retornaram `response: "500"`? (2) quantas vieram do Brasil (`geo.src: "BR"`)? (3) quantas tiveram `bytes > 5000`? (4) quantas foram para `/checkout` E deram erro?

**Como validar:** As quatro respostas saem do contador de hits, sem exportar nada.

### Exercício 3 — Filtro × query

Fixe um **filtro** de `geo.src: BR` (pin) e depois troque a query da barra. Observe o que persiste e o que muda.

**Como validar:** Você explica em uma frase quando usar filtro (persistente, compartilhável) e quando usar query (exploração rápida).

### Exercício 4 — Criar uma data view do zero

Crie uma data view para os logs do agente (padrão `logs-*`), com `@timestamp` como campo de tempo. Explore os campos do ECS: `log.level`, `host.name`, `data_stream.dataset`.

**Como validar:** A nova data view lista documentos e você identifica o dataset dos logs.

### Exercício 5 — Salvar a investigação

Monte a busca “erros 500 no checkout”, adicione as colunas `url`, `geo.src` e `bytes` na tabela e salve como `[ONP] Erros no checkout`.

**Como validar:** Ao reabrir a busca salva, colunas e filtros voltam juntos.

---

## 🔒 Desafio autônomo

Um campo do índice `onp-web-logs` está declarado no mapping mas **não aparece populado** em nenhum documento. Descubra qual é usando apenas o Discover (dica: a lista de campos mostra a porcentagem de preenchimento). Depois explique: num caso real de produção, quais seriam as DUAS causas mais prováveis para um campo mapeado ficar vazio?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Reconhecer a data view
- [ ] Responder com KQL
- [ ] Filtro × query
- [ ] Criar uma data view do zero
- [ ] Salvar a investigação
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
