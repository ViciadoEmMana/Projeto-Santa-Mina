# Registro de mudanças de design (HTML5)

Este arquivo registra as mudanças visuais feitas pela parceira de design (com o Claude) no `html5/principal/index.html`.
A entrada mais nova fica no topo. Cada entrada diz o que mudou, por que mudou e onde mexer no código.
**Regras e jogabilidade não são alteradas nessas entregas**, a não ser que a entrada diga o contrário.

---

## 13/11/2026 — Dados 3D menores e opção de texto flutuante

Ramo: `fix/dados-3d-texto-flutuante`. Nenhuma regra ou valor de dado foi alterado.

- Dados 3D: canvas de 64 px e visualização em 48 px (40 px no celular), com disposição adaptável para evitar dados gigantes e sobreposição.
- Configurações (engrenagem): opção **Dados 3D: ligados/desligados**, salva no `localStorage` do navegador.
- Desligado: nenhuma animação de poliedros ou painel de dados; os resultados numéricos aparecem como texto flutuante por um curto período, preservando os registros e cálculos de combate.
- CSS: classes `.floating-roll`, `.dice-panel canvas.die3d`, painel limitado e responsivo.
- JS: controle `dice3DEnabled`, `updateDice3DSettings`, bifurcação inicial de `rollDice`.
- Verificação: código e locais de integração conferidos; ainda requer teste manual de jogabilidade nas duas modalidades.


## 07/11/2026 — Novo design aprovado na tela de combate (pergaminho, pedra e miniaturas)

Pull request: ramo `design/novo-design-interface`. **Nenhuma regra mudou.**

### O que mudou
- **Tela de combate:** em telas a partir de cerca de 800×450, o combate vira um palco fixo de 1600×900, escalado para caber na janela. O fundo é a arte aprovada:
  - caverna e tabuleiro de pedra em perspectiva;
  - ficha em pergaminho à esquerda;
  - cartas ilustradas embaixo;
  - painéis "Ordem de Iniciativa" e "Registro de Combate" à direita;
  - botão "Finalizar Turno".

  Os textos que mudam foram apagados da arte e o jogo escreve por cima: capítulo, rodada, nome e classe do herói, PV, PA, ficha, custos e textos das cartas, iniciativa e registro.
- **Celular:** em celular em pé ou deitado (tela pequena), continua o layout anterior. O menu, os intervalos e as janelas não mudaram.
- **Tabuleiro:** segue a perspectiva da arte. Linhas **A–C** (A em cima) e colunas **1–6**, como no resto do jogo e no registro. A arte original tinha A–F e 1–3, e foi trocada para não confundir.
- **Miniaturas pintadas:**
  - **Quem tem:** Brokk e Goblin do Porrete.
  - **Animação:** andam com pulinho, avançam no ataque, piscam em vermelho ao levar dano, brilham em azul defendendo e tombam na morte.
  - **Quem não tem:** os outros heróis e inimigos continuam com o sprite atual até ganharem miniatura própria.
- **Destaques:**
  - casa do herói com contorno dourado na vez dele;
  - anel dourado (herói) ou vermelho (inimigo) sob quem está agindo;
  - casas de Mover e Correr com brilho suave.
- **Cartas extras:**
  - **Poção de Vida e "Ninguém me pega":** viraram placas no canto inferior esquerdo, no lugar de "Mão/Comprar".
  - **Pancada Sagrada e Botas de Aço (Clérigo):** ficam acima de "Finalizar Turno".
- **Botões do topo da arte:** "?" abre as regras, a engrenagem abre as configurações, o terceiro botão põe em tela cheia. A velocidade 1×/2×/4× fica ao lado deles. Clicar no retrato abre a ficha completa.
- **Fonte:** Alegreya (Google Fonts). Sem internet, cai para Georgia.

### Onde mexer
- **Estilo:** bloco CSS "NOVO DESIGN" no fim do `<style>`. Tudo é escopado em `body.nd`; posições em pixels da arte de 1600×900.
- **Código:**
  - `ND` e `ndX` no topo do script: limites do tabuleiro (`ROWS`, `TL/TR/BL/BR`).
  - `cellCorner`, `unitXY`, `unitBox`, `mouseCell`: usam a perspectiva da arte quando `ND.on`.
  - Módulo "Novo design" antes de `window.__santaMinaTest`:
    - `ND_FIG`: miniaturas e ponto de apoio da base;
    - `ndDrawFig`: animação das miniaturas;
    - `ndRender`: textos da ficha;
    - `ndFit`: escala e regra de quando ligar.
- **Miniatura nova:** acrescente em `ND_FIG` (imagem PNG transparente + `ax/ay` do centro da base) e em `ndFigKey`.

### Testado (Chromium)
- **Telas:** 1600×900, 1440×900 e 1280×720 com Brokk, Zeno, Clérigo e Pequenino, nos capítulos 1 a 4, e celular 390×844 (layout anterior). Nenhum erro.
- **Robô:** jogou com Brokk e com o Clérigo, venceu os capítulos 1 e 2 e chegou ao 3, sem travamento.

---

## 07/11/2026 — Correção: jogo quebrava ao posicionar o Clérigo

Pull request: ramo `fix/clerigo-retrato-render`.

- **Sintoma:** com o Clérigo escolhido, `render()` quebrava assim que ele era posicionado, e o combate não seguia.
- **Causa:** `render()` usava `images[heroType()].src`, mas não existe `images.cleric`. O Clérigo usa o sprite do Zeno (`heroInfo().sprite`).
- **Correção:** o retrato da ficha e o da ordem de turno usam `images[heroType()] || images[heroInfo().sprite] || images.brokk`. Herói novo sem retrato próprio não quebra mais o jogo.
- **Testado no navegador:** Clérigo, Pequenino, Zeno e Brokk posicionam e jogam sem erro.

