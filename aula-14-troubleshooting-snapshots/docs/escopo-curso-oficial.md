# Escopo — Aula 14 · APM Troubleshooting + Searchable Snapshots
(módulos EOE 3.3 e 7.3)

Fontes oficiais:
- Common problems with APM (checklist de "no data": integração/host,
  0.0.0.0 em Docker, 401 de secret token, 503 Queue is full e a leitura
  503×202, mapping explosion / limit of total fields, logs do dataset
  elastic_agent.apm_server):
  elastic.co/docs/troubleshoot/observability/apm/common-problems
- Searchable snapshots (fully mounted/full_copy × partially
  mounted/shared_cache; uso pelo ILM; force-merge para 1 segmento;
  não deletar snapshot montado — clonar; réplicas 0; repositórios
  suportados): elastic.co/docs/deploy-manage/tools/snapshot-and-restore/searchable-snapshots
- Snapshot and restore (repositório fs / path.repo, verify, create):
  elastic.co/docs/deploy-manage/tools/snapshot-and-restore
