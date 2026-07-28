# Summary — Lição 1.2 · Uptime

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- O Heartbeat checa disponibilidade por ICMP, TCP ou HTTP — do mais raso ao mais próximo do usuário
- Uma única instância consegue monitorar múltiplos endpoints
- A app de Uptime dá a leitura clara dos dados do Heartbeat: status, histórico e duração
- Dá para acompanhar tendência e ainda vigiar expiração de certificado TLS
- Private location executa a checagem de dentro da sua rede — essencial para serviços internos
- Alertas podem ser criados sobre status do monitor e sobre TLS

## Quiz

1. Cite os três tipos de monitor do Heartbeat.
   <details><summary>resposta</summary>

   **ICMP** (o host responde?), **TCP** (a porta está aberta?) e **HTTP** (a aplicação responde e com o conteúdo esperado?).
   </details>

2. Verdadeiro ou falso: a app de Uptime só mostra quais serviços estão no ar agora.
   <details><summary>resposta</summary>

   **Falso.** Ela mostra também histórico, duração das checagens, tendência e validade de certificados — é análise, não só um sinal verde/vermelho.
   </details>

3. Verdadeiro ou falso: você precisa instalar o Heartbeat em cada sistema que quer monitorar.
   <details><summary>resposta</summary>

   **Falso.** A checagem é feita DE FORA. Uma instância (ou uma private location) monitora muitos endpoints — é justamente a visão do cliente.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
