#!/bin/sh
# Gera tráfego contínuo na loja-api para alimentar o APM (traces e erros).
apk add --no-cache curl > /dev/null 2>&1
API=${API_URL:-http://loja-api:5000}
echo "Gerador de tráfego iniciado -> $API"
SEED=$(( ($(date +%s) + $$) % 2147483647 ))
avanca() { SEED=$(( (SEED * 1103515245 + 12345) % 2147483648 )); }
while true; do
  avanca; R=$(( (SEED / 65536) % 100 ))
  if   [ "$R" -lt 70 ]; then ROTA="/api/pedidos"
  elif [ "$R" -lt 90 ]; then ROTA="/api/lento"
  else                       ROTA="/api/erro"; fi
  curl -s -o /dev/null -m 10 "${API}${ROTA}"
  sleep 2
done
