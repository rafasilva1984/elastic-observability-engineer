# Desafios — Aula 3 · Coleta de Logs

## 🟢 Desafio guiado
Refaça a coleta da aula sem o vídeo: Custom Logs (Filestream) do
app-gerador com dataset `app_exemplo` (README, passos 6–9).

## 🔒 Desafio autônomo — "Loading events (Nginx access.log)"
*(mesmo desafio do lab oficial EOE 2.2)*

**Missão:** crie o arquivo `/var/log/app/nginx-access.log` no volume do
lab com as linhas abaixo (formato combined), e configure um SEGUNDO
Custom Logs na policy com dataset `nginx_exemplo`:

```
127.0.0.1 - - [10/Jul/2026:13:55:36 -0300] "GET /produtos HTTP/1.1" 200 2326 "-" "Mozilla/5.0"
127.0.0.1 - - [10/Jul/2026:13:55:38 -0300] "GET /carrinho HTTP/1.1" 404 153 "-" "Mozilla/5.0"
127.0.0.1 - - [10/Jul/2026:13:55:40 -0300] "POST /checkout HTTP/1.1" 500 89 "-" "curl/8.4"
```

### Critérios de aceite
- [ ] Data stream `logs-nginx_exemplo-default` criado
- [ ] 3 documentos visíveis no Discover
- [ ] Você sabe dizer POR QUE o conteúdo ainda está "cru" em `message`
      (gancho: parsing é o Vídeo 6!)

### Validação
`GET _cat/indices/.ds-logs-nginx_exemplo-*?v` retorna docs.count = 3.

### Dica (só se travar)
O caminho do arquivo é o de DENTRO do container do agente.

⏱ 25 min · Revisão: Vídeo 3 · doc: filestream input / custom logs
