# Lab 5.1 — Explorar jobs de machine learning prontos

> Espelha o **Lab 5.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A plataforma sobe com licença **trial** — requisito oficial para ML. Vamos usar o índice `onp-web-logs`, que tem 14 dias de tráfego com padrão e alguns desvios.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Criar o primeiro job

Em **Machine Learning > Anomaly Detection > Create job**, selecione a data view `ONP Web Logs` e crie um job **single metric** com a função `Count`. Aceite o bucket span sugerido pelo assistente.

**Como validar:** O job processa o histórico e aparece na lista com estado `closed` ou `opened`, sem erro.

### Exercício 2 — Single Metric Viewer

Abra o Viewer do job. Identifique: a linha do valor real, a faixa sombreada do esperado e os marcadores de anomalia. Clique num marcador e leia `actual` × `typical` × `probability`.

**Como validar:** Você nomeia um horário anômalo e o score dele.

### Exercício 3 — Anomaly Explorer

Abra o **Anomaly Explorer**. Interprete as cores das swim lanes e abra a tabela de anomalias e a seção de explicação.

**Como validar:** Você associa cor → faixa de severidade e localiza o período mais crítico.

### Exercício 4 — Forecast

No Viewer, rode um **Forecast** para os próximos dias.

**Como validar:** A projeção aparece à frente da série, com intervalo de confiança.

### Exercício 5 — Bucket span importa

Crie um segundo job igual, mas com bucket span bem menor (ex.: 5 min). Compare a quantidade de anomalias detectadas.

**Como validar:** Você explica, com suas palavras, o efeito do bucket span na sensibilidade.

---

## 🔒 Desafio autônomo

Injete uma anomalia REAL e prove que o ML a detecta: pare o `gerador-trafego` por 20 minutos (`docker compose stop gerador-trafego`), depois religue. Crie um job sobre os dados de APM (`traces-apm*`) com a função `Count`, rode sobre o período e verifique se a queda aparece como anomalia. Responda: por que uma QUEDA de tráfego é tão importante de detectar quanto um pico?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Criar o primeiro job
- [ ] Single Metric Viewer
- [ ] Anomaly Explorer
- [ ] Forecast
- [ ] Bucket span importa
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
