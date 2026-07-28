# Lab 3.2 — Instrumentar serviços com agente APM e com OpenTelemetry

> Espelha o **Lab 3.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A `loja-api` e o `pagamento` já usam o agente APM oficial de Python. Aqui você vai inspecionar essa configuração e depois montar o caminho OTel para comparar as duas abordagens.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Ler a instrumentação existente

Abra `plataforma/apps/loja-api/app.py`. Identifique: nome do serviço, URL do servidor, secret token e ambiente. Onde esses valores são definidos no `docker-compose.yml`?

**Como validar:** Você aponta as 4 variáveis e sabe que nenhuma linha de negócio foi alterada para instrumentar.

### Exercício 2 — Confirmar a entrega

Verifique se o APM Server está recebendo: `curl http://localhost:8200` e, no Dev Tools, `GET traces-apm*/_count`.

**Como validar:** O :8200 responde metadados e a contagem de traces cresce.

### Exercício 3 — Rodar um serviço com OTel

Suba um serviço instrumentado com OpenTelemetry apontando para o APM Server. Use as variáveis padrão do SDK: `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_HEADERS` (Bearer + secret token) e `OTEL_SERVICE_NAME`. Consulte a documentação oficial para a sintaxe exata.

**Como validar:** O novo serviço aparece em Applications > Services, junto dos outros.

### Exercício 4 — Comparar os dois caminhos

Compare os metadados de uma transação do serviço com agente Elastic e do serviço com OTel. O que é igual? O que muda?

**Como validar:** Você lista pelo menos duas diferenças concretas nos metadados.

### Exercício 5 — Resource attributes

Adicione `service.version` e `deployment.environment` ao serviço OTel via `OTEL_RESOURCE_ATTRIBUTES` e prove que os atributos aparecem no Kibana.

**Como validar:** Os atributos ficam visíveis nos metadados da transação.

---

## 🔒 Desafio autônomo

Desenhe (e escreva em 5 linhas) a arquitetura de coleta que você recomendaria para uma empresa com 40 microsserviços em 4 linguagens, que quer evitar dependência de fornecedor. Defenda: SDK direto ou Collector no meio? Agente por node ou gateway central? Justifique cada escolha com o trade-off — e cite qual configuração do Collector evita que ele caia junto com o pico de tráfego.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Ler a instrumentação existente
- [ ] Confirmar a entrega
- [ ] Rodar um serviço com OTel
- [ ] Comparar os dois caminhos
- [ ] Resource attributes
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
