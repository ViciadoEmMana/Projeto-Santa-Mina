# Santa Mina — transição do protagonista para Zeno

Atualização de 24/10/2026, em Godot 4.7.2 e GDScript.

## Protagonista atual

Zeno, Humano Guerreiro nível 1, é o protagonista de Combate.tscn e Campanha.tscn.
FOR +3, DES base +2, CON +3, INT 0, SAB +1, CAR +1; 14/14 PV e 5 PA.
A Espada de Ferro (1H, 1d6 + FOR) e o Escudo de Ferro e Madeira (+2 Defesa nos
naturais inimigos 2/3, −1 DES) são os itens iniciais. DES efetiva +1.
Não há Pele de Rocha nem imunidade anã a Derrubado.

Brokk não é oferecido no fluxo principal. Sua ficha, cenas e artes permanecem
para o protótipo legado e regressões. Os IDs/nós Brokk, sprite_brokk,
ficha_brokk e estado_brokk continuam como identificadores internos; a
identidade exibida vem da ficha. Isso evita renomear grade, IA, dados,
sinais e referências de nós sem necessidade.

## Veterano de Batalha

O estado humano mantém dois registros independentes. Cada um ativa no máximo
uma vez por confronto, não acumula e só fornece +1 enquanto o combate está ativo.

- **Dano:** considera o natural final do dado de ataque da arma, depois de
  Vantagem/Desvantagem e repetições. Se for >= 5, ativa antes do cálculo de dano:
  já vale naquele ataque. Dado descartado, teste d20 e rolagem adicional de dano
  de fogo amigo não substituem o natural do ataque para esse gatilho.
- **Defesa:** uma resolução válida com Defender ativo e dano recebido zero
  ativa +1 para as próximas resoluções. Entra como fonte veterano, separada
  do escudo e Defender. PV temporários absorvendo um dano positivo não são
  tratados como bloqueio sem dano. A função do estado já aceita uma futura
  esquiva confirmada, sem inventar carta, custo ou teste de esquiva.
- A elegibilidade do **escudo automático sem ação Defender** continua
  aguardando a resposta solicitada ao usuário. Nenhum bônus foi inventado
  para esse caso.
- Cabeçalho permanente mostra DEF/DANO +0 ou +1; inspeção/ficha mostram os
  estados. Ativações registram mensagem, partículas azuis/douradas, indicador
  curto e som próprio existente de escudo/corte. A apresentação não sorteia dados.
- Vitória e derrota desativam ambos os bônus. Novo confronto limpa os registros
  raciais e o uso por luta da Espada, preservando habilidades de classe gastas
  e débitos que só o fluxo de descanso/turno pode resolver.

## Espada, Mestre e Muralha

Mestre das Armas mantém sua decisão após o resultado e antes do dano, com
substituição obrigatória de um dado. Em Vantagem só o maior pode ser repetido.
Se o natural final permanecer em 1, a Espada oferece uma repetição opcional
do ataque completo, uma vez por luta, exigindo FOR ou DES efetiva >= 2.
Conserva o modo de rolagem e não cobra outro ataque/PA. Recusar não consome uso.
Os registros de Espada, Mestre e Muralha são separados.

Muralha mantém redução pela metade para baixo e débito de 1 PA no próximo turno.
Físico Atlético e as funções de desafio/doença continuam preparados. Nenhum
crítico ou nova ação de movimentação foi criado.

## Persistência

JSON v2 identifica heroi como Zeno/Humano/Guerreiro. O caminho permanece
user://campanha_v1.json para localizar slots existentes. A leitura migra a
estrutura v1 brokk em memória; não regrava o disco automaticamente.
PV, inventário, recompensas, efeitos, usos e dívidas são preservados.
Arma padrao passa a significar Espada; arma explicitamente equipada permanece.
Veterano nunca é restaurado como bônus ativo fora de confronto.
Os testes usam somente slots temporários próprios.

## Visual e limites

- Fonte nova assets/characters/zeno/zeno_animacoes_fonte_v01.png, criada com
  ImageGen integrado: humano, armadura metálica, tecido verde, espada e escudo.
