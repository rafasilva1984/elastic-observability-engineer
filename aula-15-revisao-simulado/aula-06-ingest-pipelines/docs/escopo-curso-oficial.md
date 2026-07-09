# Escopo do curso oficial — Extracting and Transforming Events

Fonte: Elastic Observability Engineer — Self-Paced Learning Plan
(learn.elastic.co), curso "Extracting and Transforming Events": usar ingest
pipelines para fazer parse, estruturar e transformar logs na entrada do
Elasticsearch — extraindo campos com grok, convertendo tipos para indexação
correta e tratando falhas de parsing com elegância.

Mapeamento desta aula (fontes oficiais):
- Anatomia do pipeline e Simulate API
  (elastic.co/docs/manage-data/ingest/transform-enrich/ingest-pipelines)
- Grok: sintaxe %{PADRAO:campo}, padrões prontos, construção incremental
  (elastic.co/docs/reference/enrich-processor/grok-processor)
- Dissect como alternativa para formatos fixos (conceito no vídeo)
- Processors: convert, date, geoip, remove, set/append (on_failure)
- Parsing resiliente: on_failure + tag falha_parsing
- default_pipeline no índice; pipelines @custom para integrações (ponto de prova)
