# Lab D — Simulado cronometrado (12 tarefas / 110 min)

> Espelha o **Lab D** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Regras da rodada: cronômetro ligado, documentação oficial liberada, **gabarito só no fim**. Cada tarefa diz como validar — valide antes de seguir.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 110 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Bloco 1 — Fundamentos (3 tarefas, 25 min)

(1) Crie uma data view e responda 3 perguntas no Discover. (2) Crie um monitor de uptime HTTP com alerta de status. (3) Adicione uma integração a uma agent policy e prove a coleta.

**Como validar:** Estado final: data view + monitor Up + integração coletando.

### Exercício 2 — Bloco 2 — Coleta (2 tarefas, 20 min)

(4) Configure Custom Logs para um arquivo novo com dataset próprio. (5) Encontre no Metrics Explorer o momento de maior uso de CPU do host e crie um alerta de threshold.

**Como validar:** Estado final: data stream novo com documentos + regra ativa.

### Exercício 3 — Bloco 3 — Processamento (3 tarefas, 30 min)

(6) Crie um pipeline com grok + convert + date + `on_failure`. (7) Enriqueça com geoip e user_agent. (8) Prove os dois com a Simulate API (documento bom e documento quebrado).

**Como validar:** Estado final: pipeline salvo e simulate mostrando os dois comportamentos.

### Exercício 4 — Bloco 4 — Análise (2 tarefas, 20 min)

(9) Crie um job de ML e identifique uma anomalia. (10) Crie um dashboard com 4 painéis e 1 control, salvo com período embutido.

**Como validar:** Estado final: job processado + dashboard reabrindo pronto.

### Exercício 5 — Bloco 5 — Gestão de dados (2 tarefas, 15 min)

(11) Crie uma política de ILM com rollover e prove com `_ilm/explain`. (12) Crie repositório, snapshot e monte o índice, respondendo uma busca nele.

**Como validar:** Estado final: explain com 2 gerações + índice montado respondendo.

---

## 🔒 Desafio autônomo

**Modo hard** (a partir da 2ª rodada): 90 minutos em vez de 110, e troque TODOS os nomes de objetos (pipeline, política, índice, dashboard) pelos seus. Ao final de cada tarefa escreva uma linha: 'validei com ___'. Tarefa sem linha de validação vale ZERO — é a regra da prova real. Marque o exame quando fizer ≥ 90/120 em duas rodadas seguidas.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Bloco 1 — Fundamentos (3 tarefas, 25 min)
- [ ] Bloco 2 — Coleta (2 tarefas, 20 min)
- [ ] Bloco 3 — Processamento (3 tarefas, 30 min)
- [ ] Bloco 4 — Análise (2 tarefas, 20 min)
- [ ] Bloco 5 — Gestão de dados (2 tarefas, 15 min)
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
