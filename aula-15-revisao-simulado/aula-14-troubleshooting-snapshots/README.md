# Aula 14 — APM Troubleshooting e Searchable Snapshots

Projeto de apoio do **Vídeo 14 (penúltima aula)** do curso "Preparação
para o Exame Elastic Certified Observability Engineer" — canal
**Observabilidade na Prática**. *(Cobre os módulos oficiais EOE 3.3 APM
Troubleshooting e 7.3 Searchable Snapshots.)*

Dois atos: **(A)** o APM fica MUDO de propósito — rotação de credencial
quebra o secret token do serviço `pagamento` — e você diagnostica com o
**checklist oficial** e prova a correção; **(B)** um índice de auditoria
vira **snapshot pesquisável**: repositório `fs`, snapshot, delete do
índice e `_mount` com busca respondendo direto do repositório.

---

## 1. Objetivo do projeto

- Reproduzir a falha silenciosa mais comum do APM (401 de secret token)
  e diagnosticá-la na ordem oficial: servidor → agente → APM Server →
  dado chegando.
- Conhecer os outros suspeitos do checklist: host `0.0.0.0:8200` em
  Docker, 503 Queue is full (e a leitura 503×202), mapping explosion.
- Operar searchable snapshots de ponta a ponta: repo `fs` (path.repo),
  force-merge, snapshot, mount `full_copy` e busca — e entender o
  `shared_cache` do tier frozen (a máquina por trás do ILM do Vídeo 9).

## 2. Arquitetura da solução

```
┌────────────┐  ┌─────────┐  ┌──────────────────────┐
│elasticsearch│◄─┤ kibana  │  │ fleet-server          │
│ path.repo=  │  │ :5601   │  │ :8220 + APM :8200     │
│ /snapshots  │  └─────────┘  └──────────▲───────────┘
└─────▲──────┘                            │ traces
      │ snapshot/mount        ┌───────────┴───────────┐
┌─────┴──────┐               │ loja-api ──► pagamento │◄─ simular-falha.sh
│ vol.       │               │        ▲ trafego       │   (token errado)
│ snapshots  │               └────────────────────────┘
└────────────┘
```

## 3. Pré-requisitos

Docker Engine 24+ / Compose v2. 6 GB RAM. Portas `9200`, `5601`, `8220`,
`8200`, `5000`.

## 4. Como clonar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-14-troubleshooting-snapshots
```

## 5. Variáveis de ambiente

```bash
cp .env.example .env
```

O `APM_SECRET_TOKEN` do `.env` é o token CORRETO; o override
`docker-compose.quebra.yml` injeta o errado na Parte A.

## 6. Subindo a plataforma

```bash
docker compose up -d elasticsearch kibana
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
docker compose restart kibana
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

## 7. APM + aplicações

Adicione a integração **Elastic APM** à policy do Fleet Server
(host `0.0.0.0:8200` + secret token do `.env` — fluxo do Vídeo 7) e:

```bash
docker compose up -d loja-api pagamento trafego
```

Confira o estado SAUDÁVEL: Applications > Service map com
`loja-api → pagamento`.

## 8. Executando o lab (o coração da aula)

```bash
cat docs/roteiro-troubleshooting.md
./scripts/simular-falha.sh     # Parte A: o pagamento some do mapa
./scripts/diagnosticar.sh      # o checklist oficial, na ordem
./scripts/corrigir-falha.sh    # a prova da correção
./scripts/criar-repo.sh        # Parte B: repositório fs verificado
./scripts/criar-snapshot.sh    # dado de auditoria → snapshot → delete
./scripts/montar-snapshot.sh   # _mount full_copy + busca no montado
```

## 9. Como validar

- Parte A: `diagnosticar.sh` mostra **401** nos logs do pagamento com a
  falha ativa, e a contagem de `traces-apm*` volta a crescer após a
  correção; service map se refaz em ~1 min.
- Parte B: `_count` do `auditoria-2025-montado` = **5** e a busca por
  `usuario:ops3` responde — com o índice original DELETADO.

## 10. Como acessar

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` |
| Elasticsearch | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` |
| APM Server | http://localhost:8200 | — | secret token |
| loja-api | http://localhost:5000 | — | — |

## 11. Parar

```bash
docker compose stop
```

## 12. Remover

```bash
docker compose down -v
```

## 13. Troubleshooting (do lab — e da vida)

- **`:8200` mudo desde o início**: integração APM não foi adicionada à
  policy do Fleet Server (passo 7) — primeiro item do checklist oficial.
- **Falha injetada mas o serviço NÃO some**: aguarde 1–2 min (o mapa
  agrega por janela) e confirme o override:
  `docker inspect pagamento-onp | grep SECRET`.
- **`diagnosticar.sh` sem 401**: alguns agentes logam
  `unauthorized`/`403` — o grep cobre; confira também
  `docker compose logs fleet-server | grep apm-server`.
- **Repo falha ao criar**: `path.repo` ausente (use o compose deste
  projeto) — o Elasticsearch só aceita repositório fs em caminho
  autorizado.
- **Mount lento**: `full_copy` copia os dados do repo para o node em
  background — em lab é rápido; em produção dimensione.
- **Elasticsearch reiniciando**: `sudo sysctl -w vm.max_map_count=262144`.

## 14. Referências oficiais

- Common problems with APM (o checklist do vídeo): https://www.elastic.co/docs/troubleshoot/observability/apm/common-problems
- Searchable snapshots (full_copy × shared_cache, regras): https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore/searchable-snapshots
- Snapshot and restore (repositórios, verify): https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore
- Fleet-managed APM Server: https://www.elastic.co/docs/solutions/observability/apm

## Limitações deste exemplo

- `full_copy` no single-node para o mount funcionar em qualquer lab; o
  modo `shared_cache` (frozen) exige node com cache compartilhado
  dimensionado — citado no vídeo como o modo "de produção".
- Repositório `fs` local: em produção o padrão é objeto (S3/GCS/Azure).
- A falha injetada é de token; o desafio autônomo cobre a variação de
  URL — os demais itens do checklist são discutidos conceitualmente.
