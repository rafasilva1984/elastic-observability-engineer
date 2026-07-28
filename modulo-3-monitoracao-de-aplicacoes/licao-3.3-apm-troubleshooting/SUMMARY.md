# Summary — Lição 3.3 · APM Troubleshooting

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Falha de telemetria é silenciosa: o serviço funciona, ninguém recebe erro, e o dado simplesmente não chega
- O checklist oficial roda de fora para dentro: servidor → agente → APM Server → dado novo
- Em Docker, o host do APM Server precisa ser `0.0.0.0:8200`, senão ele só ouve dentro do container
- Secret token inválido gera 401 e rejeição silenciosa do lado do agente
- 503 puro indica Elasticsearch sem vazão; 503 intercalado com 202 indica APM Server no limite
- Mapping explosion (limite de campos) faz transações sumirem sem erro visível na UI

## Quiz

1. Qual é o primeiro passo do checklist quando 'não aparece dado no APM'?
   <details><summary>resposta</summary>

   Verificar se o **APM Server está de pé** (`curl :8200`). Se estiver mudo, o problema é a integração/host — não adianta investigar o agente ainda.
   </details>

2. Você vê 503 intercalado com 202 nos logs. O que isso indica?
   <details><summary>resposta</summary>

   **APM Server no limite** (fila cheia por pressão nele). Só 503, sem 202, aponta para o Elasticsearch não dando vazão à ingestão.
   </details>

3. Por que diagnosticar em ordem fixa é melhor do que ir pelo palpite?
   <details><summary>resposta</summary>

   Porque cada passo **elimina uma camada** de suspeitos. Palpite de pessoa experiente erra com confiança — o checklist tira o ego da investigação.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
