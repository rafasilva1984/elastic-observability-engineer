# Lab A — Monitorar um cluster Kubernetes

> Espelha o **Lab A** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Este bônus precisa de um cluster local (k3d, kind ou minikube). Ele é o único lab que sobe ambiente próprio — por isso está fora da trilha oficial.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 45 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Cluster local

Suba um cluster com k3d/kind e confirme com `kubectl get nodes`.

**Como validar:** Os nodes aparecem Ready.

### Exercício 2 — kube-state-metrics

Instale o kube-state-metrics no cluster (a integração depende dele para as métricas de ESTADO).

**Como validar:** Os pods do kube-state-metrics estão Running.

### Exercício 3 — Agente como DaemonSet

Aplique o manifesto do Elastic Agent gerado pelo Fleet, apontando para o seu Fleet Server.

**Como validar:** Um pod do agente por node, todos Running e Healthy no Fleet.

### Exercício 4 — Ver o estado

No Kibana, encontre pods em estado ruim (crie um deployment com imagem inexistente de propósito).

**Como validar:** Você identifica o problema pelas métricas de estado, sem usar `kubectl describe`.

### Exercício 5 — Leader election

Verifique quantos agentes coletam as métricas de cluster e explique por quê.

**Como validar:** Você explica leader election e por que ela evita métrica duplicada.

---

## 🔒 Desafio autônomo

Aplique um deployment quebrado (imagem inexistente) SEM olhar o YAML depois e diagnostique usando SOMENTE o Kibana: qual métrica/campo denuncia o estado? Corrija e prove a recuperação pela mesma tela.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Cluster local
- [ ] kube-state-metrics
- [ ] Agente como DaemonSet
- [ ] Ver o estado
- [ ] Leader election
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
