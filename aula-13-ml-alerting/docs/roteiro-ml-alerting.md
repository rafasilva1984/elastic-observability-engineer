# Roteiro guiado — Machine Learning + Alerting (Aula 13)

Base: ES + Kibana (licença TRIAL — requisito do ML) + sample web logs.
Segue o tutorial oficial de anomaly detection, que usa este mesmo dataset.

## Parte A — Jobs prontos do sample data
1. Machine Learning > Anomaly Detection > **Create job** > data view
   `kibana_sample_data_logs` > use as **configurações fornecidas** do
   sample (cria os 3 jobs do tutorial oficial, incluindo o
   `low_request_rate`).
2. Aguarde os jobs processarem (barra de progresso) — o ML modela o
   comportamento e marca o que foge do modelo.

## Parte B — Ler os resultados (as 2 ferramentas oficiais)
1. **Single Metric Viewer** no `low_request_rate`: linha azul = valor
   real; área sombreada = faixa esperada pelo modelo (95% de confiança).
   Anomalia = ponto fora da faixa, com score.
2. **Anomaly Explorer**: as swim lanes. Cores = severidade do anomaly
   score (azul baixa · amarela média · vermelha alta — mapa oficial).
3. Abra a tabela de anomalias: actual × typical × probability, e a
   seção **Anomaly explanation**.
4. Bônus do tutorial: selecione o job e clique **Forecast** — o modelo
   projeta o comportamento futuro.

## Parte C — Seu primeiro job custom (single metric)
1. Create job > `kibana_sample_data_logs` > **Single metric**.
2. Função **Sum** sobre `bytes` · bucket span sugerido pelo wizard
   (aceite a estimativa — ponto de prova: bucket span típico 5min–1h).
3. Use full data > Create job > veja no Single Metric Viewer.

## Parte D — Alerta de anomalia (fechando o ciclo)
1. Na lista de jobs > Actions do `low_request_rate` > **Create alert
   rule** (caminho oficial da doc de Observability).
2. Severity: **75** (o padrão oficial — score ≥ 75 dispara).
3. Result type: bucket · check interval ≈ bucket span (recomendação
   oficial) · **Test** para pré-visualizar quantos alertas teriam saído.
4. Action: conector **Index** (grava o alerta num índice — perfeito para
   lab, sem depender de e-mail/Slack). Use a variável
   `{{context.anomalyExplorerUrl}}` na mensagem.

## Parte E — E o threshold clássico?
Crie também uma regra **Custom threshold** simples (ex.: count de logs
com `response.keyword: 500` > 10 em 5 min) e compare no mesmo painel de
Alerts: threshold pega o ÓBVIO que você definiu; anomalia pega o desvio
que você NÃO sabia definir.

## Pontos de prova
- ML exige licença (trial/platinum) — o lab usa trial.
- Job = detectores + datafeed; bucket span define a granularidade.
- Tipos: single metric (1 detector) · multi-metric (split + influencers)
  · population (indivíduo × população) · rare · categorization.
- Score 0–100 normalizado; severidade nas cores das swim lanes.
- Regra de anomalia: severity padrão 75; check ≈ bucket span; 2 tipos de
  regra de ML (resultados + saúde do job).
