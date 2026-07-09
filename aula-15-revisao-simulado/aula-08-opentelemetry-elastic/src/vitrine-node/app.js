// Serviço de vitrine (Aula 7 - OpenTelemetry)
// Instrumentação AUTOMÁTICA via --require @opentelemetry/auto-instrumentations-node/register
// (ver Dockerfile). Nenhum import de OTel aqui — só o Express e a chamada
// ao catálogo. O contexto do trace atravessa a chamada HTTP sozinho.
const express = require("express");
const app = express();

const CATALOGO_URL = process.env.CATALOGO_URL || "http://catalogo:5002";

app.get("/produtos", async (_req, res) => {
  // Chama o serviço Python: o trace nasce aqui (Node) e continua lá (Python).
  const r = await fetch(`${CATALOGO_URL}/itens`);
  const dados = await r.json();
  res.json({ vitrine: "ok", total: dados.itens.length, itens: dados.itens });
});

app.get("/health", (_req, res) => res.json({ ok: true }));

app.listen(5003, () => console.log("vitrine ouvindo em :5003"));
