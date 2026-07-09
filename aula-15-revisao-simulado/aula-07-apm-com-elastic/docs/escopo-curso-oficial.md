# Escopo do curso oficial — APM with Elastic

Fonte: Learning Plan oficial (learn.elastic.co), curso "APM with Elastic":
monitorar a performance de aplicações multisserviço e encontrar rapidamente
a causa raiz de falhas.

Mapeamento desta aula (fontes oficiais):
- Conceitos trace/transação/span; transação = tipo especial de span; sampling
  (elastic.co/docs/solutions/observability/apm/transactions)
- APM Server via integração APM no Elastic Agent/Fleet — fluxo recomendado,
  host 0.0.0.0 em Docker, secret token
  (elastic.co/docs/solutions/observability/apm/apm-server/fleet-managed)
- Agentes APM oficiais e envs ELASTIC_APM_SERVER_URL/SECRET_TOKEN/SERVICE_NAME
  (elastic.co/docs/solutions/observability/apm/apm-agents)
- APM app: service map, latência, throughput, taxa de erro, aba Errors
- Distributed tracing: propagação automática de contexto entre serviços
- Extras do outline 24h distribuídos: alerting sobre latência (preview)
- Nota de atualidade: Elastic recomenda considerar os SDKs EDOT
  (Elastic Distributions of OpenTelemetry) para novas instrumentações —
  ponte direta para o Vídeo 8.
