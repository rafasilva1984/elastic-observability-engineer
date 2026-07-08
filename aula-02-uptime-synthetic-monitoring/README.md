# Aula 02 — Uptime e Synthetic Monitoring

Projeto de apoio da **Aula 1 (revisada)** do curso "Preparação para o Exame
Elastic Certified Observability Engineer" — canal **Observabilidade na
Prática**.

Domínio coberto: **Uptime / Synthetic Monitoring**, usando a app **Synthetics**
do Kibana com uma **Private Location** rodando via Elastic Agent + Fleet — o
fluxo atual recomendado pela Elastic (a antiga app "Uptime" está deprecated
desde a versão 8.15).

---

## 1. Objetivo do projeto

Praticar, de ponta a ponta, o fluxo oficial de monitoramento de recursos em
redes privadas com Elastic Synthetics:

- Subir Fleet Server e um Elastic Agent (`elastic-agent-complete`) via Docker.
- Registrar uma **Private Location** no Kibana.
- Criar monitores HTTP (e opcionalmente TCP/ICMP) apontando para um app de
  exemplo, direto pela interface do Kibana.
- Visualizar e interpretar os resultados na app Synthetics.

## 2. Arquitetura da solução

```
                                   ┌───────────────┐
                     http check    │  app-exemplo  │  (Nginx monitorado)
                 ┌──────────────►  │               │
                 │                 └───────────────┘
        ┌────────┴────────┐
        │ synthetics-agent │  (Private Location - elastic-agent-complete)
        └────────┬────────┘
                  │ enrolla via
        ┌─────────▼────────┐        ┌───────────────┐        ┌───────────┐
        │   fleet-server    ├───────►│ elasticsearch │◄───────┤  kibana   │
        └───────────────────┘ indexa └───────────────┘  lê    └───────────┘
```

O `synthetics-agent` é o container que efetivamente executa os checks
(HTTP/TCP/ICMP), reportando resultado via Fleet Server para o Elasticsearch.
A criação e gestão dos monitores acontece na app **Synthetics** do Kibana.

## 3. Pré-requisitos

- Docker Engine 24+ e Docker Compose v2 (`docker compose version`).
- Pelo menos 4 GB de RAM livres.
- Portas livres: `9200`, `5601`, `8080`, `8220`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-02-uptime-synthetic-monitoring
```

## 5. Como configurar as variáveis de ambiente

```bash
cp .env.example .env
```

Deixe `FLEET_SERVER_SERVICE_TOKEN` e `SYNTHETICS_ENROLLMENT_TOKEN` em branco
por enquanto — você vai preenchê-los nos passos 6 e 7.

## 6. Como subir a base do ambiente (Elasticsearch, Kibana, app-exemplo)

```bash
docker compose up -d elasticsearch kibana app-exemplo
```

Aguarde até o Elasticsearch e o Kibana ficarem saudáveis (acompanhe com
`docker compose ps`).

### 6.1 Definindo a senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
```

Cole a senha `KIBANA_PASSWORD` do seu `.env` quando solicitado, depois:

```bash
docker compose restart kibana
```

### 6.2 Gerando o service token do Fleet Server

```bash
docker exec -it es-onp bin/elasticsearch-service-tokens create elastic/fleet-server token-onp
```

Copie o token retornado e cole em `FLEET_SERVER_SERVICE_TOKEN` no seu `.env`.

## 7. Como subir o Fleet Server e configurar a Private Location

```bash
docker compose up -d fleet-server
```

Aguarde ~30-60s. Depois, no Kibana:

1. Acesse **Management > Fleet** e confirme que o `fleet-server-onp` aparece
   saudável.
2. Vá em **Management > Fleet > Agent policies** e crie uma nova policy,
   por exemplo `Private Location - Aula 1`.
3. Nessa policy, clique em **Add agent** e copie o **enrollment token**
   gerado.
