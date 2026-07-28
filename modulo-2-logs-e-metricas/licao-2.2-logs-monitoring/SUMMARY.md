# Summary — Lição 2.2 · Logs Monitoring

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Logs respondem muitas das perguntas que fazemos aos nossos dados
- Um log é uma mensagem com timestamp e alguma(s) informação(ões) de contexto
- Integrações simplificam a coleta, o parsing e a visualização de formatos comuns
- O Elastic Agent monitora diretórios ou arquivos específicos via Filestream
- Uma vez no Elasticsearch, o dado pode ser consultado e explorado livremente
- O nome do dataset não é detalhe: define o data stream, a retenção e o custo

## Quiz

1. Quais são os dois elementos principais de uma mensagem de log?
   <details><summary>resposta</summary>

   O **timestamp** (quando aconteceu) e a **mensagem/contexto** (o que aconteceu). Sem timestamp confiável, o log perde a capacidade de correlação.
   </details>

2. Verdadeiro ou falso: está tudo bem entregar os arquivos de log do servidor web para qualquer pessoa da empresa contar acessos.
   <details><summary>resposta</summary>

   **Falso.** Log costuma conter IP, identificadores de usuário e outros dados sensíveis. O caminho certo é dar acesso à visualização adequada, com o recorte e as permissões corretas.
   </details>

3. Verdadeiro ou falso: o Elastic Agent simplifica a coleta e envia os dados para a plataforma Elastic.
   <details><summary>resposta</summary>

   **Verdadeiro.** É exatamente a proposta: um agente, várias integrações, configuração central via policy.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
