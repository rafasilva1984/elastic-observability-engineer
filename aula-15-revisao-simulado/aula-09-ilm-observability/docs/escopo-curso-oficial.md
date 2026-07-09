# Escopo do curso oficial — Index Lifecycle Management for Observability Data

Fonte: Learning Plan oficial (learn.elastic.co): como o Elasticsearch
gerencia índices automaticamente pelo ciclo de vida com políticas de ILM —
políticas padrão, transições de fase e dados movendo-se por hot, warm e
delete — essencial para custo de armazenamento e performance.

Mapeamento (fontes oficiais):
- Visão geral ILM: fases hot/warm/cold/frozen/delete; ações rollover, shrink,
  forcemerge, delete; data streams recomendados; políticas padrão criadas
  por integrações/Elastic Agent
  (elastic.co/docs/manage-data/lifecycle/index-lifecycle-management)
- Tutorial oficial "Automate rollover with ILM": política -> template com
  data_stream:{} + index.lifecycle.name -> stream -> verificação
- Rollover: backing indices .ds-<stream>-<data>-00000N, write index,
  generation; condições max_docs/max_age/max_primary_shard_size; só rola
  com >=1 doc (elastic.co/docs/reference/elasticsearch/index-lifecycle-actions/ilm-rollover)
- Fases e ações: min_age relativo AO ROLLOVER; poll_interval padrão 10min
  (elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/index-lifecycle)
- ILM Explain API + Kibana Index Management; políticas built-in
  logs@lifecycle e metrics@lifecycle
  (elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/policy-view-status)
- Snapshots/searchable snapshots: visão geral (fase frozen), conforme
  outline oficial de 24h — aprofundamento fora do escopo da aula.