- 56 AtlasTextures, sete animações de oito quadros: idle, caminhar, correr,
  ataque, defesa, dano e morte. Pés alinhados em uma tela lógica de 384×384.
- O controlador já usado por Brokk aceita os recursos de Zeno. Contato da espada
  no quinto quadro; morte conserva o último quadro.
- As cinco cartas usam recortes das poses novas. As imagens anteriores continuam
  no projeto. Não foram usados assets comerciais nem 32rogues.
- **Arte provisória:** a ilustração oficial mencionada no comando não veio
  anexada. Retrato e refinamento final dependem dessa referência.
- Os sprites atuais representam espada e escudo; variantes visuais de outros
  equipamentos continuam para refinamento futuro.
- Tentativa de teste por Computer Use não prosseguiu: a autorização do app
  expirou. Foram usados renderizador nativo e eventos de mouse/teclado enviados
  à entrada do Viewport do Godot; não afirmar teste físico pelo desktop.

## Arquivos

Criados:

- ficha_guerreiro.gd, ficha_zeno.gd, estado_combate_zeno.gd;
- scenes/characters/Zeno.tscn e os dois recursos em assets/characters/zeno/;
- tools/gerar_atlas_zeno.gd, tests/teste_zeno.gd, tests/capturar_zeno.gd;
- este relatório e arte/PROMPT_ZENO_01.txt.

Modificados:

- ficha_brokk.gd (herda a ficha compartilhada e mantém suas passivas legadas);
- combate.gd, equipamentos_combate.gd, efeitos_combate.gd;
- sistema_campanha.gd, capitulos_campanha.gd, tela_campanha.gd,
  salvamento_campanha.gd;
- layout_combate.gd, inspecao_combate.gd,
  scripts/presentation/brokk_visual.gd;
- fixtures/expectativas de teste_brokk, teste_campanha, teste_cartas,
  teste_salvamento, teste_faca_cega e teste_arena_interface;
- tools/validar_apresentacao.ps1 e documentação principal/correlata.

Não foram alterados tabuleiro.gd, cena_principal.tscn nem project.godot.
Combate.tscn reaproveita seus nós e controlador; a configuração de Zeno ocorre
antes do _ready do ator.

## Validação e como testar

Resultado final da suíte completa: **6.452 verificações, zero falhas**,
incluindo **558 da suíte Zeno**. As regressões legadas de Brokk continuam ativas.
O validador também confirmou os hashes de tabuleiro.gd, cena_principal.tscn
e project.godot, sem alterações.
A importação final no editor headless terminou com código 0 e zero erros de
script/parse/recursos. O ambiente restrito exibiu aviso ao gravar preferências
globais do editor em AppData; isso não foi erro de compilação do projeto.
Captura nativa: **20 verificações, zero falhas**, com posicionamento,
hover, ficha, seleção/cancelamento por Esc, movimento por 2 PA, ataque por 3 PA,
resultado visual 5 e cálculo 5 + FOR 3 + Veterano 1 = 9.

- Abra Campanha.tscn e pressione **F6** para jogar os quatro capítulos com Zeno.
- Abra Combate.tscn e pressione **F6** para o combate independente.
- **F5** continua abrindo o tabuleiro 3×6 original.
- Selecione posição, use cartas e escolha repetições/reações nos diálogos.
- Use Defender e bloqueie um ataque sem dano para observar DEF +1.
- Natural final 5/6 com a espada ativa DANO +1 já no golpe; vencer/perder limpa
  os bônus. Salvar/Carregar permanece disponível apenas fora do confronto.
- Suíte: tools/validar_apresentacao.ps1 -Godot <caminho-do-executavel>.
- Renderização: Godot --path . --script res://tests/capturar_zeno.gd.

Capturas reais inspecionadas:

- [Arena e novo protagonista](../tests/zeno_arena.png)
- [Inspeção por hover](../tests/zeno_inspecao.png)
- [Ficha humana](../tests/zeno_ficha.png)
- [Ataque, d6 em 5 e Veterano Dano +1](../tests/zeno_ataque_veterano.png)
- [Textura real do dado](../tests/zeno_dado.png)
- [Defesa +1 ativa](../tests/zeno_defesa_veterano.png)
- [Campanha com Zeno](../tests/zeno_campanha.png)
