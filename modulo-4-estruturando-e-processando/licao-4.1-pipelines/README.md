# Lição 4.1 — Pipelines

> Módulo 4 · Structuring and processing data · Lição 4.1
> Espelha a lição **4.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Editar documentos ANTES de indexar. Você vai criar ingest pipelines, encadear processors, usar condicionais e — o mais importante em produção — tratar falhas com `on_failure`.

## Tópicos

- Ingest pipeline: processors executados antes da indexação
- Onde processar: Logstash ou Elasticsearch (e o critério)
- Processors encadeados e a ordem que importa
- Condicionais: processar só quando fizer sentido
- `on_failure` no pipeline e no processor individual
- Simulate API: o gate antes de ir para produção

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
