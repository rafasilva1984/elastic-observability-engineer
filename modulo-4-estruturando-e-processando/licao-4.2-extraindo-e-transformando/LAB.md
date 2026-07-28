# Lab 4.2 — Extrair e transformar eventos

> Espelha o **Lab 4.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Aqui o exercício é de precisão. Você vai trabalhar com a Simulate API e documentos de teste — sem depender de coleta — para dominar cada processor isoladamente.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Converter tipos

Simule um pipeline com `convert` transformando `{"duracao":"450","ativo":"true","ip":"10.0.0.1"}` em long, boolean e ip. Depois tente converter `"quatrocentos"` para long e veja o erro.

**Como validar:** Os três campos mudam de tipo; o inválido gera erro claro.

### Exercício 2 — Normalizar datas

Crie um pipeline `date` que aceite os formatos `ISO8601`, `dd/MM/yyyy HH:mm:ss` e `MM/dd/yyyy`. Teste com `31/12/2026 23:59:00` e com `12/31/2026`.

**Como validar:** Os dois viram `@timestamp` corretos — e você percebe a armadilha de dd/MM × MM/dd.

### Exercício 3 — O fuso que engana

Processe `2026-07-03 15:00:00` sem declarar timezone; depois declare `America/Sao_Paulo`. Compare os `@timestamp` resultantes.

**Como validar:** A diferença de 3 horas aparece — e você entende por que o gráfico 'fica deslocado'.

### Exercício 4 — Idioma da data

Processe `03/Jul/2026:11:00:00 -0300` e depois uma data com mês por extenso em outro idioma, usando o parâmetro `locale`.

**Como validar:** A data com idioma declarado é parseada; sem o locale, falha.

### Exercício 5 — Higiene do documento

Encadeie `rename` (campo temporário para nome ECS), `lowercase` (em `log.level`) e `remove` (do campo temporário).

**Como validar:** O documento final tem só os campos ECS, normalizados.

---

## 🔒 Desafio autônomo

Monte um pipeline único que receba QUALQUER um dos três formatos de data acima e sempre produza `@timestamp` correto em UTC, com `on_failure` marcando o que não deu. Teste com os três formatos e com uma data inválida. Responda: por que declarar timezone explicitamente é regra de operação, e não preciosismo?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Converter tipos
- [ ] Normalizar datas
- [ ] O fuso que engana
- [ ] Idioma da data
- [ ] Higiene do documento
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
