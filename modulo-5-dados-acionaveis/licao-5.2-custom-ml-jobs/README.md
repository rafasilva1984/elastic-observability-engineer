# Lição 5.2 — Custom ML jobs

> Módulo 5 · Actionable observability data · Lição 5.2
> Espelha a lição **5.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Sair dos jobs prontos e criar os seus: escolher o tipo certo de job para a pergunta certa, entender detectores, influencers e split, e saber quando um multi-metric vale mais do que vários jobs separados.

## Tópicos

- Os assistentes: single metric, multi-metric, population, advanced, categorization, rare e geo
- Detector: a função + o campo analisado
- Split e influencers: quem 'puxa' a anomalia
- Multi-metric: mais eficiente que rodar N jobs sobre o mesmo dado
- Population: o indivíduo contra a população
- Categorization: agrupar mensagens parecidas e achar a categoria estranha

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
