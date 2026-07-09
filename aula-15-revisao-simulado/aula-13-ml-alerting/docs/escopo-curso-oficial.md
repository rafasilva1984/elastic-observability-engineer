# Escopo — Aula 13 · Machine Learning e Alerting (módulos EOE 5.1–5.3)

Fontes oficiais:
- Tutorial "Getting started with anomaly detection" (jobs do sample web
  logs, Single Metric Viewer com bounds, Anomaly Explorer/swim lanes e
  cores por severidade, population job, Forecast):
  elastic.co/docs/explore-analyze/machine-learning/anomaly-detection/ml-getting-started
- Job types (single/multi/population/rare/categorization/advanced):
  .../ml-anomaly-detection-job-types
- Run a job (bucket span 5min–1h, datafeed, custom rules, calendars):
  guia oficial ml-ad-run-jobs
- View results (bucket × influencer × record scores; multi-bucket
  impact; painel de Alerts sincronizado): ml-ad-view-results
- Create an anomaly detection rule (severity 75 padrão, anomaly filter
  KQL, interim results, variáveis como anomalyExplorerUrl, check ≈
  bucket span):
  elastic.co/docs/solutions/observability/incident-management/create-an-anomaly-detection-rule
- Generating alerts for ML jobs (2 tipos de regra: resultados e saúde):
  .../ml-configuring-alerts
