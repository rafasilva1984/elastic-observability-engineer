#!/bin/sh
# Gerador de logs de exemplo - Aula 3 (Logs)
# Escreve continuamente em /var/log/app/app.log linhas realistas de uma
# aplicação fictícia de checkout, misturando níveis INFO, WARN e ERROR.
#
# Formato (proposital, para a Aula 5 de ingest pipelines reaproveitar):
# 2026-07-03T11:00:00Z LEVEL service=checkout user=123 duration_ms=45 msg="texto"

mkdir -p /var/log/app
LOG=/var/log/app/app.log
echo "Gerador iniciado. Escrevendo em $LOG"

SERVICES="checkout pagamento estoque frete"
MSGS_INFO="pedido criado|pagamento aprovado|item reservado|frete calculado|sessao iniciada"
MSGS_WARN="tempo de resposta alto|retry na chamada externa|cache expirado|fila acima do esperado"
MSGS_ERR="falha ao processar pagamento|timeout na chamada ao estoque|conexao recusada pelo gateway|erro inesperado no checkout"

pick() { echo "$1" | tr '|' '\n' | awk -v n="$(( $(date +%N | cut -c7-9) % $2 + 1 ))" 'NR==n'; }

while true; do
  TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  SVC=$(echo "$SERVICES" | tr ' ' '\n' | awk -v n="$(( $(date +%N | cut -c4-6) % 4 + 1 ))" 'NR==n')
  USERID=$(( $(date +%N | cut -c1-4) % 900 + 100 ))
  DUR=$(( $(date +%N | cut -c2-5) % 950 + 20 ))
  ROLL=$(( $(date +%N | cut -c5-7) % 100 ))

  if [ "$ROLL" -lt 70 ]; then
    LEVEL="INFO";  MSG=$(pick "$MSGS_INFO" 5)
  elif [ "$ROLL" -lt 90 ]; then
    LEVEL="WARN";  MSG=$(pick "$MSGS_WARN" 4); DUR=$(( DUR + 800 ))
  else
    LEVEL="ERROR"; MSG=$(pick "$MSGS_ERR" 4);  DUR=$(( DUR + 1500 ))
  fi

  echo "$TS $LEVEL service=$SVC user=$USERID duration_ms=$DUR msg=\"$MSG\"" >> "$LOG"
  sleep 1
done
