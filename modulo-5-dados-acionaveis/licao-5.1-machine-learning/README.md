# Lição 5.1 — Machine Learning

> Módulo 5 · Actionable observability data · Lição 5.1
> Espelha a lição **5.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Deixar a plataforma vigiar o que ninguém tem tempo de olhar. Você vai rodar jobs de anomaly detection prontos, ler o Single Metric Viewer e o Anomaly Explorer, e usar Forecast para projetar comportamento futuro.

## Tópicos

- O problema real: dado demais, observador de menos
- Como o ML aprende o normal a partir do histórico
- Anomaly score 0–100 e os três níveis (bucket, influencer, record)
- Single Metric Viewer: valor real × faixa esperada
- Anomaly Explorer: swim lanes e severidade por cor
- Forecast: usar o passado para sugerir o futuro
- Análise de população: comparar a entidade com as demais

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
