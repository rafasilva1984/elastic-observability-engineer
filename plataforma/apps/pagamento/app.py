"""Serviço de pagamento — o segundo serviço do trace distribuído."""
import os, time, random, logging
from flask import Flask, jsonify
from elasticapm.contrib.flask import ElasticAPM

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s service=pagamento msg="%(message)s"')

app = Flask(__name__)
app.config['ELASTIC_APM'] = {
    'SERVICE_NAME': os.getenv('ELASTIC_APM_SERVICE_NAME', 'pagamento'),
    'SERVER_URL': os.getenv('ELASTIC_APM_SERVER_URL', 'http://fleet-server:8200'),
    'SECRET_TOKEN': os.getenv('ELASTIC_APM_SECRET_TOKEN', ''),
    'ENVIRONMENT': os.getenv('ELASTIC_APM_ENVIRONMENT', 'lab'),
}
ElasticAPM(app)


@app.route('/health')
def health():
    return jsonify(status='ok')


@app.route('/cobrar')
def cobrar():
    time.sleep(random.uniform(0.03, 0.15))
    app.logger.info('cobranca autorizada')
    return jsonify(status='aprovado', autorizacao=random.randint(100000, 999999))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
