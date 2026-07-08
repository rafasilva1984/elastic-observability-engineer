# Exemplo opcional (avançado): monitor lightweight via Synthetics Project
#
# Isso NÃO é necessário para acompanhar a Aula 1 - a demonstração principal
# usa a Synthetics UI diretamente no Kibana. Este arquivo é só uma referência
# para quem já quiser versionar monitores como código (infra as code), usando
# o pacote oficial @elastic/synthetics.
#
# Fonte oficial: https://www.elastic.co/docs/solutions/observability/synthetics/create-monitors-with-projects
#
# Passo a passo (fora do escopo do docker-compose deste projeto):
#   1) npx @elastic/synthetics init meu-projeto-synthetics
#   2) Edite o arquivo lightweight/http.monitor.yml gerado, com algo assim:
#
#      - id: http-app-exemplo
#        name: HTTP - App Exemplo (via projeto)
#        type: http
#        urls: ["http://app-exemplo:80"]
#        schedule: "@every 1m"
#        privateLocations: ["Private Location - Aula 1"]
#
#   3) Gere uma Project API Key no Kibana (Synthetics > Settings > Project API Keys).
#   4) Rode: npx @elastic/synthetics push --auth $SYNTHETICS_API_KEY --url http://localhost:5601
#
# Esse fluxo é ideal para quem quer versionar monitores no mesmo repositório
# da aplicação monitorada (GitOps), mas exige Node.js instalado localmente.
