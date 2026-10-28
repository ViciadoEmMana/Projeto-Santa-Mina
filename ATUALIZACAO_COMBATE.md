# Interface, formação, fogo amigo e dados 3D

> **24/10/2026 — Protagonista oficial atual: Zeno, Humano Guerreiro.**
> As regras/IDs técnicos abaixo são registros da implementação anterior.
> A transição mantém os sistemas e troca ficha, equipamento e apresentação.
> [Estado atual e validação](docs/ATUALIZACAO_ZENO.md).


## Correção de interação após a iniciativa

O `MarginContainer` de tela inteira e o espaçador sobre a grade estavam com
o filtro padrão de mouse, consumindo cliques antes de `Node2D._unhandled_input`.
Os containers estruturais e espaçadores de `layout_combate.gd` agora usam
`MOUSE_FILTER_IGNORE`. Cartas, botões e painéis interativos mantêm seus filtros.
Não foram alterados regras, posições permitidas, iniciativa ou PA.

Novo `tests/teste_interacao_layout.gd`: envia eventos pela entrada real do
Viewport, sem chamar callbacks de clique. Reproduziu o defeito antes da correção
e depois passou nas sete verificações de iniciativa, posicionamento, seleção
de carta, movimento com custo e botão Encerrar turno. Pode ser executado com
ou sem `--headless` usando o mesmo comando das demais suítes.

## Alterações

- Layout em containers separa fichas, iniciativa, arena, histórico, controles e
  cartas. Área lógica 1280 × 960, ajustada proporcionalmente à tela; a janela
  anterior é restaurada ao sair. Cartas de 192 × 288, descrições de 16 px,
  títulos de 16–18 px e histórico ampliado. Em telas menores, a escala global
  ainda reduz os textos; uma janela maior oferece melhor legibilidade.
- Posicionamento na ordem da iniciativa, antes dos turnos e dos PA. Inimigos
  corpo a corpo escolhem a coluna da frente e a melhor casa livre por caminho
  ortogonal. Consideram obstáculos e posições já confirmadas. Sem herói
  confirmado, usam a fronteira pública da área dos heróis, sem consultar sua
  posição futura. Bandido Arqueiro prefere a segunda coluna; Goblin Tiro, a
  terceira, com alternativas quando ocupadas. O planejador aceita vários heróis.
- Fogo amigo nos arcos cadastrados: natural 1/2 redireciona ao primeiro
  personagem vivo exatamente alinhado entre atirador e alvo, de qualquer facção.
  Obstáculos bloqueiam a linha, inclusive quando cruzados fora do centro da casa.
  Rola-se novamente apenas o dano, com modificadores e Defesa do atingido uma
  única vez. Esse dado não faz outro teste de acerto: resultado 1 nele não
  provoca segundo erro. O natural original vale para defesas condicionais.
  O alvo original não recebe dano e há somente um custo de ataque. Sem
  interceptador, preserva-se a regra normal; natural 3+ não ativa fogo amigo.
  Flecha, impacto e som existentes acompanham o atingido real.
- Dados reais: tetraedro d4, cubo d6, octaedro d8, trapezoedro pentagonal d10,
  dodecaedro d12 e icosaedro d20. Cada face tem seu número alinhado ao sólido.
  A face frontal indica o resultado usado. Material metálico, luz ambiente,
  lançamento e acomodação discretos, azul para heróis e vermelho para inimigos.
  Integra 2d4, vantagem/desvantagem e testes d20; o componente visual recebe
  o resultado e não consome RNG.

PA, custos e efeitos das cinco cartas, fichas, equipamentos padrão, habilidades,
recompensas, descansos, alimentos e progressão foram preservados. Não há novos
críticos. Sprites e áudio existentes não foram substituídos.

## Arquivos criados

- `layout_combate.gd`: apresentação e acompanhamento da arena.
- `formacao_inicial.gd`: escolhas sequenciais e busca de posições por caminho.
- `trajetoria_arco.gd`: interceptação, obstáculos e condição de fogo amigo.
- `geometria_dados.gd`: geometria dos seis sólidos, com cache.
- `dado_poliedrico.gd`: números, materiais, orientação e animação reutilizável.
- `Dados.tscn`, `demonstracao_dados.gd`: mostruário independente dos seis dados.
- `tests/teste_atualizacao.gd`: testes de regras, geometria e interface.
- `tests/capturar_atualizacao.gd`: capturas renderizadas e verificações auxiliares.
- Este documento e os oito PNGs listados abaixo.

## Arquivos modificados

