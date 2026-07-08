# Escopo do curso oficial — Interactive Dashboards

Fonte: Learning Plan oficial (learn.elastic.co): tornar dashboards
interativos com controls (filtros para o consumidor) e drilldowns
(navegação por clique com contexto preservado).

Mapeamento (fontes oficiais):
- Add filter controls: Options list, Range slider (numéricos), Time slider
  (1 por dashboard, global time range, play/animação); settings Chain
  controls, Apply selections automatically, Validate user selections;
  controle fixado × painel livre
  (elastic.co/guide/en/kibana/current/add-controls.html)
- Add drilldowns: 3 tipos — Dashboard (com "Use filters and query from
  origin" e "Use date range from origin"), URL (template com variáveis
  {{event.value}}, {{event.from}}/{{event.to}}, {{context.panel.*}};
  triggers Single click/Range selection) e Discover; limitação: campos
  computados não disparam drilldown
  (elastic.co/docs/explore-analyze/dashboards/drilldowns)
Nota: o lab usa licença trial (xpack trial no compose), então todos os
recursos ficam disponíveis para estudo.
