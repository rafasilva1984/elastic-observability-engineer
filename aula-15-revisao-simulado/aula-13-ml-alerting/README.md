# Aula 13 — Machine Learning e Alerting

Projeto de apoio do **Vídeo 13** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.
*(Cobre os módulos oficiais EOE 5.1 Machine Learning, 5.2 Custom
ML Jobs e 5.3 Alerting.)*

Tema: **anomalia detectada sozinha** — jobs de anomaly detection sobre o
sample de web logs (o MESMO dataset do tutorial oficial da Elastic),
leitura no Single Metric Viewer e Anomaly Explorer, um job custom criado
do zero, Forecast, e o ciclo fechado com **regra de alerta de anomalia**
(severity 75) ao lado de um threshold clássico — para comparar as duas
filosofias.

---

## 1. Objetivo do projeto

- Criar os **jobs fornecidos do sample data** (incluindo `low_request_rate`
  do tutorial oficial) e ler os resultados nas duas ferramentas oficiais.
- Criar um **single metric job custom** (Sum de bytes) com bucket span
  estimado pelo wizard.
- Rodar um **Forecast** (projeção de comportamento futuro).
- Criar uma **regra de anomalia** (severity 75, check ≈ bucket span,
  conector Index) e uma **Custom threshold** para comparação.

O passo a passo completo: **`docs/roteiro-ml-alerting.md`** (partes A–E).

## 2. Arquitetura da solução

```
┌──────────────┐    ┌────────────────────────────────────────┐
│elasticsearch │◄───┤ kibana                                  │
│ sample data  │    │ ML: jobs + datafeeds  →  scores 0–100   │
│ (trial: ML!) │    │ Single Metric Viewer · Anomaly Explorer │
└──────────────┘    │ Alerting: regra anomalia + threshold    │
                    └────────────────────────────────────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`.
**Licença trial** (já no compose) — requisito oficial do ML.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-13-ml-alerting
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

## 6. Subindo o ambiente

```bash
docker compose up -d
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

## 7. Carregando o sample data

```bash
./scripts/carregar-dados.sh
```

## 8. Executando o lab (o coração da aula)

```bash
cat docs/roteiro-ml-alerting.md
```

Partes: **A** jobs do sample → **B** leitura (Viewer + Explorer +
Forecast) → **C** job custom → **D** regra de anomalia → **E** threshold
para comparar.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

Funcional: jobs com estado `opened/closed` sem erros em ML > Anomaly
Detection Jobs; swim lanes com blocos coloridos no Anomaly Explorer;
regra ativa em Observability > Alerts.

## 10. Como acessar

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` |
| Elasticsearch | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` |

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **Aba de ML pedindo licença**: o trial expira em 30 dias — recrie o
  ambiente (`down -v` + `up -d`) ou ative novo trial em License Management.
- **Job criado mas sem anomalias**: o sample distribui dados ao redor da
  data de instalação — use o date picker do tutorial (uma semana atrás →
  um mês à frente) para cobrir os pontos.
- **Single Metric Viewer sem a faixa sombreada**: o job precisa de
  `model_plot` habilitado (o wizard do single metric já liga) — jobs
  fornecidos podem variar.
- **Regra não dispara no teste**: severity 75 é exigente por definição;
  use o botão **Test** para ver quantos alertas sairiam e ajuste.
- **Memória**: jobs de ML consomem heap próprio — num lab de 1 GB, rode
  poucos jobs simultâneos e feche os que não estiver usando.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Tutorial oficial (sample web logs, Viewer, Explorer, população, Forecast): https://www.elastic.co/docs/explore-analyze/machine-learning/anomaly-detection/ml-getting-started
- Tipos de job: https://www.elastic.co/docs/explore-analyze/machine-learning/anomaly-detection/ml-anomaly-detection-job-types
- Rodando jobs (bucket span, datafeed, custom rules): https://www.elastic.co/guide/en/machine-learning/current/ml-ad-run-jobs.html
- Lendo resultados (scores bucket/influencer/record): https://www.elastic.co/guide/en/machine-learning/current/ml-ad-view-results.html
- Regra de anomalia (severity 75, filtros, variáveis): https://www.elastic.co/docs/solutions/observability/incident-management/create-an-anomaly-detection-rule
- Alertas para jobs de ML (2 tipos de regra): https://www.elastic.co/docs/explore-analyze/machine-learning/anomaly-detection/ml-configuring-alerts

## Limitações deste exemplo

- Single-node com 1 GB de heap: didática — produção dimensiona nodes de
  ML dedicados.
- Sample data tem padrão "comportado": anomalias reais de produção são
  mais ricas (e mais sutis).
- Conector Index no lugar de e-mail/Slack: mesmo mecanismo, zero
  dependência externa.
