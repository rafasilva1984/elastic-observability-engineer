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

Ao final, **sempre** rode:

```bash
./scripts/validar.sh
```

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
| 7 | integração APM com a **versão do pacote resolvida** | `"version":""` devolve 400 e a porta 8200 fica muda **em silêncio** |
| 8 | policy + enrollment do agente | nenhum dado de host |
| 9 | dados via `_bulk` | a API de sample data do Kibana é interna e recusa chamadas externas |

Também já vêm resolvidos: `encryptionKey` do Kibana, agentes em
`https://fleet-server:8220` + `FLEET_INSECURE` (HTTP puro dá *TLS
handshake error*), e ausência da chave `version:` (obsoleta no Compose v2).

**Nenhum passo falha em silêncio.** Toda chamada de API confere o código
HTTP, e o resumo final diz quantos problemas apareceram. Se o `subir.sh`
terminar com erro, ele sai com código diferente de zero.

## Comandos

| Comando | O que faz |
|---|---|
| `./scripts/subir.sh` | sobe tudo (idempotente — pode rodar de novo com segurança) |
| `./scripts/validar.sh` | checa plataforma, APM, dados e aplicações |
| `./scripts/carregar-dados.sh` | carrega os dados de exemplo (não duplica) |
| `./scripts/carregar-dados.sh --forcar` | apaga o índice e reindexa do zero |
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

### Erros de `localhost:9200` no log do Fleet Server — **isso é normal**

Nos primeiros ~40 segundos, `docker compose logs fleet-server` mostra:

```
Failed Elasticsearch output configuration test, using bootstrap values.
  output: {"Elasticsearch":{"Hosts":["localhost:9200"],...}}
bulk indexer flush error: dial tcp 127.0.0.1:9200: connect: connection refused
Exporting failed. Dropping data. dropped_items: 109
```

**Não é defeito.** É a janela de bootstrap: o Elastic Agent sobe os
componentes de monitoring antes de receber a policy do Fleet, e nesse
intervalo usa o valor padrão `localhost:9200` — que, dentro do container,
é ele mesmo. Quando a policy chega (revisão 2 ou 3), o output correto
entra e os erros param.

Como confirmar que passou: espere 1 minuto e rode

```bash
docker compose logs --since 2m fleet-server | grep -c "connection refused"
```

Se der `0`, está resolvido. O que **não** pode acontecer é isso continuar
depois de 2 minutos — aí veja o item seguinte.

### Agente sem dados / `Drop batch` que não para

Confira o output do Fleet:

```bash
curl -s -u elastic:$ELASTIC_PASSWORD \
  http://localhost:5601/api/fleet/outputs -H "kbn-xsrf: true"
```

Tem de aparecer `"hosts":["http://elasticsearch:9200"]`. Se aparecer
`localhost:9200`, o Kibana não aplicou a preconfiguração — recrie o
ambiente com `./scripts/limpar.sh && ./scripts/subir.sh`.

> O output desta plataforma é **preconfigurado** pelo Kibana
> (`XPACK_FLEET_AGENTS_ELASTICSEARCH_HOST` no compose). Isso significa que
> ele aparece **travado para edição** em Fleet > Settings > Outputs, e que
> qualquer `PUT` na API devolve 400. É intencional: impede que o aluno
> quebre o ambiente sem querer.

### Porta 8200 não responde / APM não recebe traces

Sintoma: as lições 3.1, 3.2 e 3.3 não mostram nenhum serviço em
Observability > APM, e `loja-api`/`pagamento` não conseguem enviar traces.

Confira se a integração existe:

```bash
curl -s -u elastic:$ELASTIC_PASSWORD \
  "http://localhost:5601/api/fleet/package_policies?perPage=200" \
  -H "kbn-xsrf: true" | grep -o '"name":"apm-onp"'
```

Se não retornar nada, rode `./scripts/subir.sh` de novo — ele é
idempotente e recria só o que falta.

> **Cuidado com a checagem manual.** `curl http://localhost:8200` devolve
> **corpo vazio** quando há `secret_token` configurado, então um teste do
> tipo `curl -s http://localhost:8200 | grep -q .` acusa falha num serviço
> que está perfeito. O jeito certo é olhar o código HTTP:
>
> ```bash
> curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://localhost:8200
> ```
>
> `401` ou `200` = está no ar. `000` = porta fechada.

### `vm.max_map_count`

Elasticsearch reiniciando em loop: rode o `sysctl` acima (no Docker
Desktop/WSL2, dentro do WSL).

### Porta em uso

`docker compose down` de outros labs, ou ajuste a porta no
`docker-compose.yml`.

### Fleet Server não fica online

```bash
docker compose logs fleet-server
```

Se aparecer `Waiting on policy`, rode `./scripts/subir.sh` de novo: ele
recria a policy.

### Dados de exemplo duplicados

O `carregar-dados.sh` tem trava: se o índice já tiver 700+ documentos,
ele não faz nada. Para reindexar do zero:

```bash
./scripts/carregar-dados.sh --forcar
```
