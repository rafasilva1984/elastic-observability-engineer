# Escopo do curso oficial — Monitoring Kubernetes with Elastic Agent

Fonte: Elastic Observability Engineer — Self-Paced Learning Plan
(learn.elastic.co), curso "Monitoring Kubernetes with Elastic Agent":
instalar o Elastic Agent com a integração Kubernetes para coletar logs e
métricas da infraestrutura.

Mapeamento desta aula (com fontes oficiais):

- DaemonSet oficial gerenciado por Fleet, FLEET_URL/FLEET_ENROLLMENT_TOKEN,
  hostNetwork:true, tolerations de control-plane
  (elastic.co/docs/reference/fleet/running-on-kubernetes-managed-by-fleet)
- kube-state-metrics como requisito para metricsets de estado (mesma fonte
  + github.com/kubernetes/kube-state-metrics)
- Leader election: um pod do DaemonSet coleta métricas de cluster
  (elastic.co/guide/en/fleet/current/scaling-on-kubernetes.html)
- Integração Kubernetes: o que coleta (kubelet, estado, logs de containers)
  (docs.elastic.co/integrations/kubernetes)
- Infrastructure app + dashboards [Metrics Kubernetes]
- Extras do outline oficial de 24h distribuídos aqui: preview de ML
  (anomalia em métricas de infra) e de Alerting (regra de threshold)
