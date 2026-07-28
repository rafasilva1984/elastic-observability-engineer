# Lição 3.1 — Applications (APM)

> Módulo 3 · Applications monitoring · Lição 3.1
> Espelha a lição **3.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Investigar performance de aplicação com APM: da visão geral de serviços ao waterfall de uma transação, passando pelo service map e pela análise de erros. É aqui que 'está lento' vira 'está lento NESTE span, DESTE serviço'.

## Tópicos

- APM: monitoração de performance construída sobre o Elastic Stack
- Transação × span: a transação É um tipo especial de span
- Trace distribuído: seguir a requisição atravessando serviços
- Service map: a arquitetura desenhada a partir do tráfego real
- Latência, throughput e taxa de erro: o trio de leitura
- Errors: exceções agrupadas por assinatura

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
