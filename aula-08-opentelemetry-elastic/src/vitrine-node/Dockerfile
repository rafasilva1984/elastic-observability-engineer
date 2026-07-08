FROM node:20-slim
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev
COPY app.js .
EXPOSE 5003
# A auto-instrumentação acontece AQUI, no --require (zero mudança de código).
CMD ["node", "--require", "@opentelemetry/auto-instrumentations-node/register", "app.js"]
