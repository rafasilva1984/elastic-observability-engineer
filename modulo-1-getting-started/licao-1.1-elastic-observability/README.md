# Lição 1.1 — Elastic Observability

> Módulo 1 · Getting Started · Lição 1.1
> Espelha a lição **1.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Entender o que é observabilidade de verdade (e o que NÃO é), por que ela nasceu da complexidade das arquiteturas modernas, e como a Elastic entrega os três sinais — logs, métricas e traces — numa solução unificada. Você vai reconhecer os três pilares dentro da plataforma do curso.

## Tópicos

- Definição: observabilidade é um ATRIBUTO do sistema, não uma ferramenta
- Por que agora: microsserviços, distribuído, efêmero
- Os três sinais: logs, métricas e traces (e o que cada um responde)
- Monitoração × observabilidade: pergunta conhecida × pergunta nova
- A solução unificada da Elastic e o fluxo coletar → armazenar → analisar
- A loja de demonstração do curso e a telemetria que ela produz

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

⏱ Lab: 20 min
