# Lição 5.3 — Alerting

> Módulo 5 · Actionable observability data · Lição 5.3
> Espelha a lição **5.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Fechar o ciclo: transformar detecção em ação. Você vai criar regras (threshold e anomalia), conectar ações e — o mais importante — calibrar antes de ligar, para não alimentar a fadiga de alertas.

## Tópicos

- Os três blocos: regra (condição), conector (canal) e ação (o que enviar)
- Alerting integrado às apps de Observability
- Rules UI em Stack Management: gestão central
- Conectores nativos (index, e-mail, webhook, Slack…)
- Regras de anomalia: severity padrão 75 e o check ≈ bucket span
- O botão Test: quantos alertas TERIAM disparado
- Threshold × anomalia: limite conhecido × desvio desconhecido

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
