# Regras e formações — atualização 29/10/2026

## Muralha de Ferro
- A reação pode ser **oferecida para escolha do jogador** se o ataque físico do inimigo causar dano e **o total bruto do ataque (dados efetivos + bônus do inimigo) for 6 ou mais**, mesmo que o dado natural seja inferior a 5.
- Permanecem os gatilhos aprovados: dado natural >=5 ou dano potencialmente fatal.
- A habilidade continua **opcional**, uma vez por combate, reduz o dano recebido à metade (arredondado para baixo) e aplica **−1 PA no próximo turno** se usada.

## Goblin Faca Dupla
- Sempre lança **duas rolagens 1d4 independentes**, ainda que a primeira seja 1. Sob vantagem/desvantagem, cada uma das facas usa seus próprios dois dados e seleciona maior/menor.
- Para cada faca: **1 natural = errou apenas aquela faca, causando 0 dano e sem bônus**. Em 2, 3 ou 4: soma-se o resultado da faca. **A DES do goblin (+2) é adicionada apenas uma vez por ação, desde que ao menos uma faca acerte.**
- Somam-se apenas as facas que acertaram; então se aplica a Defesa do alvo ao total.
- Exemplos: [1,4] => 0+4+2=**6 de dano bruto**; [1,1] => 0, sem bônus; [3,4] => 3+4+2=**9 de dano bruto**.
- Nenhuma primeira rolagem 1 deve cancelar a segunda.

## Formações fixas dos últimos encontros
Casas são A–C × 1–6, com heróis nas colunas 1–3. A formação não varia com iniciativa.
- **Capítulo 3:** Goblin Sucata B4, arqueiro B6 (última coluna, atrás do Sucata), Faca Dupla C4.
- **Capítulo 4:** Tripa Seca B4, arqueiro B6 (última coluna, atrás do chefe), Porrete C5 (lateral, uma coluna atrás do chefe).
- Os dois encontros anteriores permanecem com suas formações anteriores.

## Movimento e corrida — jogador
- O herói pode usar **Mover OU Correr, apenas uma vez por turno**. São alternativas, não acumuláveis.
- O limite é compartilhado: depois de mover, não pode correr; depois de correr, não pode mover. Os PA são cobrados normalmente.
- A marca é reiniciada no começo do próximo turno do herói. As cartas ficam desabilitadas durante o restante do turno.
- Movimentações gratuitas pré-existentes de criaturas não foram alteradas.

Origem oficial: `html5/principal/index.html`; publicar sempre em https://viciadoemmana.github.io/Projeto-Santa-Mina/ via PR para main.

## Escudo contra duas facas (revisão)

O equipamento Escudo de Madeira e Ferro verifica **cada resultado efetivo** do ataque de duas facas (2d4). Se **qualquer** faca tirar **2 ou 3**, a Defesa do herói recebe **+2 uma única vez durante toda a ação**, mesmo se ambas rolarem 2 ou 3. A Defesa é descontada do dano bruto total já somado das facas, e não separadamente de cada golpe.

Exemplos com Brokk a 14 PV, sem Defender: [1,4] → Defesa 1 (sem gatilho); [1,2] → Defesa 3; [2,3] → Defesa 3, nunca 5; [3,3] → Defesa 3. Com Defender e [2,3], Defesa total 5 = Pele 1 + Defender 2 + Escudo 2.

## Regra de dano dos inimigos por arma (atualização)

O bônus de dano não depende mais do campo numérico fixo de cada monstro: é derivado do atributo aplicável à arma. **Arcos e duas facas somam Destreza; espada, porrete e arma de impacto/gancho somam Força.** Um ataque normal causa o valor efetivo do dado + o atributo. As duas facas continuam rolando dois dados independentes; cada 1 erra, e DES é adicionada uma só vez se ao menos uma acertar.

**Goblin Arqueiro:** 1d6 + DES 2, sem o antigo modificador −1. Dado 4 → 6 dano bruto; contra Brokk com Pele de Rocha +1, escudo que não ativou, dano final 5. O escudo continua ativando com 2 ou 3 do arco, quando aplicável.
