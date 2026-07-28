# Plataforma do curso

Ambiente **único** que serve todas as 24 lições. Sobe uma vez, com **um
comando**, e você passa o curso inteiro trabalhando em cima dele — do
jeito que o laboratório oficial da Elastic funciona: o ambiente já está
pronto, e a aula é o **exercício**.

```bash
cp .env.example .env      # opcional: o subir.sh faz isso sozinho
./scripts/subir.sh
```

Em ~5 minutos você tem: Elasticsearch, Kibana, Fleet Server (com APM na
8200), um agente enrolado coletando o host, a loja de demonstração
(web + API + pagamento), geradores de log e tráfego, e dados de exemplo
indexados.

## O que o `subir.sh` resolve por você

No 9.x várias etapas deixaram de ser automáticas. Todas já estão tratadas:

| # | Etapa | O que aconteceria sem ela |
|---|---|---|
| 1 | senha do `kibana_system` via API | Kibana não autentica (`security_exception`) |
| 2 | service token do Fleet | Fleet Server não sobe |
| 3 | `POST /api/fleet/setup` | Fleet não inicializa |
| 4 | policy do Fleet Server | trava em `Waiting on policy` para sempre |
| 5 | Fleet Server host | `Missing URL for Fleet Server host`, sem enrollment token |
| 6 | output → `elasticsearch:9200` | agentes tentam `localhost:9200` e descartam dados (`Drop batch`) |
| 7 | integração APM em `0.0.0.0:8200` | APM Server mudo |
| 8 | policy + enrollment do agente | nenhum dado de host |
| 9 | dados via `_bulk` | a API de sample data do Kibana é interna e recusa chamadas externas |

Também já vêm resolvidos: `encryptionKey` do Kibana, agentes em
`https://fleet-server:8220` + `FLEET_INSECURE` (HTTP puro dá *TLS
handshake error*), e ausência da chave `version:` (obsoleta no Compose v2).

## Comandos

| Comando | O que faz |
|---|---|
| `./scripts/subir.sh` | sobe tudo (idempotente — pode rodar de novo) |
| `./scripts/validar.sh` | checa plataforma, dados e aplicações |
| `./scripts/carregar-dados.sh` | recarrega os dados de exemplo |
| `./scripts/parar.sh` | para os containers, preserva os dados |
| `./scripts/limpar.sh` | apaga tudo (containers + volumes + tokens) |

## Acessos

| Serviço | URL | Credenciais |
|---|---|---|
| Kibana | http://localhost:5601 | `elastic` / valor de `ELASTIC_PASSWORD` |
| Elasticsearch | http://localhost:9200 | idem |
| APM Server | http://localhost:8200 | secret token do `.env` |
| Loja (web) | http://localhost:8080 | — |
| Loja (API) | http://localhost:5000 | — |

## Requisitos

Docker Engine 24+ com Compose v2 · 6 GB de RAM livres ·
portas 5601, 9200, 8220, 8200, 8080, 5000 ·
Linux/WSL: `sudo sysctl -w vm.max_map_count=262144`.

> **Windows / Git Bash:** rode `export MSYS_NO_PATHCONV=1` uma vez por
> sessão. Sem isso o Git Bash converte caminhos de container
> (`/var/log/app`) em caminhos do Windows (`C:/Program Files/Git/...`).

## Problemas comuns

- **`vm.max_map_count`** — Elasticsearch reiniciando em loop: rode o
  `sysctl` acima (no Docker Desktop/WSL2, dentro do WSL).
- **Porta em uso** — `docker compose down` de outros labs ou ajuste a
  porta no `docker-compose.yml`.
- **Fleet Server não fica online** — `docker compose logs fleet-server`.
  Se aparecer `Waiting on policy`, rode `./scripts/subir.sh` de novo:
  ele recria a policy.
- **Agente sem dados** — confira em Fleet > Settings se o output está em
  `http://elasticsearch:9200` (o `subir.sh` corrige isso automaticamente).
