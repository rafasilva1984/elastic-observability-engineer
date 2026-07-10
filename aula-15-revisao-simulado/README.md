# Aula 15 — Revisão Geral + Simulado

Projeto de apoio do **Vídeo 15 (gran finale)** do curso "Preparação para o
Exame Elastic Certified Observability Engineer" — canal **Observabilidade
na Prática**.

Tema: **Revisão Geral + Simulado** — a arena Docker onde você executa **12
tarefas cronometradas (110 min)** no formato do exame oficial
(performance-based), corrige com **gabarito comentado** e **reseta para
repetir** até estar pronto.

---

## 1. Objetivo do projeto

- Subir a **arena**: Elasticsearch + Kibana + Fleet Server (que vira APM
  Server na Tarefa 7) + sample data + arquivos das tarefas.
- Executar o **simulado** (`docs/simulado.md`): 12 tarefas hands-on
  cobrindo os domínios dos Vídeos 1–14, com validação por estado final —
  como no exame real.
- Corrigir com o **gabarito comentado** (`docs/gabarito.md`), diagnosticar
  os domínios fracos e **repetir** com `./scripts/reset-simulado.sh`.

Fatos do exame (fontes oficiais, ver `docs/escopo-curso-oficial.md`):
performance-based com proctor remoto; **acesso à documentação oficial
durante toda a prova**; US$ 500/tentativa; 14 dias entre tentativas;
badge válido por 2 anos.

## 2. Arquitetura da solução

```
┌────────────────────────── ARENA ──────────────────────────┐
│ ┌────────────┐   ┌─────────┐   ┌──────────────────────┐   │
│ │elasticsearch│◄──┤ kibana  │   │ fleet-server         │   │
│ │ + sample    │   │ :5601   │   │ :8220 + :8200 (APM   │   │
│ │   data      │   └─────────┘   │  após a Tarefa 7)    │   │
│ └────────────┘                  └──────────────────────┘   │
│ examples/logs-brutos.log · examples/otel-exporter-lacunas  │
└───────────────────────────────────────────────────────────┘
   docs/simulado.md (12 tarefas · 110 min) → docs/gabarito.md
                → scripts/reset-simulado.sh → repetir
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 4 GB RAM. Portas `9200`, `5601`, `8220`,
`8200`. Um cronômetro.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-15-revisao-simulado
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

O `APM_SECRET_TOKEN` do `.env` é usado nas Tarefas 7 e 8.

## 6. Subindo a arena

```bash
docker compose up -d elasticsearch kibana
```

### 6.1 Senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
```

### 6.2 Service token + Fleet Server

```bash
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
# cole em FLEET_SERVER_SERVICE_TOKEN no .env
# Cria a policy do Fleet Server no Kibana (obrigatório no 9.x — sem isso o
# Fleet Server fica preso em "Waiting on policy"). Rode ANTES de subir o Fleet:
./scripts/setup-fleet.sh
```

Em seguida, suba o Fleet Server:

```bash
docker compose up -d fleet-server
```

## 7. Preparando os dados

```bash
./scripts/preparar-arena.sh   # instala os 3 sample datasets via API do Kibana
```

## 8. Executando o simulado (o coração do projeto)

```bash
cat docs/simulado.md
```

Regras da rodada: **110 minutos no cronômetro**, documentação oficial
**liberada** (como no exame real), gabarito **proibido** até o fim, e
**valide cada tarefa** pelo critério descrito — a prova corrige o estado
final do cluster.

## 9. Como validar

```bash
./scripts/validar-ambiente.sh
```

E, tarefa a tarefa, o critério de validação descrito no próprio
`docs/simulado.md`.

## 10. Corrigindo e repetindo

1. Some os pontos com `docs/gabarito.md` (10/tarefa, 120 no total; alvo ≥ 90 = 75%).
2. Anote os domínios com erro — o gabarito aponta o vídeo de revisão.
3. Resete e repita:

```bash
./scripts/reset-simulado.sh
```

Recomendação de operação: marque a prova real quando fizer **≥ 80 em duas
rodadas seguidas**.

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting

- **`:8200` mudo**: esperado ANTES da Tarefa 7 — o APM Server nasce quando
  você adiciona a integração Elastic APM à policy do Fleet Server.
- **Reset "não apagou" dashboard/regra/policy**: objetos criados via UI são
  removidos pela UI (ou Saved Objects) — o script limpa os artefatos de
  API (pipeline, índice, ILM, template, data stream, poll_interval).
- **Rollover não veio na Tarefa 6**: ≥1 doc no índice? `poll_interval`
  ajustado? Veja o `step` no `_ilm/explain` (pegadinha revisada no V8).
- **Simulate falhando na Tarefa 4**: construa o grok incremental
  (timestamp + GREEDYDATA primeiro) — técnica do V5.
- **Fleet Server unhealthy**: service token ausente no `.env` ou Kibana
  ainda subindo — confira `docker compose logs fleet-server`.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- FAQ de certificação (formato, proctor, preços, prazos): https://www.elastic.co/training/certification/faq
- Página oficial do exame: https://www.elastic.co/training/elastic-certified-observability-engineer-exam
- Blog oficial de lançamento (doc liberada durante a prova): https://www.elastic.co/blog/be-one-of-the-first-elastic-certified-observability-engineers
- Webinar oficial de preparação: https://www.elastic.co/webinars/preparing-for-the-observability-engineer-exam
- Documentação Elastic (a "arma secreta" — treine a navegação): https://www.elastic.co/docs

## Limitações deste exemplo

- O simulado espelha o **formato** (hands-on, cronometrado, validação por
  estado final) e os **domínios** do Learning Plan; as tarefas do exame
  real são outras — o treino é de habilidade, não de decoreba.
- ML (jobs de anomalia) aparece nas revisões conceituais dos Vídeos 1/3/5;
  a arena single-node com 1 GB de heap não é dimensionada para jobs de ML
  pesados.
- Ambiente de estudo (TLS interno desabilitado, licença trial).