4. Cole esse token em `SYNTHETICS_ENROLLMENT_TOKEN` no seu `.env`.
5. Suba o agente da Private Location:

```bash
docker compose --profile synthetics up -d synthetics-agent
```

6. Volte ao Kibana, acesse **Observability > Synthetics > Settings > Private
   Locations**, clique em **Create location**, dê um nome (ex:
   `Private Location - Aula 1`) e selecione a agent policy criada no passo 2.

> Esse encadeamento de passos reflete o fluxo oficial documentado pela
> Elastic para monitoramento de redes privadas (ver seção de referências).
> Não é possível automatizar 100% via `docker-compose`, porque a criação da
> agent policy e da Private Location acontece na interface do Kibana.

## 8. Como criar o primeiro monitor

1. Em **Observability > Synthetics**, clique em **Create monitor**.
2. Escolha o tipo **HTTP**.
3. URL: `http://app-exemplo:80` (nome do serviço na rede Docker interna).
4. Em **Locations**, selecione a Private Location criada no passo 7.
5. Defina a frequência (ex: a cada 1 minuto) e salve.

Em poucos ciclos, o monitor aparece com status **Up** na lista de monitores.

## 9. Como validar se os serviços estão funcionando

```bash
./scripts/validar-ambiente.sh
```

## 10. Como acessar as interfaces

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |
| Elasticsearch (API) | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |
| App exemplo (site monitorado) | http://localhost:8080 | - | - |
| Fleet Server (API interna) | https://localhost:8220 | - | - |

## 11. Como simular uma queda

```bash
docker compose stop app-exemplo
```

Aguarde o próximo ciclo do monitor (conforme a frequência configurada) e veja
o status mudar para **Down** na app Synthetics. Para religar:

```bash
docker compose start app-exemplo
```

## 12. Como parar o ambiente

```bash
docker compose --profile synthetics stop
```

## 13. Como remover containers e volumes

```bash
docker compose --profile synthetics down -v
```

O `-v` remove também o volume `es-data`, apagando todos os dados indexados.

## 14. Troubleshooting

- **Fleet Server não fica saudável**: confirme se `FLEET_SERVER_SERVICE_TOKEN`
  foi gerado corretamente (passo 6.2) e se o `.env` foi recarregado
  (`docker compose up -d fleet-server` novamente após editar o `.env`).
- **synthetics-agent não conecta**: o `SYNTHETICS_ENROLLMENT_TOKEN` deve ser o
  token da agent policy específica criada no passo 7.2, não o token do Fleet
  Server.
- **Monitor fica "Pending" e nunca roda**: confira se a Private Location está
  com status "Healthy" em Settings > Private Locations; se não, o agente pode
  não ter se enrolado corretamente.
- **`docker compose --profile synthetics` não reconhece o profile**: exige
  Docker Compose v2.20+; atualize o Docker Desktop/Engine.

## 15. Referências oficiais

- Monitor resources on private networks: https://www.elastic.co/docs/solutions/observability/synthetics/monitor-resources-on-private-networks
- Create monitors with a Synthetics project: https://www.elastic.co/docs/solutions/observability/synthetics/create-monitors-with-projects
- Run Elastic Agent in a container: https://www.elastic.co/docs/reference/fleet/elastic-agent-container
- Synthetic monitoring (overview): https://www.elastic.co/docs/solutions/observability/synthetics
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Ambiente de **estudo/demonstração**, não de produção (TLS interno
  desabilitado entre alguns componentes, single-node, `FLEET_INSECURE=true`).
- A criação da agent policy e da Private Location precisa ser feita
  manualmente na interface do Kibana — não há API automatizada neste projeto
  para isso (poderia ser feito via API do Fleet, fora do escopo desta aula).
- Não inclui monitores de **browser** (que também exigem
  `elastic-agent-complete`, já usado aqui, mas com configuração adicional de
  journeys em JS/TS via `@elastic/synthetics` — ver `docs/exemplo-synthetics-project.md`).
