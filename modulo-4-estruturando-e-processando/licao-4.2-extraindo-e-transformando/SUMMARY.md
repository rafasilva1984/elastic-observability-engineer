# Summary — Lição 4.2 · Extracting & Transforming events

> Molde oficial: cada lição fecha com os pontos-chave e um quiz de 3 perguntas.

## Pontos-chave

- Strings podem ser convertidas para outro tipo com o processor `convert`
- Dá para mudar a caixa de uma string com `uppercase` e `lowercase`
- O processor `date` normaliza formatos diferentes de data
- Sem timezone declarado, o `date` usa **UTC** — mas você pode declarar o seu explicitamente
- O parâmetro `locale` informa o idioma em que a data pode vir
- Tipo errado não quebra a ingestão: quebra a agregação depois, quando ninguém liga uma coisa à outra

## Quiz

1. Verdadeiro ou falso: o processor `date` assume o fuso do servidor quando nenhum fuso é informado.
   <details><summary>resposta</summary>

   **Falso.** Ele assume **UTC**. Esse detalhe é a causa clássica do gráfico com 'deslocamento de 3 horas'.
   </details>

2. Que formato você usaria no processor `date` para interpretar `12/31/2019`?
   <details><summary>resposta</summary>

   `MM/dd/yyyy`. E vale o alerta: `31/12/2019` exigiria `dd/MM/yyyy` — declarar os dois na lista de formatos evita a ambiguidade quebrar a ingestão.
   </details>

3. Qual parâmetro informa ao processor `date` o idioma em que a data foi escrita?
   <details><summary>resposta</summary>

   O parâmetro **`locale`** — necessário quando o mês vem por extenso ou abreviado em idioma diferente do inglês.
   </details>

---

Próximo passo: **[LAB.md](./LAB.md)** (se ainda não fez) ou a próxima lição.
