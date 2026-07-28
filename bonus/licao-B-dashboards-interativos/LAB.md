# Lab B — Tornar o dashboard navegável

> Espelha o **Lab B** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Você vai partir do `[ONP] Web Logs — Visão Operacional` (lição 6.1) e transformá-lo num painel que navega sozinho.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Options list

Adicione um control **Options list** em `geo.src` e teste a filtragem.

**Como validar:** Selecionar um país filtra todos os painéis.

### Exercício 2 — Range slider

Adicione um **Range slider** em `bytes` (só funciona em campo numérico — teste em um keyword para ver o comportamento).

**Como validar:** O slider aparece e filtra por faixa.

### Exercício 3 — Chain

Ligue os controls em cadeia: escolher o país deve limitar as opções do control seguinte.

**Como validar:** As opções do segundo control mudam conforme a seleção do primeiro.

### Exercício 4 — Drilldown com contexto

Crie um drilldown do painel Top 10 para um dashboard de detalhe, marcando **use filters and query from origin** e **use date range from origin**.

**Como validar:** O destino abre já filtrado pelo que você clicou.

### Exercício 5 — Drilldown de URL

Crie um drilldown de URL usando uma variável do evento (ex.: `{{event.value}}`) apontando para uma busca externa ou um runbook fictício.

**Como validar:** O clique abre a URL com o valor do painel embutido.

---

## 🔒 Desafio autônomo

Repita o padrão (não os passos) sobre outro conjunto de dados: monte um par executivo → operacional com controls encadeados e um Discover drilldown. Depois responda: por que campo computado (fórmula) normalmente não dispara drilldown?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Options list
- [ ] Range slider
- [ ] Chain
- [ ] Drilldown com contexto
- [ ] Drilldown de URL
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
