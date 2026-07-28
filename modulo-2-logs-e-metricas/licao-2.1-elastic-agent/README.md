# Lição 2.1 — Elastic Agent

> Módulo 2 · Logs and metrics monitoring · Lição 2.1
> Espelha a lição **2.1** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Entender a arquitetura Elastic Agent + Fleet + integrações: o agente único que coleta tudo, o Fleet Server que o conecta, as policies que o configuram e os comandos de diagnóstico quando algo não chega.

## Tópicos

- Agente único × múltiplos beats: o que mudou e por quê
- Arquitetura: Elastic Agent → Fleet Server → Elasticsearch, gerenciado pela Fleet UI
- Agent policy: o contrato de configuração; integrações como pacotes
- Enrollment token × service token: quem é quem
- Onde os dados caem: data streams `logs-*` e `metrics-*`
- Diagnóstico: status do agente, logs do próprio agente e os erros clássicos

## Antes de começar

A plataforma precisa estar no ar (sobe **uma vez** e serve o curso inteiro):

```bash
cd ../../plataforma
./scripts/subir.sh        # se ainda não subiu
./scripts/validar.sh      # confirma que está tudo certo
```

Você **não** precisa subir nada específico desta lição. O foco aqui é o
**exercício sobre o tema**, não montar infraestrutura.

## Sequência da lição

1. Assista/leia o conteúdo e acompanhe as telas.
2. Faça o **[LAB.md](./LAB.md)** — é onde o aprendizado acontece.
3. Feche com o **[SUMMARY.md](./SUMMARY.md)** (recapitulação + quiz).

⏱ Lab: 30 min
