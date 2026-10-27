# Santa Mina — RPG tático de fantasia sombria

Repositório oficial de desenvolvimento do **Santa Mina**, com protótipo jogável em HTML5 e documentação de design para expansão em Godot 4 ou outra engine.

## ▶ Jogar / testar

- Abra [`index.html`](index.html) diretamente no navegador. Este HTML é independente: contém CSS, JavaScript e imagens incorporadas, funciona **offline**.
- Para editar o código, use a versão modular em [`html5/`](html5/). Abra `html5/index.html` junto com `game.css`, `game.js` e `assets/`, ou execute nessa pasta `python -m http.server 8000`.
- Arquivo ZIP da versão modular: [`releases/Santa_Mina_HTML5_Codigo_Fonte.zip`](releases/Santa_Mina_HTML5_Codigo_Fonte.zip).

## O que está implementado

Protótipo HTML5 com Brokk Pedraférrea (14 PV, 5 PA), combate tático 3×6, iniciativa, movimentação, ataques, defesa, cartas básicas permanentes, inimigos com IA simples, mecânicas de Tripa Seca, saques e descansos e **quatro encontros da minicampanha O Covil de Tripa Seca**.

**Atenção:** vertical slice para testes, **não é o jogo completo**. Exploração livre, cartas especiais, dados 3D, arte final, equipamentos trocáveis e a ficha jogável de Zeno estão pendentes. Detalhes e simplificações em [`html5/README.md`](html5/README.md).

## Documentação

- [Documento Mestre 3.0](docs/SANTA_MINA_DOCUMENTO_MESTRE_2026.md) — regras, campanha, arte, mecânicas, escopo e decisões recentes.
- [Comando para IA de desenvolvimento](docs/SANTA_MINA_COMANDO_PARA_IA.md).
- [GDD Universal 2.1](docs/SANTA_MINA_UNIVERSAL.md).
- [GDD Godot 4 2.1](docs/SANTA_MINA_GODOT.md).
- [Registros visuais](screenshots/) — capturas de teste redimensionadas e comprimidas para navegação no GitHub.

## Organização

```text
index.html           # HTML5 autocontido; jogo imediato
html5/               # HTML, CSS, JS, sprites originais e scripts de geração
html5/assets/        # sprites e cenários originais (arte de teste)
docs/                # documento mestre, regras e prompts
screenshots/         # capturas de testes com compactação
releases/            # pacote ZIP editável
```

## Estado dos testes

A versão HTML foi testada em Chromium durante a criação: menu, iniciativa, posicionamento, carta Defender, ataque, reação **Golpe Sujo**, proteção **Me Protejam!**, vitória no primeiro encontro e transição de capítulo. **A campanha completa de ponta a ponta ainda não foi validada**. O histórico de testes é uma descrição da execução anterior, não da publicação no GitHub.

Os arquivos foram organizados a partir do pacote e da documentação de 27/10/2026. O repositório **não inclui** o projeto Godot de um computador local, pois esses arquivos não foram fornecidos neste ambiente. Para preservá-los, será necessário enviá-los separadamente.

## Licenças e créditos

Arte de teste gerada originalmente para Santa Mina. *Songs of Conquest* é somente uma referência visual; não foram importados seus assets. **Nenhuma licença de redistribuição geral foi definida para este repositório.**
