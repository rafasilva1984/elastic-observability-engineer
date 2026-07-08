"""
Serviço de pagamento (Aula 6 - APM com Elastic)
Instrumentado com o agente APM oficial de Python (flask).
"""
import time
from flask import Flask
from elasticapm.contrib.flask import ElasticAPM

app = Flask(__name__)
# O agente lê ELASTIC_APM_* das variáveis de ambiente (server_url,
# secret_token, service_name, environment) definidas no docker-compose.
apm = ElasticAPM(app)

@app.route("/pagar")
def pagar():
    # Simula o processamento do pagamento (chamada a adquirente, etc.)
    time.sleep(0.15)
    return {"status": "aprovado"}

@app.route("/health")
def health():
    return {"ok": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
