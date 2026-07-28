"""API da Loja ONP — instrumentada com o agente APM oficial da Elastic.

Endpoints propositais para os laboratórios:
  /api/pedidos  -> caminho feliz (chama o serviço de pagamento)
  /api/lento    -> latência alta concentrada em um span
  /api/erro     -> exceção não tratada (aparece em Applications > Errors)
"""
import os, time, random, logging
import requests
from flask import Flask, jsonify
from elasticapm.contrib.flask import ElasticAPM

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s service=loja-api msg="%(message)s"')

app = Flask(__name__)
app.config['ELASTIC_APM'] = {
    'SERVICE_NAME': os.getenv('ELASTIC_APM_SERVICE_NAME', 'loja-api'),
    'SERVER_URL': os.getenv('ELASTIC_APM_SERVER_URL', 'http://fleet-server:8200'),
    'SECRET_TOKEN': os.getenv('ELASTIC_APM_SECRET_TOKEN', ''),
    'ENVIRONMENT': os.getenv('ELASTIC_APM_ENVIRONMENT', 'lab'),
    'DEBUG': True,
}
apm = ElasticAPM(app)
PAGAMENTO = os.getenv('PAGAMENTO_URL', 'http://pagamento:5001')


@app.route('/health')
def health():
    return jsonify(status='ok')


@app.route('/')
def raiz():
    return jsonify(servico='loja-api',
                   endpoints=['/health', '/api/pedidos', '/api/lento', '/api/erro'])


@app.route('/api/pedidos')
def pedidos():
    time.sleep(random.uniform(0.02, 0.09))
    try:
        r = requests.get(f'{PAGAMENTO}/cobrar', timeout=5)
        pago = r.json()
    except Exception as e:                      # noqa: BLE001
        app.logger.warning('pagamento indisponivel: %s', e)
        pago = {'status': 'indisponivel'}
    app.logger.info('pedido processado')
    return jsonify(pedido=random.randint(1000, 9999), pagamento=pago)


@app.route('/api/lento')
def lento():
    # latência concentrada: o waterfall do trace mostra ONDE o tempo foi
    with apm.client.begin_transaction('consulta-estoque'):
        pass
    time.sleep(random.uniform(1.2, 2.4))
    app.logger.warning('consulta ao estoque demorou mais que o esperado')
    return jsonify(resultado='ok, mas demorou')


@app.route('/api/erro')
def erro():
    app.logger.error('falha ao processar pagamento')
    raise RuntimeError('gateway de pagamento recusou a transacao')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
