# Plataforma do curso

Ambiente **único** que serve todas as 24 lições. Sobe uma vez, com **um
comando**, e você passa o curso inteiro trabalhando em cima dele — do jeito
que o laboratório oficial da Elastic funciona: o ambiente já está pronto, e a
aula é o **exercício**.

```bash
./scripts/subir.sh
./scripts/validar.sh
```

Em ~5 minutos você tem: Elasticsearch, Kibana, Fleet Server com APM na 8200,
um agente coletando métricas do host, a loja de demonstração (web + API +
pagamento), geradores de log e tráfego, e 720 documentos de exemplo.

O `validar.sh` no fim **não é opcional**. Ele é o que diferencia "subiu" de
"funcionou".

## O que o `subir.sh` resolve por você

No 9.x várias etapas deixaram de ser automáticas. Todas já estão tratadas:

| # | Etapa | O que aconteceria sem ela |
|---|---|---|
| 1 | senha do `kibana_system` via API | Kibana não autentica (`security_exception`) |
| 2 | service token do Fleet | Fleet Server não sobe |
| 3 | `POST /api/fleet/setup` | Fleet não inicializa |
| 4 | policy do Fleet Server | trava em `Waiting on policy` para sempre |
| 5 | Fleet Server host | `Missing URL for Fleet Server host`, sem enrollment token |
| 6 | conferência do output | agentes tentam `localhost:9200` e descartam dados |
| 7 | integração APM lendo os padrões do pacote | ver **A armadilha do APM** abaixo |
| 8 | `?sys_monitoring=true` na policy do host | policy nasce **vazia**: agente enrola, fica Healthy e não coleta nada |
| 9 | dados via `_bulk` em um processo `awk` | a API de sample data do Kibana recusa chamadas externas |

**Nenhum passo falha em silêncio.** Toda chamada de API confere o código HTTP,
e o script sai com código diferente de zero se algo deu errado.

### A armadilha do APM

Quando você manda `vars` explicitamente ao criar a integração, o Fleet usa
**só aquelas** e não preenche os padrões do pacote. Cada bloco opcional do
`apm-server` que ficar sem sua flag renderiza com valores nulos e o APM Server
recusa a configuração inteira — um erro de cada vez:

```
faltou tls_enabled            -> certificate file not configured
                                 accessing 'apm-server.ssl'
faltou tail_sampling_enabled  -> no policies specified accessing
                                 'apm-server.sampling.tail'
```

O pacote tem dezenas de vars, e a lista muda entre versões. Em vez de
persegui-las, o `subir.sh` **pergunta ao próprio Fleet**: cria uma package
policy descartável sem `inputs` numa agent policy temporária sem agentes, lê o
conjunto completo de padrões da resposta, e sobrescreve apenas `host` e
`secret_token`. Qualquer var nova que a Elastic acrescentar vem junto sozinha.

`host` tem de ser `0.0.0.0:8200`. O padrão do pacote é `localhost:8200`, e
dentro do container isso é 127.0.0.1 — inalcançável tanto pelo mapeamento de
portas do Docker quanto pelos outros serviços da rede.

## Comandos

| Comando | O que faz |
|---|---|
| `./scripts/subir.sh` | sobe tudo (idempotente — pode rodar de novo) |
| `./scripts/validar.sh` | checa plataforma, APM, dados e aplicações |
| `./scripts/corrigir-apm.sh` | recria só a integração APM |
| `./scripts/corrigir-apm.sh --remover` | remove a integração APM (rollback) |
| `./scripts/carregar-dados.sh` | carrega os dados de exemplo (não duplica) |
| `./scripts/carregar-dados.sh --forcar` | apaga o índice e reindexa |
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

---

## Windows e Git Bash — leia antes de escrever qualquer script

Esta seção existe porque três problemas reais desta plataforma vieram daqui, e
nenhum deles dá mensagem de erro clara.

### `MSYS_NO_PATHCONV=1` é necessário, mas tem preço

```bash
export MSYS_NO_PATHCONV=1     # uma vez por sessão
```

Sem isso, o Git Bash converte caminhos de container (`/var/log/app`) em
caminhos do Windows (`C:/Program Files/Git/...`) ao passar para o `docker exec`.

**O preço:** a conversão também é desligada para o `curl`. E o `curl` do PATH
no Git Bash costuma ser `/mingw64/bin/curl` — build **nativo do Windows**, que
não entende caminho POSIX sozinho. Então isto **falha em silêncio**:

```bash
curl -o /tmp/resposta.json ...      # grava em C:\tmp\, o cat lê /tmp/ e acha vazio
curl --data-binary @/tmp/dados.nd   # não acha o arquivo, HTTP 200 sem enviar nada
```

Sintoma clássico: **HTTP 200 com corpo vazio**, ou índice criado com zero
documentos. Confira qual curl você tem:

```bash
command -v curl
```

**A regra:** nunca passe caminho de arquivo para o `curl`. Use STDIN e capture
o código HTTP junto com o corpo.

