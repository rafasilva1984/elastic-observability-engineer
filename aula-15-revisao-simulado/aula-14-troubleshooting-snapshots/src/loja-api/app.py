"""
API da loja (Aula 6 - APM com Elastic)
Serviço de entrada, instrumentado com o agente APM oficial de Python.
Chama o serviço de pagamento via HTTP -> distributed tracing automático
(o agente propaga o contexto do trace nos headers).
"""
import os
import time
import requests
from flask import Flask
from elasticapm.contrib.flask import ElasticAPM

app = Flask(__name__)
apm = ElasticAPM(app)

PAGAMENTO_URL = os.environ.get("PAGAMENTO_URL", "http://pagamento:5001")

@app.route("/checkout")
def checkout():
    # Transação normal: chama o serviço de pagamento (vira um span HTTP
    # e continua o trace no outro serviço = distributed tracing).
    r = requests.get(f"{PAGAMENTO_URL}/pagar", timeout=5)
    return {"pedido": "criado", "pagamento": r.json()["status"]}

@app.route("/lento")
def lento():
    # Endpoint propositalmente lento: o vilão da investigação da aula.
    time.sleep(2.5)
    return {"pedido": "criado (com sofrimento)"}

@app.route("/erro")
def erro():
    # Exceção proposital: aparece agrupada na aba Errors da APM app.
    raise RuntimeError("Falha proposital no checkout - Aula 6")

@app.route("/health")
def health():
    return {"ok": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
