# Desafios — Aula 12 · Dashboards Interativos

## 🟢 Desafio guiado
Refaça o par Executivo → Operacional sem o vídeo
(docs/roteiro-interatividade.md, de memória).

## 🔒 Desafio autônomo — "Interatividade em outro domínio"
**Missão:** repita o PADRÃO (não os passos) sobre o sample de
**eCommerce** (`kibana_sample_data_ecommerce`):
1. Dashboard executivo: receita total + série de pedidos + top categorias,
   com 2 controls à sua escolha (um deles Range slider — escolha o campo
   certo!) e chain ligado.
2. Dashboard operacional: tabela de pedidos detalhada.
3. Dashboard drilldown com contexto de origem completo.
4. **Discover drilldown** no operacional (novo — pesquise na doc).

### Critérios de aceite
- [ ] Range slider num campo NUMÉRICO válido do eCommerce
- [ ] Clique no executivo → operacional já filtrado
- [ ] Discover drilldown levando filtros + período

### Validação
Fluxo completo em 3 cliques: filtrar país → drilldown → Discover.

### Dica (só se travar)
`taxful_total_price` é numérico; categoria é keyword.

⏱ 35 min · Revisão: Vídeo 12 · doc: dashboards/drilldowns
