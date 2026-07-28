# Lição 7.3 — Searchable snapshots

> Módulo 7 · Managing observability data · Lição 7.3
> Espelha a lição **7.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Manter dado antigo pesquisável sem pagar cluster quente. Você vai criar repositório, tirar snapshot, montar o índice direto do repositório e ligar isso ao ILM — a engrenagem por trás da fase frozen.

## Tópicos

- Snapshot and Restore API: backup de um cluster em execução
- Snapshot é point-in-time e incremental
- SLM: automatizar a rotina de snapshots
- Searchable snapshot: montar e pesquisar sem restore
- `full_copy` (fully mounted) × `shared_cache` (partially mounted / frozen)
- Snapshot na política de ILM: só uma configuração necessária

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
