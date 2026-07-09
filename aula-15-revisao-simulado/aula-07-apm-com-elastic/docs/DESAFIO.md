# Desafios — Aula 7 · APM

## 🟢 Desafio guiado
Refaça o fluxo da aula sem o vídeo: integração APM na policy + apps
instrumentadas + tráfego (README, passos 6–10).

## 🔒 Desafio autônomo — "Applications App challenge"
*(mesmo espírito do challenge oficial EOE 3.1)*

**Missão:** com o tráfego rodando, use SÓ a Applications app para:
1. Identificar o endpoint com pior latência média e dizer QUAL span
   domina o tempo dele (nome + duração).
2. Localizar o erro proposital: taxa de erro, mensagem da exception e
   em qual serviço ela nasce.
3. Criar uma regra de alerta **Latency threshold** para o serviço
   loja-api (limiar acima da média que você observou).

### Critérios de aceite
- [ ] Span dominante do /lento identificado (nome exato do waterfall)
- [ ] Exception do /erro anotada (classe/mensagem)
- [ ] Regra ativa em Applications > Alerts

### Validação
A regra listada + prints do waterfall e da aba Errors.

### Dica (só se travar)
O waterfall da transação ordena spans por tempo — o culpado salta aos olhos.

⏱ 30 min · Revisão: Vídeo 7 · doc: APM UI / alerting
