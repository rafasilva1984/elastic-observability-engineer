# Lição 4.3 — Loading events

> Módulo 4 · Structuring and processing data · Lição 4.3
> Espelha a lição **4.3** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Enriquecer o dado na ingestão: transformar IP em localização, user agent em navegador/SO, e cruzar com dados de outro índice via enrich — o que muda uma investigação de 'sei o IP' para 'sei de onde, em qual navegador, de qual cliente'.

## Tópicos

- `geoip`: IP vira país, cidade e coordenadas
- `user_agent`: string crua vira navegador, versão e sistema
- `enrich`: cruzar com dados de outro índice
- Enrich policy: criar, executar e usar (a ordem importa)
- Custo do enriquecimento: o que fazer na ingestão × na consulta
- Onde isso aparece: mapas, filtros e dashboards

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
