# Escopo do curso oficial — Collect Application Data (OpenTelemetry)

Fonte: Learning Plan oficial (learn.elastic.co), curso "Collect Application
Data": coletar dados de performance com instrumentação OpenTelemetry (OTel)
com Elastic APM — arquitetura de microsserviços instrumentada com agentes
OTel, conexão do OTel Collector ao APM Server e verificação de configuração
de agentes entre linguagens.

Mapeamento (fontes oficiais):
- OTel com Elastic: abordagens (EDOT, contrib SDK/Collector, agente Elastic
  com bridge) e OTLP nativo
  (elastic.co/docs/solutions/observability/apm/opentelemetry)
- Collector contrib -> Elastic: exporter otlp/elastic com Bearer secret
  token; processors recomendados batch + memory_limiter
  (elastic.co/docs/.../upstream-opentelemetry-collectors-language-sdks)
- Anatomia do Collector: receivers/processors/exporters/pipelines; OTLP
  gRPC 4317 e HTTP 4318 (opentelemetry.io/docs/collector/configuration)
- Envs padrão: OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES,
  OTEL_EXPORTER_OTLP_ENDPOINT
- Verificação entre linguagens: Node (auto-instrumentations, OTLP/HTTP) e
  Python (distro, OTLP/gRPC) num mesmo trace
- Nota de atualidade: EDOT (Elastic Distributions of OpenTelemetry) é a
  distribuição com suporte oficial da Elastic; o lab usa contrib para
  ensinar o padrão vendor-neutral (limitação sinalizada conforme doc).
