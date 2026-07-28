# Lição 7.1 — Data streams

> Módulo 7 · Managing observability data · Lição 7.1
> Espelha a lição **7.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Entender a estrutura que sustenta TODA a observabilidade no Elastic: data streams, índices de apoio, templates e a convenção de nomes. Sem isso, ILM e snapshots viram mágica.

## Tópicos

- Data stream: uma coleção de índices de apoio atrás de um alias
- O padrão de nome: `tipo-dataset-namespace`
- Index template e component templates: o contrato compartilhado
- Append-only: escrito uma vez, nunca atualizado
- Rollover: o processo que cria um novo índice de apoio
- ECS: por que a convenção importa para correlacionar

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
