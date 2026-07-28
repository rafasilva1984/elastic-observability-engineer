# Lab 7.3 — Configurar um repositório e adicionar searchable snapshots à política de ILM

> Espelha o **Lab 7.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O Elasticsearch da plataforma já sobe com `path.repo=/snapshots`, então o repositório do tipo `fs` funciona sem ajuste nenhum.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Criar e verificar o repositório

`PUT _snapshot/onp-repo` do tipo `fs` com `location: /snapshots`. Depois rode `POST _snapshot/onp-repo/_verify`.

**Como validar:** O verify retorna os nós que enxergam o repositório.

### Exercício 2 — Snapshot de verdade

Crie um índice `auditoria-2026` com alguns documentos, rode `_forcemerge?max_num_segments=1` (recomendação oficial) e tire o snapshot `snap-auditoria` com `wait_for_completion=true`.

**Como validar:** O snapshot termina com estado `SUCCESS`.

### Exercício 3 — Apagar e montar

Apague o índice original. Depois monte o snapshot: `POST _snapshot/onp-repo/snap-auditoria/_mount?wait_for_completion=true&storage=full_copy` com `renamed_index`.

**Como validar:** O índice montado responde `_count` igual ao original — com o original DELETADO.

### Exercício 4 — Pesquisar no montado

Rode uma busca no índice montado e confirme que os documentos respondem normalmente.

**Como validar:** A busca retorna hits — você está pesquisando dentro de um snapshot.

### Exercício 5 — Ligar ao ILM

Adicione a fase **frozen** com a ação `searchable_snapshot` (apontando para `onp-repo`) numa política de ILM. Descubra na doc qual é a única configuração obrigatória dessa ação.

**Como validar:** A política é aceita e você sabe nomear a configuração obrigatória.

---

## 🔒 Desafio autônomo

Prove a regra de segurança: com o índice montado no ar, tente **deletar** o snapshot que o originou. Observe o comportamento e descubra na documentação oficial o que se deve fazer no lugar. Depois responda: por que réplica de searchable snapshot é 0 por padrão — quem faz o papel da réplica?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Criar e verificar o repositório
- [ ] Snapshot de verdade
- [ ] Apagar e montar
- [ ] Pesquisar no montado
- [ ] Ligar ao ILM
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