```bash
# corpo por stdin, sem arquivo intermediário
gera_dados | curl -s --data-binary @- -X POST "$URL"

# corpo e código HTTP numa string só
saida=$(curl -s "$URL" -w $'\n%{http_code}')
HTTP=$(printf '%s' "$saida" | tail -n 1)
CORPO=$(printf '%s' "$saida" | sed '$d')
```

### Fork em laço é proibido

O MSYS emula `fork()` sobre a API do Windows, a **dezenas de milissegundos por
processo**. O que no Linux é elegante, aqui é meia hora de espera — e o aluno
vai achar que travou.

A versão original do `carregar-dados.sh` chamava `date`, subshells de PRNG e um
`echo | tr | awk` por campo: ~26 processos **por documento**, ~19.000 no total.
Levava mais de 15 minutos e não dava nenhum sinal de progresso.

```bash
# ERRADO: ~26 forks por iteração
while [ $i -lt 720 ]; do
  ISO=$(date -u -d "@$TS" ...)
  CAMPO=$(echo "$LISTA" | tr ' ' '\n' | awk "NR==$K")
done

# CERTO: 1 processo, 8 ms
awk -v total=720 'BEGIN { for (i=0;i<total;i++) { ... printf ... } }'
```

**A regra:** nada de `$(...)`, `date` ou pipes dentro de laço. O que for
repetitivo vai inteiro para um único `awk` ou `sed`.

### Cuidado com aritmética grande no `awk`

O `awk` usa double: inteiros são exatos só até 2⁵³ (~9×10¹⁵). O PRNG clássico
`seed * 1103515245` produz até 2,4×10¹⁸ e perde precisão **em silêncio**,
degenerando a distribuição. Use Lehmer/MINSTD, cujo produto máximo (~3,6×10¹³)
cabe com folga:

```awk
function rnd(m) { semente = (semente * 16807) % 2147483647; return int(semente % m) }
```

---

## Problemas comuns

### Erros de `localhost:9200` no log do Fleet Server — **isso é normal**

Nos primeiros ~40 segundos:

```
Failed Elasticsearch output configuration test, using bootstrap values.
bulk indexer flush error: dial tcp 127.0.0.1:9200: connect: connection refused
Exporting failed. Dropping data. dropped_items: 109
```

É a janela de bootstrap: o Elastic Agent sobe os componentes de monitoring
antes de receber a policy do Fleet e usa o padrão `localhost:9200` — que,
dentro do container, é ele mesmo. Quando a policy chega, o output correto entra
e os erros param. Confirme que passou:

```bash
docker compose logs --since 2m fleet-server | grep -c "connection refused"
```

`0` significa resolvido. O que **não** pode é continuar depois de 2 minutos.

### Agente aparece Unhealthy no Kibana

O status do agente é **agregado**: uma única unit falhada pinta o agente
inteiro de vermelho, mesmo com o Fleet Server funcionando normalmente.
Descubra qual unit e por quê:

```bash
docker compose logs --since 5m fleet-server | grep '"log.level":"error"'
docker compose logs -f fleet-server | grep 'Unit state changed'
```

Ao ler `Unit state changed ... (ANTIGO->NOVO)`, **o estado que importa é o da
direita**. `(FAILED->CONFIGURING)` é a unit se *recuperando*, não falhando — um
`grep FAILED` ingênuo confunde as duas coisas.

### Porta 8200 não responde / APM sem traces

```bash
./scripts/corrigir-apm.sh
```

Para conferir manualmente, olhe o **código HTTP**, não o corpo:

```bash
curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://localhost:8200
```

`401` ou `200` = no ar. `000` = porta fechada. Um teste do tipo
`curl -s http://localhost:8200 | grep -q .` dá falso negativo, porque com
`secret_token` o APM responde corpo vazio.

### `métricas do host: nenhum documento`

A policy do host precisa da integração **System**. Confira:

```bash
curl -s -u elastic:$ELASTIC_PASSWORD \
  "http://localhost:5601/api/fleet/agent_policies/onp-host-policy" \
  -H 'kbn-xsrf: true' | grep -o '"name":"system"'
```

Sem retorno, rode `./scripts/subir.sh` — ele detecta e acrescenta. Depois
espere 1 a 2 minutos: a coleta tem intervalo e o agente precisa buscar a nova
revisão da policy antes de começar.

### `onp-web-logs` com zero ou poucos documentos

```bash
./scripts/carregar-dados.sh --forcar
```

Se travar por minutos sem saída, você está com uma versão antiga do script que
faz fork em laço. Veja **Fork em laço é proibido** acima.

### `vm.max_map_count`

Elasticsearch reiniciando em loop: rode o `sysctl` acima. No Docker
Desktop/WSL2, dentro do WSL.

### Porta em uso

```bash
docker compose down                        # de outros labs
netstat -ano | findstr :8080               # quem está ocupando (Windows)
```

Ou ajuste a porta no `docker-compose.yml`.

## Segurança

As senhas do `.env` são **descartáveis, de laboratório**. O arquivo está no
`.gitignore` — nunca versione o seu.
