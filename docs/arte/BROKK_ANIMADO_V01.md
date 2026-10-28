# Brokk — primeira integração animada

> Histórico da integração inicial. Caminhada, corrida, defesa, dano e morte
> foram acrescentados depois: [BROKK_ANIMADO_V02.md](BROKK_ANIMADO_V02.md).

## Entrega

A identidade da etapa 1 foi aprovada pelo usuário. Brokk agora utiliza arte nova
no combate original e na campanha, com oito quadros de idle em loop e oito de
ataque com machado. O desenho segue a prancha aprovada: barba cinza trançada,
tecido azul-petróleo, ferro gasto, machado e escudo de madeira com ferragens.

Esta é uma primeira versão animada integrada, não a conclusão de toda a arte
do jogo. Não foram produzidas ainda caminhada, corrida, defesa, dano ou morte
desenhados quadro a quadro. Movimentação e reação ao dano conservam os efeitos
existentes; Brokk derrotado deixa de aparecer como antes.

## Arquivos

### Criados

- `assets/characters/brokk/brokk_idle_ataque_fonte_v01.png`: atlas transparente
  gerado com ImageGen, tendo apenas a prancha própria aprovada como referência.
- `assets/characters/brokk/brokk_animacoes.tres`: SpriteFrames com 16 AtlasTexture.
- `scripts/presentation/brokk_visual.gd`: apresentação, idle, contato do golpe e
  recuperação. Não acessa PV, PA ou gerador aleatório do combate.
- `scenes/characters/Brokk.tscn`: componente reutilizável com a mesma raiz Sprite2D.
- `BrokkAnimacoes.tscn`, `scripts/presentation/mostruario_brokk.gd`: mostruário
  independente, sem referências a sprites legados, com ampliação e escala real.
- `tools/inspecionar_atlas_brokk.gd`: inspeção de alfa e componentes; não altera
  o PNG-fonte. As regiões detectadas foram conferidas e fixadas no recurso.
- `tests/teste_brokk_visual.gd`, `tests/capturar_brokk_visual.gd`: regressões e
  quatro capturas reais, nos caminhos abaixo.
- `docs/arte/PROMPT_BROKK_ATLAS_01.txt`: prompt completo e método de geração.

### Modificados

- `Combate.tscn`: Brokk usa o novo script e não usa mais a textura 32rogues.
- `combate.gd`: raiz de Brokk em escala 1; aguarda o quadro de contato do machado
  antes dos efeitos existentes; mantém âncora de escudo sem desenhar duplicata.
- Documentos de direção, inventário e créditos: estado atualizado desta entrega.

PNG `.import` e metadados `.uid` são gerenciados pelo Godot.

## Recorte, escala e sincronização

O gerador entregou 1254×1254, não os 1024×1024 pedidos. A distribuição real não
é uma grade perfeita; o recurso usa regiões individuais, sem cortar o machado
nas divisões entre células. Não é necessário editar ou reexportar a imagem-fonte.

Cada quadro tem tela virtual de 384×384 por margem do AtlasTexture. Pés ficam
na mesma linha e o eixo horizontal é alinhado pela coluna original, não pelo
centro da arma. Isso evita deslocar o corpo quando o machado muda de posição.
A apresentação usa 72×72 e corpo de aproximadamente 51 px, cabendo na casa de
88×88. O atlas é uma fonte raster detalhada reduzida na apresentação, não uma
spritesheet originalmente desenhada à mão em 64×64. Há filtro nearest explícito,
sem mudar o filtro dos dados 3D ou da interface.

Idle: 6 quadros/s. Ataque: 12 quadros/s, sem loop. O quadro 4 (índice começando
em zero) emite o contato visual; a resolução existente apresenta os efeitos e
aplica seu dano normalmente. A animação recupera e retorna ao idle. O estado
de rolagem já existente continua bloqueando ações concorrentes.

O nó `BrokkSprite` continua Sprite2D para compatibilidade com flash, offset,
alvos e testes existentes. Seu filho AnimatedSprite2D reproduz os quadros.
O escudo já está pintado no atlas; a âncora antiga continua acompanhando o herói
para efeitos e estado, com desenho transparente para não haver dois escudos.

O ataque com machado só é reproduzido para o Machado de Ferro equipado. Testes
de outras armas continuam usando o caminho anterior, sem apresentar um golpe
de machado como se fosse disparo de arco. O desenho do personagem nesta versão
representa seu equipamento inicial; futuras trocas visuais precisarão de arte.

## Preservação

Não foram alterados dados, custos, atributos, Defesa, alcance, iniciativa,
posicionamento, turnos, cálculo de dano, IA ou habilidades do chefe. Mestre das
Armas continua decidindo o resultado antes da animação do golpe. Erros naturais
podem apresentar o movimento de ataque, mas não criam dano ou impacto de acerto.
Falha em Golpe Sujo continua interrompendo o ataque pelo caminho já existente.

`tabuleiro.gd`, `cena_principal.tscn` e `project.godot` permanecem sem alterações.
Não foram usados assets 32rogues na produção de Brokk; inimigos antigos ainda
têm referências legadas e aguardam seus próprios sprites originais. Não foram
apagados esses recursos nem declarada a substituição completa do pacote.

## Como visualizar

1. Abra `BrokkAnimacoes.tscn` e pressione **F6**. Observe o idle e clique em
   **Atacar com machado**. A figura da direita mostra o tamanho na casa real.
2. Abra `Combate.tscn` com **F6**, escolha uma posição verde, aproxime-se do alvo
   e use Atacar. Observe a animação depois dos dados e da decisão de Mestre.
3. `Campanha.tscn` com **F6** também usa o novo Brokk, sem mudar os capítulos.

Capturas reais: `tests/brokk_idle_original.png`, `tests/brokk_ataque_original.png`,
`tests/brokk_combate_idle.png`, `tests/brokk_combate_ataque.png`. As capturas de
combate usam as fixtures documentadas para reproduzir iniciativa e resultado;
o ataque é executado pelo controlador real, com gasto de 3 PA.

## Validação

Executado no Godot 4.7.2:

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| Combate/Brokk | 906 | 0 |
| Campanha | 1.009 | 0 |
| Cartas | 198 | 0 |
| Interface, formação, fogo amigo e dados | 961 | 0 |
| Cliques reais do layout | 7 | 0 |
| Brokk visual | 67 | 0 |
| **Total automatizado** | **3.148** | **0** |
| Captura renderizada de Brokk | 18 | 0 |

Quatro PNGs inspecionados. A captura renderizada foi executada sem headless e
inclui checks de preparação do encontro. Não são 18 capturas. Os logs headless
continuam emitindo o aviso ambiental de certificados do Windows; não houve erro
de GDScript nas execuções finais. A renderização usou ANGLE neste computador.

```text
Godot --headless --path . --script res://tests/teste_brokk_visual.gd
Godot --path . --script res://tests/capturar_brokk_visual.gd
```

## Próximo trabalho artístico

Finalizar animações restantes de Brokk e produzir adversário original; depois
integrar cenário piloto em camadas. A prancha do covil continua sendo conceito,
não foi aplicada como fundo achatado contendo personagem ou grade desenhados.
