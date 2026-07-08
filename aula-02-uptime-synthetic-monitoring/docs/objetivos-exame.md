# Ponto de atenção: Uptime app (deprecated) vs Synthetics

Fonte: Elastic Docs — Synthetic monitoring
https://www.elastic.co/docs/solutions/observability/synthetics

A partir da versão **8.15** do Elastic Stack, a app **Uptime** está marcada
como *deprecated* na documentação oficial, e não está disponível no
Elastic Cloud Serverless. A ferramenta atual para esse domínio é a app
**Synthetics**, que substitui a configuração manual via `heartbeat.yml` por:

- Criação de monitores diretamente na **Synthetics UI** do Kibana.
- Uso de **Private Locations** (Elastic Agent + Fleet) para rodar monitores
  na sua própria infraestrutura.
- Uso opcional de **Synthetics projects** (`@elastic/synthetics` CLI) para
  versionar monitores como código.

O Learning Plan oficial da Elastic (Self-Paced Learning Plan para o exame
Observability Engineer) já reflete essa mudança: o curso se chama
**"Synthetic monitoring with Elastic"**, não "Heartbeat" ou "Uptime".

> Recomendação: ao se preparar para o exame, confirme na FAQ oficial de
> certificação qual versão do stack está em vigor no momento da sua prova,
> já que o formato do exame é performance-based e pode referenciar uma
> versão específica.
