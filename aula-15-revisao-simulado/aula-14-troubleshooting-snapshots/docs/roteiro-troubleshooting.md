# Roteiro guiado — APM Troubleshooting + Searchable Snapshots (Aula 14)

Base: arena do Vídeo 7 (APM funcionando de ponta a ponta) + repositório
de snapshots. Suba tudo pelo README (passos 6–8) ANTES das partes abaixo.

## PARTE A — O APM ficou mudo (EOE 3.3)

### A1. Estado saudável (a linha de base)
Applications > Service map: loja-api → pagamento conectados, tráfego
fluindo. SEMPRE conheça o saudável antes de quebrar.

### A2. Injete a falha
```bash
./scripts/simular-falha.sh
```
O serviço pagamento é recriado com um secret token ERRADO — a "rotação
de credencial" clássica. Aguarde ~1 min: ele SOME do service map. O
serviço funciona; a telemetria morreu. Ninguém recebe erro.

### A3. Diagnostique com o checklist oficial (de fora pra dentro)
```bash
./scripts/diagnosticar.sh
```
A ordem oficial do "Common problems":
1. **APM Server de pé?** `curl :8200` responde → servidor ok.
2. **Agente entregando?** logs do serviço → aqui aparece o **401/
   unauthorized** (secret token inválido = rejeição).
3. **APM Server reclamando?** logs do fleet-server (`apm-server`).
4. **Dado novo chegando?** count em `traces-apm*` nos últimos 5 min —
   parado para o serviço quebrado.

Diagnóstico fechado: 401 no agente + contagem parada = token.

### A4. Corrija e PROVE
```bash
./scripts/corrigir-falha.sh
```
~1 min depois: pagamento de volta ao service map, contagem andando.

### Outros suspeitos do checklist oficial (conhecer para a prova)
- Integração APM ausente/parada na policy → `:8200` mudo.
- Host errado: em Docker o bind precisa ser `0.0.0.0:8200`.
- **503 Queue is full**: só 503 = Elasticsearch sem dar vazão;
  503 + 202 intercalados = APM Server no limite.
- **Mapping explosion**: tags demais → "Limit of total fields [1000]"
  e transações somem.

## PARTE B — Searchable Snapshots (EOE 7.3)

### B1. Repositório
```bash
./scripts/criar-repo.sh     # PUT _snapshot tipo fs (exige path.repo) + verify
```

### B2. Snapshot do dado "frio"
```bash
./scripts/criar-snapshot.sh # índice auditoria-2025 → force-merge → snapshot → DELETE
```
Ao final, o dado existe SÓ no repositório — o cenário de retenção legal.

### B3. Monte e pesquise
```bash
./scripts/montar-snapshot.sh
```
`_mount` com `storage=full_copy` (fully mounted). O índice
`auditoria-2025-montado` responde busca normalmente — sem restore.
O modo `shared_cache` (partially mounted) é o que o tier **frozen** usa,
com cache compartilhado em vez de cópia completa.

### Regras oficiais que caem em conversa de prova
- Force-merge para 1 segmento ANTES do snapshot (menos leituras no repo).
- NUNCA delete um snapshot com índice montado — clone o snapshot se
  precisar mexer.
- Réplicas de searchable snapshot: 0 por padrão — a "réplica" é o
  próprio repositório.
- É assim que a fase frozen do ILM funciona por baixo (liga com o V8).
