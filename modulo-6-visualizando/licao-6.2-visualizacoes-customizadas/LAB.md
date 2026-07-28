# Lab 6.2 — Criar visualizações

> Espelha o **Lab 6.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O índice `onp-web-logs` tem `geo.coordinates` (geo_point) — então dá para fazer mapa de verdade. Vamos montar um catálogo de visualizações sobre os MESMOS dados, para sentir como cada formato responde uma pergunta diferente.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Métrica e tendência

Com Lens, crie: (a) um **Metric** com `Sum(bytes)`; (b) uma **linha/área** de contagem por `@timestamp`.

**Como validar:** Os dois painéis renderizam e você diz qual pergunta cada um responde.

### Exercício 2 — Comparação e composição

Crie: (c) **barras horizontais** com Top 10 `geo.src`; (d) uma **tabela** com Top 10 `url` mostrando contagem e média de bytes.

**Como validar:** A tabela traz duas métricas na mesma linha.

### Exercício 3 — Heat map

Crie um **heat map** com `@timestamp` no eixo X, Top `geo.src` no Y e contagem na célula.

**Como validar:** O padrão de horário/país aparece por intensidade de cor.

### Exercício 4 — Maps

Crie uma visualização de **Maps** usando `geo.coordinates`. Consulte a documentação oficial para adicionar a camada de documentos.

**Como validar:** Os pontos/clusters aparecem no mapa com a distribuição real.

### Exercício 5 — Escolher com critério

Para cada pergunta escolha o gráfico e justifique em uma frase: (1) o tráfego está subindo esta semana? (2) quais os 5 sistemas operacionais mais comuns? (3) qual a proporção de cada código HTTP? (4) de onde vêm as requisições?

**Como validar:** Quatro escolhas justificadas — é o critério, não a ferramenta, que a prova cobra.

---

## 🔒 Desafio autônomo

Construa uma visualização que hoje está ERRADA de propósito e conserte: faça uma pizza com Top 20 de `url` (vai ficar ilegível), depois refaça a mesma pergunta com o formato adequado. Escreva a regra que você extraiu disso. Bônus: monte um gráfico com um campo de altíssima cardinalidade (ex.: `clientip`) e explique por que ele é ruim **para o cluster**, não só para os olhos.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Métrica e tendência
- [ ] Comparação e composição
- [ ] Heat map
- [ ] Maps
- [ ] Escolher com critério
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
