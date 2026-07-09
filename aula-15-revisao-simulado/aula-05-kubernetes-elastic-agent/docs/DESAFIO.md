# Desafios — Aula 5 · Kubernetes

## 🟢 Desafio guiado
Refaça o lab sem o vídeo: k3d + DaemonSet + kube-state-metrics +
app-exemplo (README, passos 6–10).

## 🔒 Desafio autônomo — "Encontre o pod quebrado"
**Missão:** aplique um deployment novo com um erro proposital (imagem
inexistente, ex: `nginx:versao-que-nao-existe`) SEM olhar depois o YAML:
1. Encontre o problema usando SOMENTE o Kibana (métricas de estado /
   Observability > Infrastructure).
2. Diga qual métrica/campo denuncia o estado (dica: família `state_*`).
3. Corrija a imagem e prove a recuperação pelo Kibana.

### Critérios de aceite
- [ ] Problema localizado sem `kubectl describe` (só observabilidade)
- [ ] Nome do metricset/campo que revelou o estado anotado
- [ ] Recuperação visível (réplicas desejadas = disponíveis)

### Validação
Antes: réplicas indisponíveis > 0 no Kibana. Depois: zeradas.

### Dica (só se travar)
Sem kube-state-metrics instalado, você NÃO veria nada disso.

⏱ 30 min · Revisão: Vídeo 5 · doc: kubernetes integration (state_*)
