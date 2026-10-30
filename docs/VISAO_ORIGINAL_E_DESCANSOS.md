# Santa Mina — visão original e adaptação para PC

## Por que o Santa Mina foi criado

Santa Mina nasceu como um **RPG dungeon crawler de tabuleiro, apoiado por um livro de regras**, com a ambição de oferecer **combate tático simples, prático e legível**, uma alternativa mais ágil às rotinas mais complexas de D&D. O jogador deve compreender claramente **o que pode fazer no próprio turno**, mediante **Pontos de Ação (PA)** e **cartas de ações e habilidades**.

A exploração da masmorra é uma jornada de **gestão de recursos e riscos**: guardar Mestre das Armas e Muralha de Ferro para o chefe ou utilizá-los antes para impedir dano significativo é uma decisão fundamental.

## Adaptação para computador

Na mesa, cabe ao jogador responder perguntas sobre a ativação de habilidades. No PC, oferecer janelas de confirmação a cada ocorrência pode quebrar o ritmo. Por isso, **efeitos automáticos mediante condições específicas** (como Mestre das Armas) e **reações confirmáveis somente nos momentos mais decisivos** (como Muralha de Ferro) são uma adaptação intencional. O objetivo é preservar a escolha estratégica e reduzir cliques repetitivos. O design é flexível: regras podem evoluir se forem melhores para a experiência no PC, sem abandonar a identidade do tabuleiro e do livro.

Princípios:
1. **Clareza de turno:** cartas mostram ação, custo de PA, alvo e restrições.
2. **Economia real:** decisões sobre consumir habilidades e provisões têm consequências futuras.
3. **Ritmo:** automatizar ações sem escolhas interessantes; pedir confirmação apenas em decisões relevantes.
4. **Regras auditáveis:** o jogador entende os dados, bônus, Defesa e origem de cada efeito.
5. **Livro e PC:** manter uma base comum, adaptando interface e fluxo quando necessário.

## Descansos — regras aprovadas e implementação HTML5

- **Descanso curto:** permitido em intervalos de segurança, inclusive no ambiente de masmorra. Requer **uma provisão**, aplica o efeito do alimento e permite recuperar **uma habilidade consumível gasta escolhida pelo jogador**. Se nenhuma estiver gasta, ainda pode ser usado para consumir alimento. Não acumula diversas recuperações no mesmo ponto.
- **Descanso longo:** apenas **em ambiente aberto seguro ou hotel**. Requer uma provisão; recupera **todas as habilidades consumíveis gastas** e restaura **metade dos PV máximos (arredondado para cima) + Constituição**, limitado pelo máximo de PV. O alimento também aplica seu efeito.
- **Masmorra/dungeon:** **descanso longo proibido**, com aviso de atenção ao entrar na área.
- **HTML atual:** o descanso ocorre **ao término do encontro, antes do próximo capítulo**, com um descanso por intervalo. O hotel ainda não existe na minicampanha. Alimentos com efeitos reais incluem Pão de queijo (+2 PV temporários) e Caldo de ovo (+1 PV); poções e medicamentos dependem da implementação de itens e de seus efeitos.

## Pendência de decisão de design

O pedido de recuperar uma habilidade **a cada turno** na masmorra não foi ativado **durante o combate**: isso mudaria o papel de habilidades de uso limitado e permitiria ciclos de recuperação na frente dos inimigos. É necessário decidir se descanso curto é uma carta **durante combate com custo de PA e risco**, ou uma **atividade apenas após o fim dos encontros/em salas seguras**. Recomendação: segunda opção para evitar tornar Mestre das Armas e Muralha de Ferro quase infinitas.

Esta documentação é a referência para futuras implementações HTML, Godot e livro de regras.
