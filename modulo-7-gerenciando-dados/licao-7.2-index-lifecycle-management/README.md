# Lição 7.2 — Index Lifecycle Management

> Módulo 7 · Managing observability data · Lição 7.2
> Espelha a lição **7.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Controlar o custo e a performance do dado ao longo do tempo. Você vai criar uma política de ILM, ligá-la a um template e PROVAR o ciclo acontecendo — não só configurar e torcer.

## Tópicos

- Data tiers: hot, warm, cold, frozen
- As cinco fases da política e o que cada uma permite
- `min_age` conta a partir do ROLLOVER, não da criação
- `indices.lifecycle.poll_interval`: 10 minutos por padrão
- Ligar política ao template do data stream
- `_ilm/explain`: o diagnóstico de onde o índice está e por quê

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
