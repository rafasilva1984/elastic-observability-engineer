# GABARITO COMENTADO — Simulado (Vídeo 15)

Abra somente após a rodada. Cada resposta aponta o módulo do curso e a
fonte oficial para revisão.

## Tarefa 1 — Dashboard básico
Dashboards > Create dashboard → Markdown opcional → Create visualization
(Lens): Metric/Sum of bytes · Area de Records por @timestamp · Horizontal
bar Top 10 geo.src → Settings: store time ON → Save `[SIM] Web Logs` +
tag. *Revisão: Vídeos 1 e 10 · doc: explore-analyze/dashboards/create-dashboard.*

## Tarefa 2 — Visualizações
Heat map: tipo Heat map · X=@timestamp · Y=Top geo.src · Cell=Count.
Tabela: tipo Table · Rows Top url.keyword · Metrics Count + Average of
bytes. *Vídeo 11 · doc: charts/heat-map-charts.*

## Tarefa 3 — Interatividade
Add > Controls > Control (Options list geo.src; Range slider bytes —
numérico!). Painel Top 10 > Create drilldown > Go to dashboard >
`[Logs] Web Traffic` > marcar **Use filters and query from origin** e
**Use date range from origin**. *Vídeo 12 · doc: dashboards/drilldowns.*

## Tarefa 4 — Ingest pipeline
```
PUT _ingest/pipeline/simulado-logs-app
{ "processors": [
  { "grok": { "field": "message", "patterns": [
    "%{TIMESTAMP_ISO8601:log_tempo} %{LOGLEVEL:log.level} service=%{WORD:service.name} user=%{NUMBER:user.id} client_ip=%{IP:client.ip} duration_ms=%{NUMBER:event.duration} msg=\"%{GREEDYDATA:log.mensagem}\"" ] } },
  { "convert": { "field": "event.duration", "type": "long" } },
  { "date": { "field": "log_tempo", "formats": ["ISO8601"] } },
  { "geoip": { "field": "client.ip", "target_field": "client.geo", "ignore_missing": true } },
  { "remove": { "field": "log_tempo", "ignore_missing": true } } ],
  "on_failure": [ { "append": { "field": "tags", "value": ["falha_parsing"] } } ] }
```
Simulate: `POST _ingest/pipeline/simulado-logs-app/_simulate` com 1 linha
válida + a linha "FORA DO PADRAO". *Vídeo 6 · doc: grok-processor.*

## Tarefa 5 — Respostas dos dados
```
PUT logs-simulado
{ "settings": { "index.default_pipeline": "simulado-logs-app" } }
```
Indexe cada linha como `{"message": "<linha>"}` (script do Vídeo 6 serve
de referência). Respostas: **(a) 3 eventos ERROR** · **(b) estoque**
(timeout de 3020 ms é a maior duração) · **(c) 1 doc** com
`falha_parsing`. *Vídeos 3/6.*

## Tarefa 6 — ILM
```
PUT _cluster/settings
{ "persistent": { "indices.lifecycle.poll_interval": "10s" } }

PUT _ilm/policy/simulado-ciclo   # hot rollover max_docs:50 · warm 2m · delete 4m
PUT _index_template/simulado-ilm
{ "index_patterns": ["logs-simulado.ilm-*"], "data_stream": {},
  "template": { "settings": { "index.lifecycle.name": "simulado-ciclo",
  "number_of_replicas": 0 } } }
```
Gere docs (`POST logs-simulado.ilm-default/_doc` com @timestamp) e prove:
`GET .ds-logs-simulado.ilm-*/_ilm/explain?human` — gerações 000001/000002
com fases distintas. Lembretes de prova: **min_age conta do rollover**;
**poll padrão = 10 min**; **índice vazio não rola**. *Vídeo 9.*

## Tarefa 7 — APM via Fleet
Integrations > Elastic APM > Add → Host/URL `0.0.0.0:8200` (obrigatório
em Docker — doc oficial) → Secret token = `APM_SECRET_TOKEN` do .env →
policy do Fleet Server. `curl http://localhost:8200` responde JSON.
*Vídeo 7 · doc: apm-server/fleet-managed.*

## Tarefa 8 — Lacunas do OTel
```
endpoint: "fleet-server:8200"
Authorization: "Bearer ${env:APM_SECRET_TOKEN}"
```
(lacunas: `fleet-server` · `8200` · `Bearer` · `APM_SECRET_TOKEN`).
Bônus de revisão: 4317=gRPC, 4318=HTTP; `otlp/elastic` é só nome de
instância. *Vídeo 8 · doc: opentelemetry/upstream-collectors.*

## Tarefa 9 — Alerta
Observability > Alerts > Manage Rules > Create rule > Custom threshold →
data view/índice `logs-simulado` → condição: document count com filtro
`log.level: "ERROR"` acima de 2 · janela 5 min · check a cada 1 min →
Save. *Distribuído (Vídeos 5/7).*

## Tarefa 10 — Fleet
Fleet > Agent policies > Create agent policy `SIM - Coleta` (manter
system logs/metrics) → aba do policy > Add agent → copiar o
**enrollment token** exibido. *Fundação dos Vídeos 2/3/5.*


## Tarefa 11 — Machine Learning
ML > Anomaly Detection Jobs > Create job > data view do sample >
**Use as configurações fornecidas** (nascem os 3 jobs, incluindo
`low_request_rate`). Viewer: chart icon nas Actions; a anomalia é o
ponto fora da faixa sombreada (date picker: 1 semana atrás → 1 mês à
frente). Regra: Actions > **Create alert rule** > severity 75 (padrão
oficial) > check ≈ bucket span > **Test**. *Revisão: Vídeo 13 · doc:
ml-getting-started + create-an-anomaly-detection-rule.*

## Tarefa 12 — Searchable Snapshot
```
PUT _snapshot/sim-repo
{ "type": "fs", "settings": { "location": "/snapshots" } }

PUT _snapshot/sim-repo/sim-snap?wait_for_completion=true
{ "indices": "kibana_sample_data_logs" }

POST _snapshot/sim-repo/sim-snap/_mount?wait_for_completion=true&storage=full_copy
{ "index": "kibana_sample_data_logs", "renamed_index": "logs-montado" }

GET logs-montado/_count
```
Lembretes de prova: repo fs exige **path.repo**; `full_copy` = fully
mounted (o lab), `shared_cache` = frozen; **clone** antes de deletar
snapshot montado. *Revisão: Vídeo 14 (+ Vídeo 9 para o frozen).*

---

**Correção por domínio:** errou a 4/5 → reveja o Vídeo 6; a 6 → Vídeo 9;
a 7/8 → Vídeos 7/8; a 1–3 → Vídeos 10–12. Errou a 11 → Vídeos 4/13; a 12 → Vídeo 14. Rode
`./scripts/reset-simulado.sh` e repita a rodada.
