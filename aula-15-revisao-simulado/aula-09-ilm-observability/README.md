# Aula 09 — ILM para Dados de Observabilidade

Projeto de apoio do **Vídeo 9** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Index Lifecycle Management (ILM)** — assistir ao ciclo de vida
completo de um data stream **em minutos**: rollover agressivo no hot →
readonly/forcemerge no warm → deleção automática, acompanhado pela **ILM
Explain API** e pelo Kibana.

---

## 1. Objetivo do projeto

- Criar uma política ILM (`onp-ciclo-rapido`) com **rollover por `max_docs: 50`**,
  warm 2 min após o rollover e delete 4 min após o rollover.
- Criar o **index template** com `data_stream: {}` + `index.lifecycle.name`
  (padrão do tutorial oficial).
- Gerar dados continuamente e **assistir às gerações** do data stream
  (`.ds-logs-onp.ilm-...-000001, 000002, ...`) nascendo, esfriando e sumindo.
- Diagnosticar tudo com a **ILM Explain API**.

> Truque didático do lab: `indices.lifecycle.poll_interval` reduzido para
> **10s** (padrão oficial: **10 minutos** — ponto de prova!).

## 2. Arquitetura da solução

```
gerar-dados.sh ──► data stream logs-onp.ilm-default
                        │ (write index da geração atual)
     política onp-ciclo-rapido (via template onp-ilm-demo)
                        ▼
   HOT ──rollover(50 docs)──► nova geração .ds-...-00000N
    │
    └─ 2min após rollover ─► WARM (readonly + forcemerge)
                └─ 4min após rollover ─► DELETE (some!)
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-09-ilm-observability
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

## 6. Subindo o ambiente

```bash
docker compose up -d
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

## 7. Montando o ciclo (a sequência importa)

```bash
./scripts/acelerar-ilm.sh     # poll_interval 10s (LAB; padrão = 10min)
./scripts/criar-politica.sh   # hot(rollover 50 docs) -> warm(2m) -> delete(4m)
./scripts/criar-template.sh   # data_stream + index.lifecycle.name
```

## 8. Gerando dados e assistindo ao ciclo

Terminal 1 — gerar:

```bash
./scripts/gerar-dados.sh
```

Terminal 2 — assistir:

```bash
watch -n 5 ./scripts/explicar-ilm.sh
```

O que você vai ver, na ordem:
1. O data stream nasce no primeiro documento (o template casa com o nome).
2. A cada ~50 docs, **rollover**: nasce a geração seguinte
   (`...-000002`, `...-000003`...) e ela vira o **write index**.
3. ~2 min após o rollover de cada índice: fase **warm**
   (readonly + forcemerge para 1 segmento).
4. ~4 min após o rollover: **delete** — o índice some da lista.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

## 10. Como explorar no Kibana

1. **Stack Management > Index Lifecycle Policies**: abra a
   `onp-ciclo-rapido` e veja as fases na UI (é a mesma política via API).
2. **Index Management > Data Streams**: `logs-onp.ilm-default` com a
   coluna de gerações; clique para ver os backing indices e a fase de cada um.
3. **Index Management > Indices** (habilite *Include hidden indices*): os
   `.ds-*` com o **Lifecycle status/phase** — a visão oficial de status.
4. Repare nas políticas **built-in** `logs@lifecycle` e `metrics@lifecycle`
   (criadas automaticamente para observabilidade) — em produção, você
   customiza cópias delas, não edita as gerenciadas.

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **Rollover não acontece**: (a) o índice precisa de **≥1 documento**
  (regra oficial); (b) poll_interval — no padrão de 10 min, a transição
  pode demorar até 2 ciclos (doc oficial); rode `acelerar-ilm.sh` no lab;
  (c) confira `_ilm/explain` — o campo `step` mostra onde parou.
- **Warm/delete "atrasados"**: `min_age` conta **a partir do rollover**, não
  da criação do índice (ponto de prova!).
- **Política presa/erro**: `GET .ds-*/_ilm/explain?only_errors=true` e
  `POST <índice>/_ilm/retry` para reexecutar o passo que falhou.
- **Template não pega**: o stream já existia antes do template? Delete o
  data stream (`DELETE _data_stream/logs-onp.ilm-default`) e gere de novo.
- **Mudei a política e nada mudou**: a definição da fase atual fica em
  **cache** no índice; a nova versão vale ao entrar na próxima fase
  (comportamento oficial).
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- ILM (visão geral, fases, ações, data streams recomendados): https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management
- Configure a lifecycle policy (política + template): https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/configure-lifecycle-policy
- Rollover action (condições; min_age relativo ao rollover): https://www.elastic.co/docs/reference/elasticsearch/index-lifecycle-actions/ilm-rollover
- Phases and actions (min_age, poll_interval, cache de fase): https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/index-lifecycle
- Check ILM status / Explain API (e políticas built-in @lifecycle): https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/policy-view-status
- Rollover e data streams (gerações, write index): https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/rollover

## Limitações deste exemplo

- Single-node: sem tiers físicos hot/warm/cold reais — as fases acontecem
  no mesmo node (o conceito e as ações são os mesmos; em produção, `allocate`
  move entre tiers de hardware).
- **Frozen/searchable snapshots**: apresentados como conceito no vídeo
  (exigem repositório de snapshot; fora do escopo do lab, conforme ementa).
- Números agressivos (50 docs / 2 min / 4 min) são para DIDÁTICA; produção
  usa os padrões de 50 GB / 30 dias como ponto de partida (doc oficial).
