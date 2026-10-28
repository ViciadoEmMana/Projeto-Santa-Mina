# Santa Mina — origem e estado dos assets

## Zeno — 24/10/2026

- Protagonista humano provisório em `assets/characters/zeno/`: imagem criada com
  ImageGen integrado, com fundo transparente, sem imagens comerciais de entrada.
- Descrição usada: humano sério, espada e escudo, armadura metálica e tecido
  verde. A imagem oficial citada pelo usuário ainda não foi recebida.
- Atlas original de 1340×1174, 56 quadros e sete animações. AtlasTextures apenas
  recortam regiões e alinham os pés; os pixels da fonte não foram alterados.
- As cartas usam recortes dessas poses; as ilustrações anteriores permanecem.
- Prompt e configuração: `docs/arte/PROMPT_ZENO_01.txt`.
- Não foram usados assets de 32rogues, Songs of Conquest ou Luiz Melo.
- Sons de ativação reutilizam os WAVs próprios de escudo/corte já existentes.

## Inimigos, ambientes e cartas — 23/10/2026

- Fontes novas em `assets/enemies/bandits/porrete/`, `assets/enemies/goblins/`
  e `assets/enemies/tripa_seca/`: ImageGen integrado, com referências somente
  de personagens/conceito próprios. Humanos e goblins têm silhuetas distintas.
- Quatro fundos em `assets/environments/`, atlas de pisos e props, e ilustrações
  das cinco cartas em `assets/cards/`: mesmo método e referências próprias.
- Prompts completos: `docs/arte/PROMPTS_INIMIGOS_CENARIOS_01.txt`.
  Relatório, versões ativas e limites: `docs/arte/ENTREGA_VISUAL_01.md`.
- São fontes raster geradas por IA, não pixel art desenhada manualmente.
  Não foram usados arquivos comerciais, 32rogues ou capturas com esses assets.
- Seis sons adicionais em `audio/ambiente/`: síntese local determinística, sem
  amostras externas. Gerador `gerar_ambiente.cjs`, WAVs prontos usados pelo Godot.
- O combate/campanha atuais não carregam a textura 32rogues. Os arquivos antigos
  e suas licenças continuam preservados no disco.

## Bandido Arqueiro humano

- Fontes v02 em `assets/enemies/bandits/arqueiro/`: ImageGen integrado, com
  referências exclusivamente próprias. Ações foram revistas após o usuário pedir
  proporção humana; disparo isolado para evitar fragmentos de quadros vizinhos.
- Referência inicial de linguagem: prancha própria aprovada de Santa Mina.
  Revisões usam apenas as imagens próprias do personagem. Nenhuma entrada
  32rogues ou de Songs of Conquest foi usada.
- Prompts: `docs/arte/PROMPTS_ARQUEIRO_01.txt`,
  `PROMPTS_ARQUEIRO_PROPORCOES_V02.txt` e `PROMPTS_ARQUEIRO_LIMPEZA.txt`.
- Rascunhos v01 não são usados pelo recurso final. Estado e arquivos em
  `docs/arte/ARQUEIRO_ANIMADO_V01.md`.

## Complementos de Brokk

- `assets/characters/brokk/brokk_movimento_fonte_v01.png` e
  `brokk_reacoes_fonte_v01.png`: gerados pela ferramenta integrada ImageGen,
  tendo somente o atlas próprio aprovado como referência visual.
- Sem entrada 32rogues ou imagens de jogos comerciais. PNGs-fonte preservados;
  recorte/alinhamento em `brokk_complementos.tres` no Godot.
- Prompts: `docs/arte/PROMPTS_BROKK_COMPLEMENTOS_01.txt`.
- Estado e limitações: `docs/arte/BROKK_ANIMADO_V02.md`.

## Brokk animado — primeira integração

- `assets/characters/brokk/brokk_idle_ataque_fonte_v01.png`: gerado pela ferramenta
  integrada ImageGen, usando somente a prancha própria aprovada como referência.
  Não foram usadas imagens 32rogues ou de Songs of Conquest. Versão animada v01;
  não é arte desenhada manualmente em resolução nativa de 64×64.
- `brokk_animacoes.tres`: recorte e alinhamento em recursos nativos Godot.
- Prompt: `docs/arte/PROMPT_BROKK_ATLAS_01.txt`.
- Brokk não referencia mais a textura legada; os inimigos ainda aguardam
  substituição. Ver `docs/arte/BROKK_ANIMADO_V01.md`.

## Nova direção artística — etapa 1

- `assets/concepts/etapa_01/brokk_covil_v01.png`: proposta visual criada nesta
  sessão com a ferramenta integrada ImageGen, a partir de descrição textual.
  Não foram fornecidas imagens de terceiros, arquivos de 32rogues ou capturas
  que contenham esses sprites. É conceito gerado por IA, ainda não arte final
  aprovada, spritesheet ou cenário jogável.
- Direção solicitada pelo usuário: pixel art detalhada, profundidade e luz
  atmosférica, com inspiração geral em Songs of Conquest. Nenhum asset desse
  jogo foi obtido, importado ou usado como imagem de referência.
- Prompt: `docs/arte/PROMPT_CONCEITO_01.txt`.

## Material próprio existente

- Oito sons em `audio/combate/`: síntese programática local, sem amostras de
  terceiros, documentada em `audio/combate/README.md` e `gerar_sons.js`.
- Geometria e numeração dos dados: componentes procedurais do projeto.
- Molduras/ilustrações geométricas das cartas, grade e efeitos atuais:
  apresentação provisória produzida em código no projeto.

## Material legado de terceiros — não usar na nova produção

- Pacote **32rogues**, Seth Boyles, versões 0.4.0 e 0.5.0 presentes em
  `Assets 32 rogues/`. Licenças locais nos respectivos `LICENSE.txt`.
- A referência da cena de combate foi substituída em 23/10/2026. O pacote não
  foi apagado; os registros anteriores descrevem a transição histórica.
- Por determinação do usuário, não usar esses arquivos na produção de novos
  assets nem como referência de entrada para ferramentas de geração.
- A licença local contém condições e restrições relacionadas a IA generativa;
  não é tratada como autorização para geração ou adaptação por IA.

Este registro deve ser ampliado antes de distribuir versões com novos assets.
