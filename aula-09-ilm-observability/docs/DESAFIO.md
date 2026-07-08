# Desafios — Aula 9 · ILM

## 🟢 Desafio guiado
Refaça o ciclo sem o vídeo: acelerar poll + política + template + gerador
+ observatório (README, passos 7–8).

## 🔒 Desafio autônomo — "Evolua a política em produção simulada"
**Missão:** com o ciclo da aula rodando:
1. Adicione uma fase **cold** (min_age 3m, readonly + set_priority 0)
   entre warm e delete, e mude o delete para 6m — SEM apagar nada.
2. Observe: o índice atual NÃO muda de comportamento imediatamente.
   Explique por quê (uma frase).
3. Prove com `_ilm/explain` uma geração passando por hot → warm → cold →
   delete completo.

### Critérios de aceite
- [ ] Política com 4 fases válida (GET _ilm/policy/onp-ciclo-rapido)
- [ ] Explicação do cache de fase escrita com suas palavras
- [ ] Explain mostrando um índice em fase cold antes de sumir

### Validação
`watch -n 5 ./scripts/explicar-ilm.sh` cobrindo o ciclo novo.

### Dica (só se travar)
A definição da fase ATUAL fica em cache no índice — a nova versão vale
na transição seguinte (Vídeo 9, erro comum nº 2).

⏱ 30 min · Revisão: Vídeo 9 · doc: ILM phases and actions
