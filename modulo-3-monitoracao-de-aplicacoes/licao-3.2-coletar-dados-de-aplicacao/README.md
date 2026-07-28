# Lição 3.2 — Collect application data

> Módulo 3 · Applications monitoring · Lição 3.2
> Espelha a lição **3.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Entender as duas formas de instrumentar um serviço — agentes APM da Elastic e OpenTelemetry — e a arquitetura do Collector. Você vai instrumentar de fato e decidir, com critério, qual caminho usar.

## Tópicos

- Agentes APM oficiais: instrumentação automática por framework
- OpenTelemetry: padrão neutro (APIs, SDKs, Collector)
- Arquitetura do Collector: receivers, processors, exporters
- OTLP: 4317 (gRPC) e 4318 (HTTP)
- Enviar ao Elastic: endpoint do APM Server + Bearer token
- Vendor lock-in: por que a decisão importa antes de instrumentar

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

⏱ Lab: 35 min
