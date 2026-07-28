# Lab 6.1 — Explorar e construir dashboards

> Espelha o **Lab 6.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A integração System já trouxe dashboards curados. Você vai usá-los, e depois construir o seu sobre `onp-web-logs`.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Dashboards de integração

Em **Dashboards**, filtre pelas tags e encontre os painéis criados pela integração System. Abra um e identifique de quais data streams ele lê.

**Como validar:** Você abre um dashboard que ninguém criou manualmente e sabe dizer a origem dos dados.

### Exercício 2 — Do Discover para o Dashboard

No Discover, monte um filtro (ex.: `response: "500"`), depois abra um dashboard e aplique o mesmo filtro. Observe o que persiste.

**Como validar:** Você explica como o contexto do filtro acompanha a navegação.

### Exercício 3 — Construir do zero

Crie o dashboard `[ONP] Web Logs — Visão Operacional` sobre `ONP Web Logs` com: um painel Markdown (pergunta, dono, como ler), um KPI de total de requisições, uma série temporal e um Top 10 de `geo.src`.

**Como validar:** Os quatro painéis carregam com dados coerentes entre si.

### Exercício 4 — Salvar direito

Salve com **store time with dashboard** (Last 15 days), descrição e a tag `onp`. Reabra e confirme.

**Como validar:** Ao reabrir, o período e os filtros voltam junto — o painel abre pronto para leitura.

### Exercício 5 — Por valor × biblioteca

Crie uma visualização e adicione ao dashboard **por valor**; depois salve outra **na biblioteca** e adicione. Edite as duas e observe a diferença de impacto.

**Como validar:** Você explica quando usar cada modo (e o risco de editar um painel da biblioteca).

---

## 🔒 Desafio autônomo

Construa, sem roteiro, o dashboard `[ONP] Web Logs — Erros` que responda 'de onde vêm os erros HTTP?'. Exigências: filtro de erro no lugar certo (painel ou dashboard — justifique a escolha), hierarquia KPI → tendência → detalhe, e nomes/tags padronizados. Depois responda: por que um dashboard deve responder UMA pergunta, e não ser um catálogo de gráficos?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Dashboards de integração
- [ ] Do Discover para o Dashboard
- [ ] Construir do zero
- [ ] Salvar direito
- [ ] Por valor × biblioteca
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
