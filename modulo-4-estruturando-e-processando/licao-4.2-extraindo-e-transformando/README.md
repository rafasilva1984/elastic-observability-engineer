# Lição 4.2 — Extracting & Transforming events

> Módulo 4 · Structuring and processing data · Lição 4.2
> Espelha a lição **4.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Dominar os processors de transformação: converter tipos, normalizar datas de formatos diferentes, ajustar caixa e lidar com fuso horário e idioma — os detalhes que separam um dado utilizável de um dado que só parece certo.

## Tópicos

- `convert`: string para número, booleano, IP
- `uppercase` / `lowercase`: normalizar antes de agregar
- `date`: normalizar formatos diferentes para `@timestamp`
- Fuso horário: o padrão é UTC quando você não declara
- `locale`: quando o mês vem escrito em outro idioma
- `rename`, `remove` e `set`: higiene do documento

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
