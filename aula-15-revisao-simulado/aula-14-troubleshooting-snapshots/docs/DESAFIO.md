# Desafios — Aula 14 · APM Troubleshooting + Searchable Snapshots

## 🟢 Desafio guiado
Refaça as partes A e B sem o vídeo (docs/roteiro-troubleshooting.md).

## 🔒 Desafio autônomo — "Outro sintoma, outro culpado"
**Missão A (troubleshooting):** peça a um colega (ou faça sem olhar
depois) para editar o compose e trocar a `ELASTIC_APM_SERVER_URL` do
serviço pagamento por uma URL errada (ex.: porta 8201). Diagnostique
usando SOMENTE o checklist — e diga em qual passo esse defeito aparece
DIFERENTE do defeito de token (dica: connection refused × 401).

**Missão B (snapshots):** crie um segundo índice `auditoria-2026` com
docs seus, snapshot `snap-2026`, apague o índice, monte com um nome
novo e responda uma busca nele. Depois tente DELETAR o snapshot com o
índice montado e explique o que a doc oficial manda fazer no lugar.

### Critérios de aceite
- [ ] Passo do checklist que diferencia URL errada × token errado
      identificado por escrito
- [ ] Serviço de volta ao service map após a correção
- [ ] Busca respondida no índice montado do snap-2026
- [ ] Regra do "clone antes de deletar" explicada em 1 frase

### Validação
Prints do diagnosticar.sh nos dois defeitos + _count do índice montado.

### Dica (só se travar)
URL errada mata a CONEXÃO (passo 2 sem 401, com refused); token errado
mata a AUTORIZAÇÃO (401 explícito).

⏱ 40 min · Revisão: Vídeo 14 · doc: apm common-problems + searchable-snapshots
