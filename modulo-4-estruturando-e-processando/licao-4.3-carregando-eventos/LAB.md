# Lab 4.3 — Carregar e enriquecer eventos

> Espelha o **Lab 4.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O índice `onp-web-logs` já tem `clientip` e `user_agent.original`. Vamos enriquecer esses dados e depois cruzar com uma tabela de clientes.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — GeoIP

Crie um pipeline com o processor `geoip` sobre `clientip`, com `target_field` adequado. Teste no Simulate com um IP público (ex.: `8.8.8.8`).

**Como validar:** O documento ganha país, cidade e coordenadas (`location`).

### Exercício 2 — User agent

Adicione o processor `user_agent` sobre `user_agent.original`. Teste com uma string de navegador real e com `curl/8.4.0`.

**Como validar:** Você obtém nome, versão e sistema operacional separados.

### Exercício 3 — Criar o índice de enriquecimento

Crie um índice `clientes-onp` com alguns documentos (`{"ip_faixa":"8.8.8.8","cliente":"ACME","plano":"ouro"}`, etc.).

**Como validar:** O índice existe e responde à busca.

### Exercício 4 — Enrich policy

Crie uma **enrich policy** do tipo `match` sobre `clientes-onp`, **execute** a policy e só então use o processor `enrich` no pipeline. Teste no Simulate.

**Como validar:** O documento sai com os dados do cliente anexados.

### Exercício 5 — Ver o resultado

Reindexe uma amostra de `onp-web-logs` através do pipeline completo (geoip + user_agent + enrich) para um novo índice e explore no Discover.

**Como validar:** Você filtra por país, por navegador e por cliente — coisas impossíveis antes.

---

## 🔒 Desafio autônomo

Descubra e explique: por que a enrich policy precisa ser **executada** antes de o processor funcionar (o que acontece por baixo)? E qual o efeito colateral de alterar o índice de origem sem re-executar a policy? Prove o comportamento no seu lab: altere um documento em `clientes-onp`, teste sem re-executar, depois re-execute e teste de novo.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] GeoIP
- [ ] User agent
- [ ] Criar o índice de enriquecimento
- [ ] Enrich policy
- [ ] Ver o resultado
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
