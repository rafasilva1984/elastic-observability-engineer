# Lição 3.3 — APM Troubleshooting

> Módulo 3 · Applications monitoring · Lição 3.3
> Espelha a lição **3.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Diagnosticar o APM mudo com o checklist oficial, em ordem fixa, de fora para dentro. Falha de telemetria é silenciosa: ninguém recebe erro, e você só descobre quando precisa do trace que não existe.

## Tópicos

- O checklist oficial de 'no data' em 4 passos
- Servidor de pé? `curl :8200` e o host `0.0.0.0` em Docker
- Agente entregando? o 401 de secret token
- APM Server reclamando? logs do dataset `elastic_agent.apm_server`
- 503 Queue is full: a nuance entre 503 puro e 503 + 202
- Mapping explosion: o limite de campos e as transações que somem

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
