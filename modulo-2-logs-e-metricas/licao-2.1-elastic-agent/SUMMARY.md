# Summary — Lição 2.1 · Elastic Agent

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- O Elastic Agent é uma forma única e unificada de coletar logs, métricas e outros dados de um host
- As integrações que acompanham o agente simplificam a conexão com serviços e sistemas externos
- O Fleet Server é o componente que conecta os agentes ao Fleet
- A Fleet UI, no Kibana, centraliza o gerenciamento do parque de agentes
- A policy é o contrato de configuração: mudou a policy, o agente se reconfigura sozinho
- Agente Healthy não significa dado chegando — output errado descarta em silêncio

## Quiz

1. Qual a diferença entre service token e enrollment token?
   <details><summary>resposta</summary>

   O **service token** autentica o *Fleet Server* no Elasticsearch. O **enrollment token** é o que um *agente* usa para se inscrever numa policy do Fleet. São credenciais de camadas diferentes.
   </details>

2. Verdadeiro ou falso: se o agente aparece Healthy no Fleet, os dados estão chegando ao Elasticsearch.
   <details><summary>resposta</summary>

   **Falso.** Healthy diz que o agente está se comunicando com o Fleet. Se o *output* estiver errado, ele coleta e descarta (`Drop batch`) — saudável e mudo ao mesmo tempo.
   </details>

3. O que acontece com o agente quando você adiciona uma integração à policy dele?
   <details><summary>resposta</summary>

   A policy sobe de revisão e o agente recebe a nova configuração automaticamente no próximo check-in (segundos a ~1 min), sem reinstalar nada.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
