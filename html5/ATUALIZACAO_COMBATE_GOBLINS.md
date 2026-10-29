# Atualização de combate — armas dos inimigos, Defesa e encontros

## Encontros da minicampanha

1. **O Carregamento Desaparecido:** 2 bandidos, arqueiro e porrete (sem alterações na composição).
2. **Rastros na Mata:** 2 goblins, um de porrete e um de duas facas (2d4).
3. **A Passagem dos Covardes:** 3 goblins, Sucata à frente, arqueiro na coluna 6 de retaguarda e duas facas.
4. **O Covil de Tripa Seca:** chefe Tripa Seca com espada, arqueiro na coluna 6 da retaguarda e um goblin de porrete.

O posicionamento inicial continua respeitando casas vagas e a ordem de iniciativa: inimigos de curto alcance preferem a coluna 4 (índice 3); arqueiros preferem a coluna 6 (índice 5), recuando apenas quando necessário.

## Passivas dos inimigos

- **Porrete do bandido/goblin:** ao tirar 6 natural no 1d6 de ataque, aplica **Derrubado** ao herói; o próximo turno dele é perdido. Não acrescenta dados ou PA ao ataque. O gatilho permanece válido se a Defesa absorver o dano, conforme protótipo. **Brokk** resiste devido à passiva racial Firmeza de Rocha contra armas 1d6. Se o alvo for outro inimigo por fogo amigo, não há Derrubado de porrete.
- **Espada de Tripa Seca:** uma vez por combate, repete automaticamente o **erro 1 natural** da espada 1d6. O novo dado substitui o anterior, e o efeito não se recupera até outro encontro.
- **Arco (bandido e goblin):** mantém as regras já presentes de desvantagem contra alvo ortogonalmente adjacente e fogo amigo em resultados baixos quando há interceptação.
- **Duas facas:** mantém os dois dados de ataque (2d4) e o deslocamento gratuito já implementados.

## Defesa junto aos personagens

Pequena placa de bronze com **escudo prateado e número**, ao lado direito da barra de PV de cada unidade viva. Atualiza diretamente pelo estado do combate:
- inimigos: Defesa base +2 se tiverem Defender ativo;
- Brokk: Pele de Rocha +1 enquanto tiver mais de metade do HP máximo; Defender +2 se ativo;
- Zeno: Defender +2, Veterano +1 se ativado.

**Atenção:** o bônus condicional do escudo do herói (+2 apenas nos dados naturais 2 ou 3 do atacante) **não é incluído nesse número fixo**, pois só existe contra um ataque específico; continua funcionando no cálculo da Defesa do golpe.

## Integração

Fonte única: `html5/principal/index.html`. Publicação após merge em `main`, no link oficial https://viciadoemmana.github.io/Projeto-Santa-Mina/ . Esta atualização altera apenas regras solicitadas e a placa de Defesa; as mudanças de cenário e interface feitas pela colaboração visual permanecem.
