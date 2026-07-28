# Lab 3.3 — Diagnosticar o APM que ficou mudo

> Espelha o **Lab 3.3** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

Você vai QUEBRAR de propósito e consertar com método. Antes de tudo, registre o estado saudável: é a sua linha de base.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Linha de base

Anote o estado saudável: service map com `loja-api → pagamento`, e o resultado de `GET traces-apm*/_count` (repita duas vezes com 1 min de intervalo para ver crescendo).

**Como validar:** Você tem dois números e um print do mapa completo.

### Exercício 2 — Injetar a falha

Recrie o serviço de pagamento com o token errado:

```bash
cd ../../plataforma
docker compose stop pagamento
docker run -d --name pagamento-quebrado --network onp-net \
  -e ELASTIC_APM_SERVICE_NAME=pagamento \
  -e ELASTIC_APM_SERVER_URL=http://fleet-server:8200 \
  -e ELASTIC_APM_SECRET_TOKEN=token-errado-de-proposito \
  $(docker compose images -q pagamento)
```

**Como validar:** Em ~2 min o serviço `pagamento` some do service map — mas a aplicação continua respondendo.

### Exercício 3 — Passo 1 e 2 do checklist

(1) O servidor está de pé? `curl http://localhost:8200`. (2) O agente entrega? `docker logs pagamento-quebrado 2>&1 | grep -iE '401|unauthorized|secret'`.

**Como validar:** O :8200 responde (servidor OK) e o log do agente mostra a rejeição de autenticação.

### Exercício 4 — Passo 3 e 4

(3) O APM Server reclama? `docker compose logs fleet-server | grep -i apm-server`. (4) Chega dado novo? conte `traces-apm*` filtrando `service.name: pagamento` nos últimos 5 minutos.

**Como validar:** A contagem do serviço quebrado está parada — diagnóstico fechado: secret token.

### Exercício 5 — Corrigir e PROVAR

Remova o container quebrado e volte o original (`docker rm -f pagamento-quebrado && docker compose up -d pagamento`). Aguarde ~2 min.

**Como validar:** O serviço reaparece no service map e a contagem volta a crescer. Diagnóstico só termina na prova.

---

## 🔒 Desafio autônomo

Repita o exercício com um defeito DIFERENTE: em vez do token, aponte o `ELASTIC_APM_SERVER_URL` para uma porta errada (ex.: 8201). Diagnostique com o mesmo checklist e responda: **em qual passo** esse defeito se manifesta de forma diferente do defeito de token, e por quê? (dica: um mata a autorização, o outro mata a conexão).

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Linha de base
- [ ] Injetar a falha
- [ ] Passo 1 e 2 do checklist
- [ ] Passo 3 e 4
- [ ] Corrigir e PROVAR
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
