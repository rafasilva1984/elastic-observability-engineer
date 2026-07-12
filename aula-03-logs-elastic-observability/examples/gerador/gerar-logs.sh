#!/bin/sh
# Gerador de logs de exemplo - Aula 3 (Logs)
# Escreve continuamente em /var/log/app/app.log linhas realistas de uma
# aplicação fictícia de checkout, misturando níveis INFO, WARN e ERROR.
#
# Formato (proposital, para a aula de ingest pipelines reaproveitar):
# 2026-07-03T11:00:00Z LEVEL service=checkout user=123 duration_ms=45 msg="texto"
#
# PORTABILIDADE: roda em Alpine/BusyBox (POSIX sh), onde `date +%N`
# (nanossegundos) NÃO existe — usá-lo quebra a aritmética com "arithmetic
# syntax error". Usamos um LCG (gerador linear congruente) atualizado no
# shell principal — subshell $(...) não preserva a semente.

mkdir -p /var/log/app
LOG=/var/log/app/app.log
echo "Gerador iniciado. Escrevendo em $LOG"

MSGS_INFO="pedido criado|pagamento aprovado|item reservado|frete calculado|sessao iniciada"
MSGS_WARN="tempo de resposta alto|retry na chamada externa|cache expirado|fila acima do esperado"
MSGS_ERR="falha ao processar pagamento|timeout na chamada ao estoque|conexao recusada pelo gateway|erro inesperado no checkout"

item() { echo "$1" | tr '|' '\n' | awk -v n="$2" 'NR==n'; }

SEED=$(( ($(date +%s) + $$) % 2147483647 ))
avanca() { SEED=$(( (SEED * 1103515245 + 12345) % 2147483648 )); }

while true; do
  TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  avanca; SVC_N=$(( (SEED / 65536) % 4 + 1 ))
  avanca; USERID=$(( (SEED / 65536) % 900 + 100 ))
  avanca; DUR=$(( (SEED / 65536) % 950 + 20 ))
  avanca; ROLL=$(( (SEED / 65536) % 100 ))
  avanca; MSG_N=$(( (SEED / 65536) % 5 + 1 ))

  SVC=$(item "checkout|pagamento|estoque|frete" "$SVC_N")

  if [ "$ROLL" -lt 70 ]; then
    LEVEL="INFO"
    MSG=$(item "$MSGS_INFO" "$MSG_N")
  elif [ "$ROLL" -lt 90 ]; then
    LEVEL="WARN"
    MSG=$(item "$MSGS_WARN" $(( MSG_N > 4 ? 4 : MSG_N )))
    DUR=$(( DUR + 800 ))
  else
    LEVEL="ERROR"
    MSG=$(item "$MSGS_ERR" $(( MSG_N > 4 ? 4 : MSG_N )))
    DUR=$(( DUR + 1500 ))
  fi

  echo "$TS $LEVEL service=$SVC user=$USERID duration_ms=$DUR msg=\"$MSG\"" >> "$LOG"
  sleep 1
done
