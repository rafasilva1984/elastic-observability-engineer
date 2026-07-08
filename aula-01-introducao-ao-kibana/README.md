# Aula 01 — Introdução ao Kibana

Projeto de apoio do **Vídeo 1** do curso "Preparação para o Exame Elastic
Certified Observability Engineer" — canal **Observabilidade na Prática**.

Tema: **Introdução ao Kibana** — os três recursos fundamentais que todo
engenheiro de observabilidade usa o tempo todo: **Discover** (explorar dados),
**Lens** (criar visualizações) e **Dashboards** (juntar tudo num painel).

---

## 1. Objetivo do projeto

Subir Elasticsearch + Kibana com Docker e carregar os **sample data sets
oficiais** da Elastic (eCommerce, Flights, Web Logs) para praticar a navegação
e os recursos centrais do Kibana, sem precisar montar ingestão de dados.

## 2. Arquitetura da solução

```
┌───────────────┐        ┌───────────┐
│ elasticsearch │◄───────┤  kibana   │
│  (armazena)   │  lê     │ (explora) │
└───────────────┘        └───────────┘
        ▲
        │ sample data via API
   ┌────┴─────────────────────┐
   │ carregar-dados.sh   │
   └───────────────────────────┘
```

O Elasticsearch guarda os dados; o Kibana é a interface onde você explora
(Discover), visualiza (Lens) e monta painéis (Dashboards). Os sample data são
carregados por script, via API do Kibana.

## 3. Pré-requisitos

- Docker Engine 24+ e Docker Compose v2 (`docker compose version`).
- Pelo menos 4 GB de RAM livres.
- Portas livres: `9200`, `5601`.

## 4. Como clonar o projeto

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-01-introducao-ao-kibana
```

## 5. Como configurar as variáveis de ambiente

```bash
cp .env.example .env
```

Ajuste as senhas se quiser. A versão do stack já vem fixada
(`STACK_VERSION=9.4.3` — confira a mais recente em
https://www.elastic.co/downloads/elasticsearch).

## 6. Como subir o ambiente com Docker

```bash
docker compose up -d
```

Sobe Elasticsearch e Kibana. Na primeira vez, o download das imagens pode
levar alguns minutos. Acompanhe com `docker compose ps` até ficarem `healthy`.

### 6.1 Definindo a senha do kibana_system

```bash
docker exec -it es-onp bin/elasticsearch-reset-password -u kibana_system -i
```

Cole a senha `KIBANA_PASSWORD` do seu `.env` quando solicitado, depois:

```bash
docker compose restart kibana
```

### 6.2 Carregando os sample data sets

```bash
./scripts/carregar-dados.sh
```

Isso cria os índices `kibana_sample_data_ecommerce`,
`kibana_sample_data_flights` e `kibana_sample_data_logs`, já com data views,
visualizações e dashboards prontos. (Alternativa manual: no Kibana, vá em
**Integrations > Sample Data > Other sample data sets** e clique em Add data.)

## 7. Como validar se os serviços estão funcionando

```bash
./scripts/validar-ambiente.sh
```

## 8. Como acessar as interfaces

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Kibana | http://localhost:5601 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |
| Elasticsearch (API) | http://localhost:9200 | elastic | valor de `ELASTIC_PASSWORD` no `.env` |

## 9. Como executar o exemplo (roteiro da aula)

1. **Discover**: menu > Discover. Selecione a data view
   `kibana_sample_data_logs`. Ajuste o time range para "Last 90 days" (os
   timestamps do sample são relativos à data de carga). Filtre com KQL, por
   exemplo `response >= 400` para ver só erros.
2. **Lens**: a partir de um campo no Discover, clique em Visualize, ou vá em
   Dashboard > Create visualization. Arraste um campo (ex: `extension.keyword`)
   para o workspace e veja o Lens sugerir o gráfico automaticamente.
3. **Dashboard**: salve a visualização num novo dashboard, adicione mais
   painéis e salve o painel completo.
4. **Preview de recursos avançados** (conforme o escopo do curso oficial —
   apenas reconhecimento, sem aprofundar):
   - **Maps**: abra o dashboard `[Flights] Global Flight Dashboard` (criado
     junto com o sample data de voos) e observe a visualização geoespacial.
   - **Canvas**: menu > Analytics > Canvas — painéis de apresentação
     totalmente customizados (telões de NOC, relatórios executivos).
   - **Machine Learning**: menu > Analytics > Machine Learning — o Kibana
     oferece criar jobs de detecção de anomalia sobre os próprios sample
     data, aprendendo o padrão normal e apontando desvios sem threshold
     manual. O aprofundamento acontece nos módulos seguintes da formação.

## 10. Como visualizar os dados

Tudo é visual, dentro do Kibana (Discover, Lens, Dashboards). Para inspecionar
os dados brutos via API:

```bash
curl -s -u "elastic:SENHA" \
  "http://localhost:9200/kibana_sample_data_logs/_search?size=1&pretty"
```

## 11. Como parar o ambiente

```bash
docker compose stop
```

## 12. Como remover containers e volumes

```bash
docker compose down -v
```

O `-v` remove o volume `es-data`, apagando os dados. Use sem `-v` para manter.

## 13. Troubleshooting

- **Elasticsearch reinicia em loop**: falta de memória ou `vm.max_map_count`
  baixo no Linux (`sudo sysctl -w vm.max_map_count=262144`).
- **Kibana "server is not ready yet"**: aguarde o ES ficar green/yellow e
  confira a senha do `kibana_system` (passo 6.1).
- **Discover não mostra nada**: o time range padrão é curto. Amplie para
  "Last 90 days" — os timestamps do sample data são relativos à carga.
- **Script de sample data retorna 401**: senha do `elastic` no `.env`
  divergente da usada no container.

## 14. Referências oficiais

- Learn data exploration and visualization with Kibana: https://www.elastic.co/docs/explore-analyze/kibana-data-exploration-learning-tutorial
- Explore fields and data with Discover: https://www.elastic.co/docs/explore-analyze/discover/discover-get-started
- Lens (visualization editor): https://www.elastic.co/docs/explore-analyze/visualize/lens
- Explore and analyze data with Kibana (overview): https://www.elastic.co/docs/explore-analyze
- Elasticsearch Docker install: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Limitações deste exemplo

- Ambiente de **estudo/demonstração**, não de produção (TLS desabilitado,
  single-node).
- Os sample data sets são fictícios e servem só para aprendizado da interface.
- Não cobre ingestão de dados reais (isso vem nos próximos vídeos do curso).
