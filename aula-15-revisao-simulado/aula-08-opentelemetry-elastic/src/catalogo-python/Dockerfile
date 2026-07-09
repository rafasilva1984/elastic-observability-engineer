FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && opentelemetry-bootstrap -a install
COPY app.py .
EXPOSE 5002
# A auto-instrumentação acontece AQUI: opentelemetry-instrument envolve o
# processo e instrumenta o Flask sem mudar o código.
CMD ["opentelemetry-instrument", "python", "app.py"]
