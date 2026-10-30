# Registro de mudanças de design (HTML5)

Este arquivo registra as mudanças visuais feitas pela parceira de design (com o Claude) no `html5/principal/index.html`.
A entrada mais nova fica no topo. Cada entrada diz o que mudou, por que mudou e onde mexer no código.
**Regras e jogabilidade não são alteradas nessas entregas**, a não ser que a entrada diga o contrário.

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
