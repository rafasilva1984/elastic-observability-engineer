# Lab 2.2 — Coletar e explorar os logs da aplicação

> Espelha o **Lab 2.2** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

O container `gerador-logs-onp` escreve continuamente em `/var/log/app/app.log` (formato: `TS LEVEL service=… user=… duration_ms=… msg="…"`) e esse volume já está montado no agente. Falta configurar a coleta.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 35 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Confirmar a fonte

Verifique que o arquivo existe e cresce: `docker exec agente-host-onp tail -3 /var/log/app/app.log`. (No Git Bash use `MSYS_NO_PATHCONV=1` antes do comando.)

**Como validar:** Três linhas de log aparecem, com timestamps recentes.

### Exercício 2 — Configurar Custom Logs

Na policy **ONP - Host**, adicione a integração **Custom Logs (Filestream)** com caminho `/var/log/app/app.log` e dataset `app_exemplo`.

**Como validar:** A integração aparece na policy e a revisão sobe.

### Exercício 3 — Provar a chegada

No Dev Tools: `GET logs-app_exemplo-default/_count`. Depois abra o Discover na data view `logs-*` e filtre `data_stream.dataset: "app_exemplo"`.

**Como validar:** O count sai do zero e cresce a cada refresh (o gerador escreve 1 linha/segundo).

### Exercício 4 — Investigar de verdade

Responda usando o Discover: (1) quantos eventos ERROR na última hora? (2) qual `service` aparece mais? (3) existe algum evento com `duration_ms` acima de 2000?

**Como validar:** As três respostas saem de buscas no campo `message` — e você percebe o incômodo de consultar texto não estruturado.

### Exercício 5 — Sentir a dor que o módulo 4 resolve

Tente montar uma visualização de "média de duration_ms por serviço". Não vai dar: o dado está dentro de `message`, como texto.

**Como validar:** Você escreve, com suas palavras, por que o parsing na ingestão é obrigatório — esse é o gancho da lição 4.1.

---

## 🔒 Desafio autônomo

Colete um SEGUNDO arquivo de log, com formato diferente. Crie `/var/log/app/nginx-access.log` dentro do container do gerador com 3 linhas no formato *combined* (busque o formato na documentação oficial), configure uma nova entrada de Custom Logs com dataset `nginx_exemplo` e prove que os documentos chegaram. Responda: por que usar um dataset separado em vez de jogar tudo no mesmo?

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Confirmar a fonte
- [ ] Configurar Custom Logs
- [ ] Provar a chegada
- [ ] Investigar de verdade
- [ ] Sentir a dor que o módulo 4 resolve
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
