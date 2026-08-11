# Lição A — Kubernetes com Elastic Agent

> Módulo 0 · Bônus — além do exame · Lição A
> Espelha a lição **A** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Levar a coleta para um cluster Kubernetes: DaemonSet, leader election e o requisito que ninguém lê — kube-state-metrics. Não está no exame, mas está no seu dia a dia.

## Tópicos

- Por que um agente por node (DaemonSet)
- Leader election: quem coleta as métricas de estado do cluster
- kube-state-metrics é REQUISITO para os metricsets de estado
- Autodiscover: coletar de pods que nascem e morrem
- Onde o kubelet mente por omissão

## Antes de começar

A plataforma precisa estar no ar (sobe **uma vez** e serve o curso inteiro):

```bash
cd ../../plataforma
./scripts/subir.sh        # se ainda não subiu
./scripts/validar.sh      # confirma que está tudo certo
```

Diferente das demais lições, esta **exige infraestrutura própria**: um
cluster Kubernetes local (k3d, kind ou minikube) não faz parte da
`plataforma/` do curso. O Fleet Server da plataforma continua sendo o
destino do agente — só o cluster é seu.

## Sequência da lição

1. Assista/leia o conteúdo e acompanhe as telas.
2. Faça o **[LAB.md](./LAB.md)** — é onde o aprendizado acontece.
3. Feche com o **[SUMMARY.md](./SUMMARY.md)** (recapitulação + quiz).

⏱ Lab: 45 min
