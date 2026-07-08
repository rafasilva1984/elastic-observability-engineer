"""
Serviço de catálogo (Aula 7 - OpenTelemetry)
Instrumentação AUTOMÁTICA via opentelemetry-instrument (distro oficial):
nenhum import de OTel no código — a mágica acontece no comando de execução
e nas variáveis de ambiente OTEL_*.
"""
import time
from flask import Flask

app = Flask(__name__)

ITENS = [
    {"id": 1, "nome": "Teclado mecânico", "preco": 350.0},
    {"id": 2, "nome": "Mouse vertical", "preco": 180.0},
    {"id": 3, "nome": "Monitor 27\"", "preco": 1450.0},
]

@app.route("/itens")
def itens():
    time.sleep(0.12)  # simula consulta ao banco
    return {"itens": ITENS}

@app.route("/health")
def health():
    return {"ok": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)
