# Lição 2.2 — Logs Monitoring

> Módulo 2 · Logs and metrics monitoring · Lição 2.2
> Espelha a lição **2.2** do curso oficial *Elastic Observability Engineer*.

## Objetivo

Coletar logs de uma aplicação real com a integração Custom Logs (Filestream), entender o que faz um log ser útil, e explorar tudo no Discover — incluindo a diferença entre log bruto e log estruturado, que abre o módulo 4.

## Tópicos

- Anatomia de um log: timestamp + mensagem + contexto
- Integrações prontas × Custom Logs: quando usar cada caminho
- Filestream: o input que lê arquivos e guarda o offset
- Dataset e namespace: o nome que define seu data stream
- Da coleta à consulta: o caminho do arquivo até o Discover
- Log bruto × log estruturado (e por que isso vira custo lá na frente)

## Antes de começar

A plataforma precisa estar no ar (sobe **uma vez** e serve o curso inteiro):

```bash
cd ../../plataforma
./scripts/subir.sh        # se ainda não subiu
./scripts/validar.sh      # confirma que está tudo certo
```

Você **não** precisa subir nada específico desta lição. O foco aqui é o
**exercício sobre o tema**, não montar infraestrutura.

## Sequência da lição

1. Assista/leia o conteúdo e acompanhe as telas.
2. Faça o **[LAB.md](./LAB.md)** — é onde o aprendizado acontece.
3. Feche com o **[SUMMARY.md](./SUMMARY.md)** (recapitulação + quiz).

⏱ Lab: 35 min
