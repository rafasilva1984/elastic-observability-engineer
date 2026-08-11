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

`system.cpu.total.norm.pct` é normalizado pelo número de cores lógicos do host — cada loop
abaixo satura **um** core inteiro. Descubra quantos cores sua máquina expõe ao container:

```bash
docker exec agente-host-onp nproc
```

Depois rode o comando de carga **um loop por core, deixando 1-2 cores de folga** (ex.: numa
máquina de 8 cores, rode 6-7 vezes; numa de 16, rode 13-14 vezes) — com só "duas vezes" numa
máquina de muitos cores a CPU normalizada mal sai do lugar:

```bash
docker exec -d agente-host-onp sh -c 'end=$(( $(date +%s) + 180 )); while [ $(date +%s) -lt $end ]; do :; done'
```

**Como validar:** Em ~1 min o quadrado do host esquenta e a curva de `system.cpu` sobe —
quanto mais próximo do total de cores você rodar, mais perto de 100% ela chega.

### Exercício 4 — Metrics Explorer

Em **Infrastructure > Metrics Explorer**, coloque `system.load.1`, `system.load.5` e `system.load.15` no mesmo gráfico, agrupando por `host.name`.

**Como validar:** As curvas se separam durante o pico — a "tesoura" do load average.

### Exercício 5 — Alerta de threshold

Crie uma regra **Custom threshold** para CPU do host acima de 80% por 2 minutos, checando a cada minuto, com ação de log/índice. Provoque a carga de novo (mantendo o número de loops do Exercício 3 até passar de 80%, senão a regra nunca vê o pico).

> **Pegadinha real:** `system.cpu.total.norm.pct` é armazenado como **fração 0–1**, não como
> 0–100. Se a UI do Custom Threshold pedir o valor sem o símbolo `%`, digite **0.8** — "80"
> literal nunca vai disparar, porque nenhum valor real do campo passa de 1. Confirmado testando
> a regra via API: com threshold `80` ela nunca disparou mesmo com CPU real em 0.87; com
> threshold `0.8` disparou corretamente e recuperou quando a carga cessou.

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
