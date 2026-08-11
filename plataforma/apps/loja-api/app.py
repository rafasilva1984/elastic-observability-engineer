"""API da Loja ONP — instrumentada com o agente APM oficial da Elastic.

Endpoints propositais para os laboratórios:
  /api/pedidos  -> caminho feliz (chama o serviço de pagamento: trace distribuído)
  /api/lento    -> latência alta concentrada em UM span nomeado (waterfall)
  /api/erro     -> exceção não tratada (aparece em Applications > Errors)

NOTA DE CORREÇÃO — /api/lento
  A primeira versão desta rota fazia:

      with apm.client.begin_transaction('consulta-estoque'):
          pass

  Dois erros numa linha só:

  1. `begin_transaction()` devolve um objeto `Transaction`, que NÃO implementa
     o protocolo de context manager. O `with` levantava AttributeError e a
     rota respondia HTTP 500.

  2. O argumento de `begin_transaction` é o TIPO da transação, não um nome.
     A chamada abria uma transação nova por cima da que a integração Flask já
     tinha iniciado, sequestrando o contexto. A transação do Flask ficava
     órfã e a rota NÃO aparecia em Applications > Transactions, porque
     aquela tela filtra por transações do tipo `request`.

  A API correta para "mostre onde o tempo foi dentro desta transação" é
  `elasticapm.capture_span`, que é context manager e cria um span filho da
  transação corrente. Referência oficial:
  https://www.elastic.co/guide/en/apm/agent/python/current/api.html
"""
import os, time, random, logging
import requests
from flask import Flask, jsonify
import elasticapm
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
    """Caminho feliz. A chamada HTTP ao serviço de pagamento é instrumentada
    automaticamente pelo agente, então o trace atravessa os dois serviços."""
    with elasticapm.capture_span('montar-carrinho', span_type='app'):
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
    """Latência concentrada em um span nomeado.

    O waterfall do trace mostra dois spans com durações muito diferentes:
    `validar-sessao` com poucos milissegundos e `consulta-estoque` com mais
    de um segundo — cerca de 98% da transação. É o exercício de "onde foi o
    tempo?" das lições 3.1 e 3.3.
    """
    with elasticapm.capture_span('validar-sessao', span_type='app'):
        time.sleep(random.uniform(0.005, 0.02))

    with elasticapm.capture_span('consulta-estoque',
                                 span_type='db',
                                 span_subtype='postgresql',
                                 span_action='query'):
        time.sleep(random.uniform(1.2, 2.4))

    # labels viram campos filtráveis em Applications (labels.cenario)
    elasticapm.label(cenario='latencia-alta', origem='consulta-estoque')

    app.logger.warning('consulta ao estoque demorou mais que o esperado')
    return jsonify(resultado='ok, mas demorou')


@app.route('/api/erro')
def erro():
    """Exceção não tratada. A integração Flask captura automaticamente e o
    erro aparece em Applications > Errors, ligado ao trace que o originou."""
    app.logger.error('falha ao processar pagamento')
    raise RuntimeError('gateway de pagamento recusou a transacao')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
