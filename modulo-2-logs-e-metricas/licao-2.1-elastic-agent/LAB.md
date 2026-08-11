# Lab 2.1 — Inspecionar, configurar e diagnosticar o Elastic Agent

> Espelha o **Lab 2.1** do curso oficial. A plataforma já está no ar:
> aqui você **pratica o tema**, não monta ambiente.

A plataforma já subiu com um agente enrolado (`agente-host-onp`) na policy **ONP - Host**, além do próprio Fleet Server. Aqui você vai abrir o capô: entender o que está rodando, adicionar uma integração e treinar o diagnóstico.

**Pré-requisito:** `../../plataforma/scripts/validar.sh` sem falhas.
**Tempo-alvo:** 30 min · **Documentação oficial liberada** (como na prova).

---

## 🟢 Parte guiada

### Exercício 1 — Ler o estado do parque

Em **Fleet > Agents**, identifique quantos agentes existem, em qual policy cada um está e a versão. Depois abra **Agent policies** e veja quantas integrações cada policy tem.

**Como validar:** Você identifica 2 agentes Healthy (Fleet Server e o host) e sabe dizer a policy de cada um.

### Exercício 2 — Anatomia da policy

Abra a policy **ONP - Host**. Liste as integrações que vieram nela por padrão e o que cada uma coleta. Encontre onde ficam os *data streams* gerados.

**Como validar:** Você localiza a integração **System** e sabe dizer que ela nasce junto com a policy.

### Exercício 3 — Adicionar uma integração

Adicione a integração **Docker** à policy ONP - Host (métricas de containers). Salve e observe a policy subir de revisão.

**Como validar:** A revisão da policy aumenta e o agente recebe a nova configuração em ~1 min.

### Exercício 4 — Diagnóstico pelo container

Rode: `docker exec agente-host-onp elastic-agent status` e depois `docker exec agente-host-onp elastic-agent diagnostics`. Interprete a saída: quais componentes estão HEALTHY?

**Como validar:** Você lê o status por componente (filestream, system/metrics, etc.), não só "o agente está no ar".

> **Nota:** é esperado ver `docker/metrics` como **DEGRADED** ("failed to connect to the
> docker API at unix:///var/run/docker.sock") — o container do agente nesta plataforma não
> tem o socket do Docker montado. Não é erro de configuração seu; é o próprio cenário de
> diagnóstico: treine reconhecer, pela mensagem, que a causa é falta de acesso ao socket, não
> um problema na integração em si.

### Exercício 5 — Onde o dado cai

No Dev Tools, rode `GET _cat/indices/.ds-metrics-system*?v` e `GET _data_stream/metrics-system.cpu-default`. Relacione: integração → dataset → data stream.

**Como validar:** Você aponta o data stream exato criado pela integração System.

---

## 🔒 Desafio autônomo

Provoque uma falha silenciosa e diagnostique. **Nesta plataforma o output "default" vem
preconfigurado via variável de ambiente do Kibana e não pode ser editado** (Fleet recusa com
"Preconfigured output ... cannot be updated outside of kibana config file") — então crie um
**novo** output em **Fleet > Settings > Outputs > Add output** apontando para um host inválido
(ex.: `http://elasticsearch-errado:9200`), depois abra **Agent policies > ONP - Host >
Settings** e troque o *output for integrations* para esse novo output. Salve e observe.
Responda: (1) o agente continua **Healthy** na UI? (2) o dado continua chegando? (3) qual
mensagem aparece nos logs do container? Depois **restaure** a policy para usar o output
default novamente e prove a recuperação. Escreva a lição aprendida em uma frase.

> Sem passo a passo — é assim que o exame cobra. Se travar, a documentação
> oficial está liberada: treine **achar**, não decorar.

---

## Checklist de conclusão

- [ ] Ler o estado do parque
- [ ] Anatomia da policy
- [ ] Adicionar uma integração
- [ ] Diagnóstico pelo container
- [ ] Onde o dado cai
- [ ] Desafio autônomo concluído e validado
- [ ] Quiz do [SUMMARY.md](./SUMMARY.md) respondido