---

## 30/10/2026 — Correção urgente: jogo travava ao abrir depois do Pequenino Ladino

Pull request: ramo `fix/ladino-capuz-trava-carregamento`.

### 1. Jogo parava de carregar (todos os heróis)
- **Sintoma:** desde o pull request 16, o script quebrava ao abrir a página. Nenhum botão do menu funcionava e a API de teste (`__santaMinaTest`) não existia.
- **Causa:** a ficha `CHARS.halfling` usa `head:'hood'`, mas não tinha a cor `hood`. Ao gerar os retratos de todos os personagens (`portraitURL`), `drawHead` chamava `C(undefined)` e `shadeHex` quebrava.
- **Correção:** `hood:'#3d4a3a'` (capuz verde-escuro) na ficha do Pequenino. Além disso, `drawHead` agora usa `cfg.hood||cfg.hair||cfg.cloth`, então uma ficha nova sem cor de capuz não derruba mais o jogo inteiro.

### 2. Barra de cartas quebrava ao posicionar o herói
- **Sintoma:** ao escolher a casa inicial, `render()` quebrava e o combate não começava.
- **Causa:** a carta nova `slip` ("Ninguém me pega") não tinha ícone em `ICONS`, e `pixIcon(undefined)` quebrava. A carta aparece para todos os heróis (desabilitada para quem não é Ladino), então afetava qualquer herói.
- **Correção:** ícone `ICONS.slip` em pixel art (figura escapando com rastros de movimento). `pixIcon` agora devolve vazio se faltar ícone, em vez de quebrar.

### Testado
- **Teste automático do repositório:** `node tests/verificar_html5.js` continua passando.
- **No navegador (Chromium):** um robô jogou a campanha com Brokk, Zeno e Pequenino. Os três venceram os capítulos 1 e 2, chegaram ao 3 e também jogaram o capítulo 4 pelo "Testar um capítulo". Nenhum erro de JavaScript e nenhum travamento.
- **Por que o teste automático não pegou:** ele lê o código, mas não abre a página. Erros que só acontecem ao rodar passam despercebidos.

---

## 29/10/2026 — Interface de madeira completa, casas com luz suave, pixel do Brokk e goteira do covil

Pull request: ramo `design/interface-madeira-casas-sutis`.

### 1. Tamanho do Brokk corrigido (pixel do cenário = pixel do Brokk)
- **Antes:** em telas de computador o Brokk aparecia gigante, quase do tamanho de duas casas.
  O motivo era que `heroScale()` devolve `PIX`, mas o `PIX` ainda usava a conta antiga (`raw/32`), que dá 4–5 px.
- **Agora:** `PIX=Math.max(1,Math.round(raw*.8/57))` em `layoutBoard`, a mesma conta da versão de design aprovada.
  O Brokk volta a ter cerca de 80% da largura da casa, e o cenário tem o mesmo "grão" de pixel que ele.
- **Onde mexer:** `layoutBoard` (`PIX`) e `heroScale`.
- **Efeitos colaterais:** o Zeno e os inimigos usam `sprScale()` e não mudam. Os enfeites do cenário ficam mais finos e detalhados.

### 2. Casas acendem com luz suave
- **Antes:** ao escolher Mover ou Correr, as casas acendiam como quadrados ciano com borda dura e setinhas.
  Isso ia contra o tabuleiro invisível.
- **Agora:** um brilho suave na cor da luz de cada cenário, mais forte no centro e sem borda.
  As cores ficam no campo `glow` de `PAL`: sol na floresta, verde na mata, dourado no desfiladeiro e tocha no covil.
  Com o mouse em cima, a casa acende mais e ganha um contorno leve.
- **Quando acende:** continua igual. Só na vez do herói: posicionamento inicial, Mover e Correr.
  Na vez do oponente nada acende. O alvo de ataque continua com o brilho vermelho sob os pés (`drawTargetGlow`).
- **Onde mexer:** `drawHighlight` (força na variável `a`, `.3` normal e `.55` com o mouse).

### 3. Interface de madeira e bronze completa
- A V8 já tinha um segundo bloco `:root` com as cores de madeira, mas várias partes continuavam cinza-azuladas:
  - o primeiro `:root`;
  - o fundo das placas (sem veios nem rebites);
  - os botões e a engrenagem;
  - as linhas da ordem de turno e da ficha;
  - o seletor de herói;
  - a etiqueta "VEZ DE…" desenhada no canvas.
- **Agora:** tudo usa a mesma madeira escura com veios, moldura de bronze e rebites nos cantos. O ciano continua só nos destaques de jogo.
- **Onde mexer:** variáveis `--plate-*` e `--wood-grain` em `:root`, regra `.plate`, e `.hero-selector`.

### 4. Som de goteira no covil
- A animação das gotas caindo das estalactites já chamava `sound('drip')`, mas o efeito não existia em `SFX`, então nada tocava.
- **Agora:** `SFX.drip` toca uma goteira baixinha com eco, no máximo uma a cada 0,5 s.

### Testado
- **Telas conferidas:** menu, capítulos 1 e 4 no computador (1440×900) e capítulo 4 no celular (390×844), com Brokk e com Zeno.
- **Resultado:** nenhum erro de JavaScript.

### O que NÃO foi trazido (decisão do autor)
- **Rolagem de iniciativa na tela:** a versão de design mostrava os d20 de cada personagem e a ordem antes da rodada 1.
  Ela não está na V8 e não foi recolocada, porque mexe no fluxo de início de capítulo, que a V8 alterou (bônus de iniciativa da adaga).
