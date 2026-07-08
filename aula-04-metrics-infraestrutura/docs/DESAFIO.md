# Desafios — Aula 4 · Metrics e Infraestrutura

## 🟢 Desafio guiado
Refaça o fluxo sem o vídeo: policy + System → Inventory → Hosts →
carga → Metrics Explorer → alerta (docs/roteiro-metrics.md).

## 🔒 Desafio autônomo — "Encontre o vilão de recursos"
**Missão:** sem passo a passo:
1. Rode a carga e, usando SÓ o Metrics Explorer, monte um gráfico que
   compare `system.load.1` vs `system.load.15` do host — e explique em
   1 frase por que as curvas se separam durante o pico.
2. No detalhe do host (Inventory), identifique qual PROCESSO puxou a
   CPU durante a carga.
3. Crie uma regra de CPU > 80%/2min com uma ação de log e prove o
   disparo com a carga.

### Critérios de aceite
- [ ] Gráfico load.1 × load.15 salvo + explicação da separação
- [ ] Nome do processo vilão anotado
- [ ] Alerta disparado visível em Observability > Alerts

### Validação
Print do alerta ativo + gráfico do Metrics Explorer.

### Dica (só se travar)
load.1 reage rápido; load.15 é a média longa — o pico curto abre a tesoura.

⏱ 30 min · Revisão: Vídeo 4 · doc: infra-and-hosts
