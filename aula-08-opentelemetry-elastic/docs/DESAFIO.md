# Desafios — Aula 8 · OpenTelemetry

## 🟢 Desafio guiado
Refaça o lab sem o vídeo: Collector + auto-instrumentação Python/Node +
trace cruzando linguagens (README, passos 6–10).

## 🔒 Desafio autônomo — "Adjusting the OTel/APM settings"
*(mesmo espírito dos challenges oficiais EOE 3.2)*

**Missão:** três ajustes de configuração, sem passo a passo:
1. Troque o serviço Python de gRPC (4317) para **HTTP (4318)** — só com
   variáveis de ambiente (pesquise OTEL_EXPORTER_OTLP_PROTOCOL).
2. Adicione `service.version=1.1.0` como resource attribute nos DOIS
   serviços (OTEL_RESOURCE_ATTRIBUTES).
3. No Collector, adicione o processor **attributes** inserindo
   `deployment.environment=lab` em todos os traces.

### Critérios de aceite
- [ ] Traces continuam chegando após a troca de protocolo
- [ ] service.version visível nos metadados da transação no Kibana
- [ ] deployment.environment=lab presente (filtre por ele na APM UI)

### Validação
Applications > serviço > metadados da transação mostra os 2 atributos.

### Dica (só se travar)
Todo processor novo precisa entrar TAMBÉM no pipeline de `service:`.

⏱ 35 min · Revisão: Vídeo 8 · doc: OTel SDK env vars / collector processors
