# Lab 2.3 — Analisar a infraestrutura e capturar um pico

> Espelha o **Lab 2.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A integração **System** já está coletando do `agente-host-onp` desde que a plataforma subiu. Vamos ler essas métricas nas três telas oficiais e provocar um pico de verdade.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Inventory

Abra **Observability > Infrastructure > Inventory**. Identifique o host, entenda o que a cor representa e abra o detalhe (*Open as page*).

**Como validar:** O `agente-host-onp` aparece no waffle map com métricas atuais.

### Exercício 2 — Hosts

Abra **Observability > Hosts**. Compare CPU, memória, disco e rede. Ordene por uso de CPU.

**Como validar:** Você consegue dizer qual métrica está mais pressionada no host.

### Exercício 3 — Provocar carga

Gere CPU dentro do host monitorado:

```bash
docker exec -d agente-host-onp sh -c 'end=$(( $(date +%s) + 180 )); while [ $(date +%s) -lt $end ]; do :; done'
```

Rode o comando duas vezes (dois loops) e volte ao Inventory.

**Como validar:** Em ~1 min o quadrado do host esquenta e a curva de `system.cpu` sobe.

### Exercício 4 — Metrics Explorer

Em **Infrastructure > Metrics Explorer**, coloque `system.load.1`, `system.load.5` e `system.load.15` no mesmo gráfico, agrupando por `host.name`.

**Como validar:** As curvas se separam durante o pico — a "tesoura" do load average.

### Exercício 5 — Alerta de threshold

Crie uma regra **Custom threshold** para CPU do host acima de 80% por 2 minutos, checando a cada minuto, com ação de log/índice. Provoque a carga de novo.

**Como validar:** A regra dispara e aparece em Observability > Alerts.

---

## 🔒 Desafio autônomo

Descubra, usando **apenas** as telas de métrica, qual PROCESSO consumiu a CPU durante a carga (dica: a integração System tem um dataset de processos — talvez você precise habilitá-lo na policy). Depois responda: por que `system.load.1` sobe muito antes de `system.load.15`, e o que isso te diz sobre um pico ser recente ou sustentado?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Inventory
- [ ] Hosts
- [ ] Provocar carga
- [ ] Metrics Explorer
- [ ] Alerta de threshold
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