- `combate.gd`: integração do layout, formação, dados e fogo amigo.
- `adaptador_encontro.gd`: visibilidade, posições e dados reais dos inimigos.
- `grade_combate.gd`: participantes não posicionados ainda não ocupam casas.
- `estado_inimigo.gd`, `catalogo_criaturas.gd`: preferência por criatura.
- `equipamentos_combate.gd`: habilitação explícita de fogo amigo no arco curto.
- `ficha_brokk.gd`: arma atual opcional por instância e atributo correspondente;
  equipamento padrão preservado, sem criar menu de troca.
- `regras_combate.gd`: dano redirecionado sem segundo teste de acerto.
- `efeitos_combate.gd`: impacto de fogo amigo mesmo com natural original 1.
- `barra_cartas_basicas.gd`, `carta_combate.gd`: dimensões, fontes e espaçamento.
- `tests/teste_brokk.gd`, `tests/teste_campanha.gd`, `tests/teste_cartas.gd`:
  expectativas visuais atualizadas e fixtures reproduzíveis.
- `CARTAS_COMBATE.md`, `CAMPANHA.md`: referência para esta atualização.

`Combate.tscn`, `cena_principal.tscn`, `tabuleiro.gd` e `project.godot` mantêm
seus conteúdos anteriores. Recursos de campanha não foram substituídos.

## Como testar com F6

1. Abra `Combate.tscn` e pressione **F6**. Aguarde a iniciativa e escolha uma
   casa verde na sua vez de posicionar. Os turnos começam após toda a formação.
2. Use as cinco cartas, selecione alvos/destinos, cancele com **Esc** e encerre
   turnos. Confira PV, PA, resultados, estados indisponíveis e histórico.
3. Abra `Campanha.tscn` com **F6** para os quatro capítulos. Observe os inimigos
   corpo a corpo na frente e Goblin Tiro na terceira coluna. Para fogo amigo,
   alinhe um personagem entre arqueiro e alvo: natural 1/2 provoca redirecionamento,
   rolagem de dano e mensagem própria. A ocorrência depende do dado; os testes
   reproduzem os dois lados e todos os valores de dano.
4. Abra `Dados.tscn` com **F6** para ver os seis tipos e lançar todos novamente.
5. **F5** continua abrindo a cena principal com o tabuleiro original 3 × 6.

Brokk conserva seu equipamento atual. O caminho de arco para jogador está
integrado e testado com arma configurada por instância; não foi inventada
uma classe nova nem interface de equipamento.

## Validação executada

Godot **4.7.2**, GDScript:

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| `tests/teste_brokk.gd` | 906 | 0 |
| `tests/teste_campanha.gd` | 1.009 | 0 |
| `tests/teste_cartas.gd` | 198 | 0 |
| `tests/teste_atualizacao.gd` | 961 | 0 |
| **Total automatizado** | **3.074** | **0** |
| Capturas renderizadas | 14 | 0 |

Foram inspecionadas imagens reais dos seis estados da interface e dos dados.
As suítes verificam geometria, números dentro das faces, orientação, todos os
resultados, ausência de RNG visual, formação dos quatro capítulos, fogo amigo
dos dois lados, Defesa, PA e alvo correto. A campanha completa é exercitada
por ataques, movimento e transições reais. As sementes são apenas fixtures de
teste: o jogo continua com rolagens normais.

Comandos (substitua `Godot` pelo executável local):

```text
Godot --headless --path . --script res://tests/teste_brokk.gd
Godot --headless --path . --script res://tests/teste_campanha.gd
Godot --headless --path . --script res://tests/teste_cartas.gd
Godot --headless --path . --script res://tests/teste_atualizacao.gd
Godot --path . --script res://tests/capturar_atualizacao.gd
```

O ambiente headless informa falha ao ler certificados do Windows; não houve
erro de GDScript nem falha de verificação. A renderização nativa usa ANGLE
como alternativa disponível para o driver gráfico deste computador.

## Capturas reais

- `tests/interface_posicionamento.png`: iniciativa e escolha de casa.
- `tests/interface_turno_jogador.png`: fichas, arena e mão completas.
- `tests/interface_turno_inimigo.png`: turno inimigo e dado vermelho.
- `tests/interface_carta_selecionada.png`: carta e alvo destacados.
- `tests/interface_carta_indisponivel.png`: bloqueio por PA insuficientes.
- `tests/interface_registro.png`: várias mensagens e barra de rolagem.
- `tests/dados_seis_tipos.png`: seis sólidos com seus valores máximos.
- `tests/dados_seis_animados.png`: dados durante a animação.
