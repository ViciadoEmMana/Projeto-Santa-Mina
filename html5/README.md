# Santa Mina — protótipo jogável HTML5 (27/10/2026)

## Como jogar agora

**Mais simples:** abra `Santa_Mina_Teste_HTML5.html` (arquivo separado, fora deste pacote) com dois cliques no Chrome, Edge ou Firefox. O arquivo HTML é autocontido: inclui código, estilos, sprites e cenários, sem instalação e sem internet.

**Versão editável:** abra `index.html` com o navegador mantendo as pastas `assets/` e os arquivos `game.css` e `game.js` juntos. Para desenvolvimento local, você também pode executar `python -m http.server 8000` nesta pasta e acessar `http://localhost:8000`.

## Funcionalidades para testar

- Menu principal, novo jogo, continuar de checkpoint, ajuda, áudio sintetizado opcional.
- Escolher diretamente qualquer um dos **quatro capítulos** pelo botão **Testar um capítulo**, sem sobrescrever o progresso de uma jornada salva.
- Quatro combates da minicampanha de demonstração **O Covil de Tripa Seca**.
- Iniciativa 1d20 + DES efetiva e posicionamento inicial dependente de iniciativa.
- Tabuleiro de 3 linhas (A–C), 6 colunas (1–6); ocupação de casas, movimentação ortogonal e ataque corpo a corpo adjacente, inclusive diagonal.
- Cartas permanentes: Ataque (3 PA), Defender (1 PA), Mover (2 PA), Correr (3 PA), Ataque com Vantagem (5 PA).
- Brokk Pedraférrea (anão guerreiro): 14 PV, 5 PA, machado 1d6 +3 FOR, bônus especial natural 6, escudo com +2 Defesa em naturais 2/3, Pele de Rocha (+1 DEF enquanto PV > 7).
- Mestre das Armas: rerrolagem opcional após ataque, uma vez entre descansos; Muralha de Ferro: reduz metade do dano e cobra 1 PA no próximo turno.
- Inimigos com IA simples, seus respectivos PV/Defesa/PA, flechas, desvantagem adjacente, fogo amigo quando há um interceptador na trajetória.
- Chefe Tripa Seca: 13 PV, 4 PA, Golpe Sujo, Me Protejam!, vitória apenas ao derrotar todos os inimigos.
- Tela de vitória, saques únicos, contagem de coroas, interlúdio, descanso curto e descanso longo somente em local protegido, consumindo provisões e aplicando efeitos de pão de queijo/caldo de ovo.
- Atalhos: **1–5** escolher carta, **Esc** cancelar, **Enter** encerrar turno.
- Checkpoint local do início do capítulo; ações dentro de um combate não são retomadas exatamente onde pararam.

## Limites honestos desta compilação de testes

Esta build é um **vertical slice de combate e campanha**, não uma implementação completa do GDD. Ainda não inclui o mapa de exploração aberta, mazos especiais, equipamentos trocáveis, todos os alimentos, animações individuais finalizadas, dados físicos 3D, efeitos completos, nem a ficha jogável de Zeno. Os retratos e os cenários são **artes procedurais originais e provisórias**.

A ficha de **Zeno** ainda tem dados importantes em aberto. Por isso o personagem testável é **Brokk**, cujos valores constam do Documento Mestre 3.0. O jogo não inventa PV ou Defesa inicial de Zeno.

### Decisões reversíveis e aproximações de teste

- Os bônus ofensivos dos **bandidos** foram definidos provisoriamente em +1 para possibilitar um combate de teste; o documento não fornece todas as estatísticas ofensivas deles.
- As provisões iniciais escolhidas exclusivamente para testar descansos são 2× pão de queijo e 1× caldo de ovo; não definem o inventário oficial inicial.
- A interface de dado mostra dados estilizados **2D**, com resultados corretos; a geometria 3D real segue pendente.
- Os acampamentos de descanso entre os capítulos 1/2 e 2/3 são locações técnicas de demonstração, não parte oficial do mundo.
- Ataques à distância são simplificados em alcance dentro da grade; teste a exceção de fogo amigo e a desvantagem adjacente com arqueiros.
- A animação de personagens usa sprites 2D desenhados para este protótipo, com pequena oscilação. A arte final detalhada e a exploração 2.5D não estão concluídas.
- Efeitos de duração de consumíveis não utilizados nesta build permanecem para validação futura.

## Testes executados na criação

Os seguintes testes de interação foram executados em Chromium headless usando Playwright, inserindo a versão HTML autocontida:

1. Abertura do menu e da partida, cálculo de iniciativa, posicionamento de Brokk.
2. Carta **Defender** custou 1 PA; turnos de inimigos foram disparados sem erros JavaScript observados.
3. Carta **Ataque** custou 3 PA e reduziu PV de bandido após rolagem, com o diálogo de Mestre das Armas.
4. Teste de Tripa Seca: o **Golpe Sujo** abriu como reação e **Me Protejam!** transferiu dano para um goblin protetor.
5. Primeira batalha vencida via ações normais de ataque e deslocamento; tela de vitória, interlúdio e transição para o capítulo 2 confirmados.

**Ainda não foi feita uma campanha inteira automatizada** e não se afirma paridade completa com o código histórico do Godot.

## Estrutura

- `index.html` — interface de jogo, canvas de combate e layout.
- `game.css` — layout responsivo de fantasia sombria.
- `game.js` — estado, regras, turnos, IA, persistência e efeitos.
- `assets/*.png` — sprites provisórios (original).
- `assets/*.jpg` — paisagens provisórias (original).
- `create_assets.py` — gerador de imagens procedurais originais.
- `build_standalone.py` — gera `../Santa_Mina_Teste_HTML5.html` com todos os recursos incorporados.
- `docs/SANTA_MINA_DOCUMENTO_MESTRE_2026.md` — documento de referência.

## Créditos

Sprites, cenários e interface: produzidos especificamente para esta compilação; não foram utilizados arquivos do jogo *Songs of Conquest* nem assets de terceiros. O nome *Songs of Conquest* aparece no GDD apenas como referência de linguagem visual.
