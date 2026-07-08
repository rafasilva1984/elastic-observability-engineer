# 🎓 Elastic Certified Observability Engineer — Curso Completo em Português

![Elastic Stack](https://img.shields.io/badge/Elastic%20Stack-9.4.3-005571?logo=elastic)
![Docker](https://img.shields.io/badge/Docker-Compose%20v2-2496ED?logo=docker)
![Idioma](https://img.shields.io/badge/idioma-PT--BR-green)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-blue)

Curso **gratuito e hands-on** de preparação para o exame **Elastic Certified
Observability Engineer**, do canal
[**Observabilidade na Prática**](https://www.youtube.com/@ObservabilidadeNaPratica).

**15 aulas · 19/19 módulos do lab oficial cobertos · 100% replicável com Docker.**
Cada aula tem lab completo, desafios no formato oficial do exame (guiado +
autônomo com validação por estado final) e fontes oficiais da Elastic.

## 📚 Grade do curso

| # | Aula | Módulos EOE | Vídeo |
|---|------|-------------|-------|
| 01 | [Introdução ao Kibana](./aula-01-introducao-ao-kibana/) | EOE 1.1 · 1.3 | _em breve_ |
| 02 | [Uptime e Synthetic Monitoring](./aula-02-uptime-synthetic-monitoring/) | EOE 1.2 | _em breve_ |
| 03 | [Logs com Elastic Observability](./aula-03-logs-elastic-observability/) | EOE 2.1 · 2.2 | _em breve_ |
| 04 | [Metrics e Infraestrutura](./aula-04-metrics-infraestrutura/) | EOE 2.3 | _em breve_ |
| 05 | [Monitorando Kubernetes com Elastic Agent](./aula-05-kubernetes-elastic-agent/) | EOE 2.x aplicado | _em breve_ |
| 06 | [Ingest Pipelines](./aula-06-ingest-pipelines/) | EOE 4.1 · 4.2 · 4.3 | _em breve_ |
| 07 | [APM com Elastic](./aula-07-apm-com-elastic/) | EOE 3.1 | _em breve_ |
| 08 | [OpenTelemetry com Elastic](./aula-08-opentelemetry-elastic/) | EOE 3.2 | _em breve_ |
| 09 | [ILM para Dados de Observabilidade](./aula-09-ilm-observability/) | EOE 7.1 · 7.2 | _em breve_ |
| 10 | [Hello Dashboard](./aula-10-hello-dashboard/) | EOE 6.1 | _em breve_ |
| 11 | [Visualizações com Lens](./aula-11-lens-visualizacoes/) | EOE 6.2 | _em breve_ |
| 12 | [Dashboards Interativos](./aula-12-dashboards-interativos/) | EOE 6.1 avançado | _em breve_ |
| 13 | [Machine Learning e Alerting](./aula-13-ml-alerting/) | EOE 5.1 · 5.2 · 5.3 | _em breve_ |
| 14 | [APM Troubleshooting e Searchable Snapshots](./aula-14-troubleshooting-snapshots/) | EOE 3.3 · 7.3 | _em breve_ |
| 15 | [Revisão Geral + Simulado](./aula-15-revisao-simulado/) | todos os domínios | _em breve_ |

## 🚀 Como usar

```bash
git clone https://github.com/rafasilva1984/elastic-observability-engineer.git
cd elastic-observability-engineer/aula-01-introducao-ao-kibana
cat README.md   # cada aula tem passo a passo completo (14 seções)
```

Fluxo de toda aula: `cp .env.example .env` → subir com Docker Compose →
seguir o roteiro em `docs/` → fazer o `docs/DESAFIO.md` → validar.

## ✅ Pré-requisitos

- Docker Engine 24+ com Compose v2
- 4–6 GB de RAM livres (varia por aula; ver README de cada uma)
- `sudo sysctl -w vm.max_map_count=262144` (requisito do Elasticsearch)

## 🔐 Importante

Os arquivos `.env` contêm senhas e tokens locais e estão no `.gitignore` —
**use sempre o `.env.example` como base e nunca versione o seu `.env`.**

## 🏁 Preparação final

A [Aula 15](./aula-15-revisao-simulado/) traz o **simulado completo**: 12
tarefas cronometradas (110 min) no formato performance-based do exame, com
gabarito comentado e reset para repetir. Recomendação: marque a prova com
**≥ 90/120 em duas rodadas seguidas**.

## 📄 Licença

MIT — use, estude, compartilhe. Se este material te ajudou, ⭐ o repositório
e se inscreva no canal: é o que mantém o projeto vivo.
