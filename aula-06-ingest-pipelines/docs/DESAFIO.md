# Desafios — Aula 6 · Ingest Pipelines

## 🟢 Desafio guiado
Refaça o pipeline da aula sem o vídeo: grok → convert → date → geoip →
on_failure + Simulate (README + scripts/).

## 🔒 Desafio autônomo — "Create a new Ingest pipeline"
*(mesmo nome do challenge oficial EOE 4.1)*

**Missão:** crie o pipeline `nginx-access` que estruture as linhas do
desafio da Aula 3 (formato Nginx combined):
1. Grok extraindo: IP de origem, método, caminho, status e bytes.
2. `convert` do status e bytes para número.
3. `date` levando o timestamp da linha para `@timestamp`.
4. Processor **user_agent** sobre o campo do agente (pesquise na doc —
   ele não apareceu na aula de propósito).
5. `on_failure` com tag `falha_parsing`.
6. Prove com a Simulate API usando as 3 linhas do desafio da Aula 3.

### Critérios de aceite
- [ ] Simulate mostra os 5 campos estruturados + user_agent.name
- [ ] Linha inválida (invente uma) preservada com a tag
- [ ] Você consegue explicar por que o `date` precisa do formato
      `dd/MMM/yyyy:HH:mm:ss Z`

### Validação
`POST _ingest/pipeline/nginx-access/_simulate` com as 3 linhas + 1 quebrada.

### Dica (só se travar)
Existe um pattern grok pronto para combined log — procure por
`HTTPD_COMBINEDLOG` na doc de grok patterns.

⏱ 35 min · Revisão: Vídeo 6 · doc: ingest processors (grok, user_agent)
