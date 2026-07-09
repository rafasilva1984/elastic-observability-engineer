# Escopo do curso oficial — Logs

Fonte: Elastic Observability Engineer — Self-Paced Learning Plan
(learn.elastic.co), curso "Logs".

Descrição oficial (em nossas palavras): coletar, explorar e analisar dados de
log com o Elastic Observability — configurando integrações para ingerir logs
de componentes de aplicação, usando o Discover para consultar e filtrar, e
trabalhando com dashboards curados para visualizar a atividade do sistema.

Mapeamento desta aula:

- **Integrações de ingestão** → Custom Logs (Filestream) via Fleet
  (https://docs.elastic.co/integrations/filestream), com nota sobre a
  versão clássica deprecated (https://docs.elastic.co/integrations/log).
- **Discover para consultar/filtrar** → KQL sobre data_stream.dataset e
  message (https://www.elastic.co/docs/explore-analyze/discover/discover-get-started).
- **Dashboards curados** → entregues pela integração System, habilitada na
  própria Agent Policy da aula.
- **Extra do outline oficial de 24h** distribuído aqui: visão introdutória
  de Machine Learning aplicado a logs (categorização/anomalia) — apresentado
  como preview, com aprofundamento em módulos posteriores.

Nota de fronteira: a estruturação dos campos do log (parsing) pertence ao
curso "Extracting and Transforming Events" e é tratada no Vídeo 6.
