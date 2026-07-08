# SIMULADO — Elastic Certified Observability Engineer (Vídeo 15)

**Formato espelhando o exame oficial**: tarefas práticas (performance-based)
executadas num cluster real. **Tempo total: 110 minutos** (12 tarefas). Cronometre.

*T11–T12 cobrem a extensão do curso (Vídeos 4, 13 e 14): ML/Alerting e
Searchable Snapshots — domínios do lab oficial EOE 5.x e 7.3.*

Regras da rodada (iguais às condições reais no que importa):
- ✅ **Pode consultar a documentação oficial da Elastic** — no exame real
  você tem acesso a ela o tempo todo (fato do blog oficial). Treine
  NAVEGAR rápido na doc, não decorar.
- ❌ Sem gabarito durante a rodada. Ele está em `docs/gabarito.md` — só
  abra no fim.
- ✔️ Cada tarefa diz como **validar** — no exame, a correção é sobre o
  estado final do cluster. Sempre valide antes de seguir.

Pré-requisito: arena no ar (README, passos 6–7) + `./scripts/preparar-arena.sh`.

---

## Tarefa 1 — Dashboard básico (10 min) · Módulos 1/9
Crie o dashboard `[SIM] Web Logs` sobre `kibana_sample_data_logs` com:
(a) Metric **Sum of bytes**; (b) série temporal de requisições (Area);
(c) barra horizontal **Top 10 geo.src**. Salve com **store time = Last 7
days** e a tag `simulado`.
**Validação:** reabrir o dashboard mostra os 3 painéis com dados.

## Tarefa 2 — Visualizações avançadas (8 min) · Módulo 10
No mesmo dashboard, adicione: (a) **heat map** `@timestamp` × Top
`geo.src` × Count; (b) **tabela** Top 10 `url.keyword` com Count e
Average of bytes.
**Validação:** heat map com células coloridas; tabela com 2 métricas.

## Tarefa 3 — Interatividade (10 min) · Módulo 11
No `[SIM] Web Logs`: (a) control **Options list** em `geo.src`; (b)
control **Range slider** em `bytes`; (c) **dashboard drilldown** do
painel Top 10 para o dashboard `[Logs] Web Traffic` (sample), levando
**filtros e período da origem**.
**Validação:** selecionar um país filtra tudo; o clique-drilldown abre o
destino JÁ filtrado.

## Tarefa 4 — Ingest pipeline (12 min) · Módulo 5
Crie o pipeline `simulado-logs-app` que estruture as linhas de
`examples/logs-brutos.log` (formato: `TS LEVEL service=X user=N
client_ip=IP duration_ms=D msg="..."`): grok → convert (duração→long) →
date (→@timestamp) → geoip → remove do campo temporário; `on_failure`
com tag `falha_parsing`. Teste com a **Simulate API** (1 doc bom + 1
quebrado).
**Validação:** simulate mostra doc estruturado e doc preservado com a tag.

## Tarefa 5 — Indexar e responder (8 min) · Módulos 3/5
Crie o índice `logs-simulado` com `index.default_pipeline=
simulado-logs-app` e indexe as 12 linhas do arquivo. No Discover,
responda: (a) quantos eventos `ERROR`? (b) qual `service.name` tem a
MAIOR `event.duration`? (c) quantos docs têm `tags: falha_parsing`?
**Validação:** respostas conferem com o gabarito.

## Tarefa 6 — ILM de ponta a ponta (12 min) · Módulo 8
(a) `indices.lifecycle.poll_interval: 10s`; (b) política `simulado-ciclo`:
hot rollover `max_docs: 50` → warm `min_age: 2m` (readonly+forcemerge) →
delete `min_age: 4m`; (c) template `simulado-ilm` para
`logs-simulado.ilm-*` com `data_stream:{}`; (d) gere >60 docs no stream
`logs-simulado.ilm-default` e **prove o rollover** com `_ilm/explain`.
**Validação:** ≥2 gerações `.ds-*` e fases distintas no explain.

## Tarefa 7 — APM Server via Fleet (10 min) · Módulo 6
Adicione a integração **Elastic APM** à policy do Fleet Server com host
`0.0.0.0:8200` e o secret token do `.env`.
**Validação:** `curl http://localhost:8200` responde com metadados.

## Tarefa 8 — OTel exporter (8 min) · Módulo 7
Complete as 4 lacunas de `examples/otel-exporter-lacunas.yml` (endpoint
do APM Server da arena + autenticação Bearer).
**Validação:** compare com o gabarito — as 4 lacunas exatas.

## Tarefa 9 — Alerta de threshold (7 min) · Módulos 4/6 (alerting)
Crie uma regra em **Observability > Alerts** do tipo *Custom threshold*:
contagem de documentos de `logs-simulado` com `log.level: ERROR` **> 2
em 5 minutos**, checagem a cada 1 minuto.
**Validação:** a regra aparece ativa na lista de regras.

## Tarefa 10 — Fleet fundamentals (5 min) · Módulos 2/3/4
Crie a agent policy `SIM - Coleta` (com system logs/metrics) e obtenha o
**enrollment token** dela.
**Validação:** policy listada em Fleet e token copiável.

## Tarefa 11 — Machine Learning (10 min) · Vídeos 4/13
Sobre `kibana_sample_data_logs`: (a) crie os **jobs fornecidos** do
sample (ML > Anomaly Detection > Create job > configurações fornecidas);
(b) no `low_request_rate`, identifique no **Single Metric Viewer** uma
anomalia (anote score e horário); (c) crie uma regra de anomalia para
esse job com severity **75** e valide com o botão **Test**.
**Validação:** jobs processados; anomalia anotada; regra listada e testada.

## Tarefa 12 — Searchable Snapshot (10 min) · Vídeos 9/14
(a) Crie o repositório `sim-repo` (tipo `fs`, location `/snapshots` —
o compose da arena já tem `path.repo`); (b) snapshot `sim-snap` contendo
`kibana_sample_data_logs`; (c) **monte** o índice do snapshot com
`storage=full_copy` e nome `logs-montado`; (d) responda: quantos docs
tem o índice montado?
**Validação:** `GET logs-montado/_count` responde igual ao original.

---

**Pontuação sugerida:** 10 pontos/tarefa (120 no total) · **aprovado ≥ 90 (75%)** (rigor
proposital). Terminou? Corrija com `docs/gabarito.md`, anote os domínios
errados, rode `./scripts/reset-simulado.sh` e **repita a rodada** focando
neles. No exame real: leia a tarefa INTEIRA antes de começar, valide o
estado final, e não trave — pule e volte.
