# Lição 1.3 — Discover

> Módulo 1 · Getting Started · Lição 1.3
> Espelha a lição **1.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Dominar a primeira parada de qualquer investigação no Kibana. Você vai criar data views, filtrar com KQL, entender quais campos estão (e quais NÃO estão) populados, e salvar buscas — a habilidade que sustenta todas as outras lições.

## Tópicos

- Data view: o contrato entre o Kibana e os índices
- Anatomia do Discover: time range, barra de busca, lista de campos, tabela
- KQL na prática: igualdade, intervalo, existência, curingas e booleanos
- Filtros × query: quando usar cada um
- Descobrir o que NÃO está populado (o campo vazio que denuncia a coleta)
- Buscas salvas e o time range que engana

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

⏱ Lab: 25 min
