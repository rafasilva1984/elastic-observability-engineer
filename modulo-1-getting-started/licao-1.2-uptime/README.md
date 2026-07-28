# Lição 1.2 — Uptime

> Módulo 1 · Getting Started · Lição 1.2
> Espelha a lição **1.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Monitorar disponibilidade de fora para dentro, do jeito que o cliente enxerga. Você vai criar monitores (ICMP, TCP e HTTP), ler a app de Uptime e configurar alerta de status — e entender por que dashboard verde com jornada quebrada é o pior cenário de todos.

## Tópicos

- Heartbeat e os três tipos de checagem: ICMP, TCP e HTTP
- Uma instância monitora vários endpoints
- A app de Uptime: status, histórico, duração e tendência
- Certificados TLS: monitorar validade antes de expirar
- Private locations: rodar a checagem de dentro da sua rede
- Alertas de status de monitor e de TLS

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
