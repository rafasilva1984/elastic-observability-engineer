# Lição 2.3 — Metrics Monitoring

> Módulo 2 · Logs and metrics monitoring · Lição 2.3
> Espelha a lição **2.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Trabalhar o sinal que conta O QUANTO e a TENDÊNCIA. Você vai navegar Inventory, Hosts e Metrics Explorer, provocar um pico de CPU real e capturá-lo com um alerta — fechando o ciclo coletar → visualizar → alertar.

## Tópicos

- Métrica × log: periodicidade contra evento
- A integração System e os datasets (cpu, memory, load, network, filesystem)
- Onde a UI lê: os padrões `metrics-*` e `metricbeat-*`
- Inventory: o waffle map (cor = uso de CPU) e o detalhe do host
- Hosts e Metrics Explorer: comparação e lupa
- Leitura de load average: 1, 5 e 15 minutos

## Antes de começar

A plataforma precisa estar no ar (sobe **uma vez** e serve o curso inteiro):

```bash
cd ../../plataforma
./scripts/subir.sh        # se ainda não subiu
./scripts/validar.sh      # confirma que está tudo certo
```

Você **não** precisa subir nada específico desta lição. O foco aqui é o
**exercício sobre o tema**, não montar infraestrutura.

## Sequência da lição

1. Assista/leia o conteúdo e acompanhe as telas.
2. Faça o **[LAB.md](./LAB.md)** — é onde o aprendizado acontece.
3. Feche com o **[SUMMARY.md](./SUMMARY.md)** (recapitulação + quiz).

⏱ Lab: 30 min
