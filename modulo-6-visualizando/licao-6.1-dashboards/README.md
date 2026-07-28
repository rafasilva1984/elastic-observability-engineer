# Lição 6.1 — Dashboards

> Módulo 6 · Visualizing observability data · Lição 6.1
> Espelha a lição **6.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Construir painéis que respondem UMA pergunta. Você vai usar os dashboards que vêm das integrações, criar o seu do zero e entender como filtro e contexto viajam entre Discover e Dashboard.

## Tópicos

- Dashboards que vêm prontos com as integrações
- Filtros viajam entre Discover e Dashboards
- Painel por valor × painel da biblioteca (o que quebra quando você edita)
- Hierarquia de leitura: KPI → tendência → detalhe
- Um dashboard combina visualizações de vários data streams
- Dono, descrição e tags: o que evita o cemitério de painéis

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
