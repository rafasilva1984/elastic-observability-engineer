# Summary — Lição 3.2 · Collect application data

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Use agentes APM da Elastic ou um SDK OpenTelemetry para instrumentar o serviço na linguagem dele
- Os agentes APM medem performance e rastreiam erros automaticamente, com suporte nativo a frameworks populares
- OpenTelemetry é um framework de observabilidade neutro para coletar, processar e exportar telemetria
- O Collector centraliza buffer, retry, processamento e credencial — desacoplando a aplicação do backend
- OTLP usa 4317 para gRPC e 4318 para HTTP
- Instrumentar uma vez e trocar o backend depois é decisão de arquitetura, não detalhe técnico

## Quiz

1. Verdadeiro ou falso: dá para instrumentar serviços usando agentes APM da Elastic ou a API/SDK do OpenTelemetry.
   <details><summary>resposta</summary>

   **Verdadeiro.** Os dois caminhos entregam no mesmo APM Server. A escolha é de estratégia (acoplamento, padronização, esforço de migração).
   </details>

2. Verdadeiro ou falso: pela Fleet UI você gerencia centralmente instâncias do APM Server.
   <details><summary>resposta</summary>

   **Verdadeiro.** O APM Server roda como uma integração no Elastic Agent, então é gerenciado pela policy no Fleet.
   </details>

3. Verdadeiro ou falso: OpenTelemetry é um framework novo da Elastic para coletar e exportar telemetria.
   <details><summary>resposta</summary>

   **Falso.** É um projeto **neutro** da CNCF, não da Elastic — e é exatamente essa neutralidade que resolve o vendor lock-in.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
