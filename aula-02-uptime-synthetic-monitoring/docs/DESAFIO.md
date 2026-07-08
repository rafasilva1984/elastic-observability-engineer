# Desafios — Aula 2 · Synthetic Monitoring

## 🟢 Desafio guiado
Refaça o lab da aula sem o vídeo: private location + monitores TCP/ICMP +
browser monitor (README, passos 6–9).

## 🔒 Desafio autônomo — "Monitorando um segundo serviço"
**Missão:** suba um segundo Nginx (`nginx2`, porta 8081, mesma rede
`onp-net`) editando o compose, e crie para ele:
1. Um monitor **HTTP** (não TCP!) checando a cada 1 min pela private
   location, validando status 200.
2. Derrube o `nginx2` (`docker compose stop nginx2`) e observe o monitor
   ficar **down**.
3. Suba de novo e confirme a recuperação.

### Critérios de aceite
- [ ] Monitor HTTP up com o serviço no ar
- [ ] Transição up → down → up visível na timeline do Synthetics
- [ ] Screenshot/waterfall do check disponível

### Validação
Synthetics > monitor > histórico mostra os 3 estados no horário do teste.

### Dica (só se travar)
Monitor HTTP tem campo de status esperado — procure "response status".

⏱ 25 min · Revisão: Vídeo 2 · doc: solutions/observability/synthetics
