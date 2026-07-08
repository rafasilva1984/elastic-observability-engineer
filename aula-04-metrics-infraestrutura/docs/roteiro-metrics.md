# Roteiro guiado — Métricas de infraestrutura (Aula 4)

## Passo 0 — Base no ar
README passos 6 (ES/Kibana/Fleet Server) e a policy do host (abaixo).

## Passo 1 — Policy + integração System (a fundação)
1. Fleet > Agent policies > **Create agent policy** > nome `ONP - Hosts`.
2. Repare (ponto de prova!): a policy nova JÁ NASCE com a integração
   **System** — logs e métricas do host (doc oficial de system metrics).
3. Abra a integração System na policy e confira **Collect metrics from
   System instances** ligado; explore os datasets (cpu, memory, load,
   network, filesystem...). Ative **System core metrics** se quiser
   visão por core.
4. Add agent > copie o **enrollment token** > cole em `HOST_ENROLLMENT_TOKEN`
   no `.env` > `docker compose up -d host-app`.

## Passo 2 — Inventory (o mapa da infraestrutura)
- Observability > **Infrastructure > Inventory**: o waffle map mostra os
  hosts com a cor = uso de CPU (comportamento oficial).
- Clique no `host-app-onp`: overlay de detalhe com métricas do host;
  **Open as page** para a visão completa.

## Passo 3 — Hosts (análise e comparação)
- Observability > **Hosts**: visão orientada a métricas, construída sobre
  o Lens (doc oficial) — CPU, memória, rede, disco por host.

## Passo 4 — O pico ao vivo
- `./scripts/gerar-carga.sh` e volte ao Inventory: o quadrado do host
  esquenta; no detalhe, `system.cpu` sobe. 3 min depois, normaliza.

## Passo 5 — Metrics Explorer (a lupa)
- Infrastructure > **Metrics Explorer**: troque as métricas para
  `system.load.1`, `system.load.5`, `system.load.15` (exemplo da doc
  oficial) e agrupe por `host.name`.

## Passo 6 — Alerta de infraestrutura
- Crie uma regra **Custom threshold** (ou Inventory rule): CPU do host
  acima de 80% por 2 min. Rode a carga de novo e veja a regra reagir.

## Ligações
- Anomalias no host → Aula 13 (ML). Métricas de k8s → Aula 5.
