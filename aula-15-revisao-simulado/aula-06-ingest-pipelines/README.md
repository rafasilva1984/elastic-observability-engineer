# Aula 06 — Ingest Pipelines

Projeto de apoio do **Vídeo 6** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Ingest Pipelines — extraindo e transformando eventos**: grok para
extrair campos de logs brutos, conversão de tipos, enriquecimento com geoip
e tratamento resiliente de falhas de parsing — testado com a Simulate API
antes de indexar. Uma das habilidades mais cobradas no exame.

---

## 1. Objetivo do projeto

Transformar as linhas brutas de `examples/logs-brutos.log` (o mesmo formato
gerado na Aula 3) em documentos estruturados e consultáveis:

- **grok** extrai `log.level`, `service.name`, `user.id`, `client.ip`,
  `event.duration` e a mensagem.
- **convert** tipa `event.duration` como número (long).
- **date** transforma o timestamp do log no `@timestamp` do documento.
- **geoip** enriquece `client.ip` com localização (`client.geo`).
- **on_failure** preserva linhas fora do padrão com a tag `falha_parsing`
  em vez de descartá-las ou quebrar a ingestão.

## 2. Arquitetura da solução

```
examples/logs-brutos.log
        │  indexar-logs.sh (POST /_doc)
        ▼
┌───────────────────────────────────────────────┐
│ índice logs-aula5                              │
│  index.default_pipeline = onp-logs-app         │
│   grok → convert → date → geoip → remove       │
│   on_failure: tags=[falha_parsing]             │
└───────────────────────┬───────────────────────┘
                        ▼
        documentos estruturados no Discover/Lens
```

## 3. Pré-requisitos

- Docker Engine 24+ e Docker Compose v2. 4 GB de RAM. Portas `9200`, `5601`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-06-ingest-pipelines
```

## 5. Como configurar variáveis de ambiente

```bash
cp .env.example .env
```

## 6. Como subir o ambiente

```bash
docker compose up -d
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

## 7. Como criar e testar o pipeline (o coração da aula)

```bash
./scripts/criar-pipeline.sh      # PUT _ingest/pipeline/onp-logs-app
./scripts/simular-pipeline.sh    # Simulate API: 1 doc válido + 1 fora do padrão
```

**Prática oficial**: sempre testar com a Simulate API antes de indexar.
Na simulação, o doc válido volta estruturado; o doc fora do padrão volta com
`tags: [falha_parsing]` e `error.message` — o on_failure funcionando.

> Alternativa visual: o mesmo pipeline pode ser criado/editado em
> **Stack Management > Ingest Pipelines** no Kibana, processor a processor,
> com o botão *Test pipeline* embutido (mesma Simulate API por baixo).

## 8. Como indexar os logs brutos

```bash
./scripts/indexar-logs.sh
```

O script cria o índice `logs-aula5` com `index.default_pipeline=onp-logs-app`
— **todo** documento indexado passa pelo pipeline automaticamente — e envia
as 12 linhas do arquivo (11 no padrão + 1 fora, de propósito).

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

Correto quando: a busca por `log.level:ERROR AND service.name:pagamento`
retorna documento com `event.duration` numérico e `client.geo` preenchido; e
a busca por `tags:falha_parsing` retorna a linha fora do padrão preservada.

## 10. Como explorar no Kibana

1. **Stack Management > Data Views > Create**: `logs-aula5`
   (timestamp: `@timestamp`).
2. **Discover**: filtre `service.name : "pagamento" and log.level : "ERROR"`
   — agora por CAMPO, não por texto. Compare com a Aula 3.
3. **Lens**: `event.duration` agora é numérico — dá média, percentil, série
   temporal. Texto não soma; número sim.
4. Observe `client.geo.country_iso_code` criado pelo geoip.

## 11. Como parar o ambiente

```bash
docker compose stop
```

## 12. Como remover containers e volumes

```bash
docker compose down -v
```

## 13. Troubleshooting

- **Grok não casa (tudo cai no on_failure)**: construa o padrão de forma
  incremental na Simulate API — comece com `%{TIMESTAMP_ISO8601:log_tempo}
  %{GREEDYDATA:resto}` e vá detalhando. É a técnica recomendada.
- **`convert` falha**: o campo capturado pelo grok vem como string; confira
  o nome exato do campo e se o `NUMBER` capturou só dígitos.
- **`@timestamp` com a hora da ingestão, não do log**: faltou o processor
  `date` — sem ele, o Elasticsearch usa o momento da indexação.
- **geoip vazio**: IPs privados (10.x, 192.168.x) não têm localização; use
  IPs públicos como nos exemplos. `ignore_missing: true` evita erro.
- **Reindexar após ajustar o pipeline**: documentos antigos NÃO são
  reprocessados; use `_reindex` ou apague e rode `indexar-logs.sh` de novo
  (`curl -X DELETE .../logs-aula5`).
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Ingest pipelines (visão geral): https://www.elastic.co/docs/manage-data/ingest/transform-enrich/ingest-pipelines
- Grok processor: https://www.elastic.co/docs/reference/enrich-processor/grok-processor
- GeoIP processor: https://www.elastic.co/docs/reference/enrich-processor/geoip-processor
- Handling pipeline failures (on_failure): https://www.elastic.co/docs/manage-data/ingest/transform-enrich/ingest-pipelines (seção de failure handling)
- Blog oficial Elastic — Structuring data with grok: https://www.elastic.co/blog/structuring-elasticsearch-data-with-grok-on-ingest-for-faster-analytics

## Pontos de prova (integrações + pipelines)

Quando os dados chegam por **integrações do Elastic Agent** (Aulas 3 e 5), o
jeito certo de customizar o processamento é criar pipelines **`@custom`** —
por exemplo `logs-app_exemplo.filestream@custom` (por dataset) ou
`logs@custom` (global de logs) — que as integrações chamam automaticamente,
sem editar os pipelines gerenciados. Isso cai em prova e evita perder
customização em upgrade.

## Limitações deste exemplo

- Ambiente de estudo (TLS desabilitado, single-node).
- Índice simples (`logs-aula5`) para focar no pipeline; em produção com
  integrações, o caminho são data streams + pipelines `@custom`.
- `dissect` não é demonstrado no lab (formato do log é variável); o conceito
  e o critério de escolha grok × dissect estão no vídeo.
