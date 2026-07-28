# Summary — Lição A · Kubernetes com Elastic Agent

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Um agente por node, via DaemonSet, é o padrão em Kubernetes
- kube-state-metrics é requisito para os metricsets de estado — sem ele o cluster mente por omissão
- Leader election garante que só um agente colete as métricas de nível de cluster
- Autodiscover acompanha pods efêmeros sem reconfiguração manual
- Escala muda o jogo: 300 nodes = 300 agentes ingerindo ao mesmo tempo

## Quiz

1. Por que o kube-state-metrics é obrigatório?
   <details><summary>resposta</summary>

   Porque o kubelet reporta o que ele enxerga do NODE. O estado dos OBJETOS (pods em CrashLoopBackOff, réplicas faltando) só existe via kube-state-metrics.
   </details>

2. O que é leader election no contexto do Elastic Agent?
   <details><summary>resposta</summary>

   O mecanismo que elege UM agente do cluster para coletar métricas de nível de cluster, evitando que todos coletem a mesma coisa e dupliquem os dados.
   </details>

3. Verdadeiro ou falso: em Kubernetes você instala um agente por pod.
   <details><summary>resposta</summary>

   **Falso.** É um agente por **node** (DaemonSet). O autodiscover é que cuida dos pods que nascem e morrem.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
