# Santa Mina — cartas básicas permanentes (etapa 1)

> **24/10/2026 — Protagonista oficial atual: Zeno, Humano Guerreiro.**
> As regras/IDs técnicos abaixo são registros da implementação anterior.
> A transição mantém os sistemas e troca ficha, equipamento e apresentação.
> [Estado atual e validação](docs/ATUALIZACAO_ZENO.md).


> Arte atualizada em 23/10/2026: cinco ilustrações próprias integradas, preservando
> molduras, layout, textos, custos e interações. Ver [entrega visual](docs/arte/ENTREGA_VISUAL_01.md).

> Versão atual: veja [ATUALIZACAO_COMBATE.md](ATUALIZACAO_COMBATE.md).
> Cartas agora têm 192 × 288, área lógica de combate 1280 × 960, hover de
> 8 px/2,5% e textos ampliados. Validação atual: 3.074 verificações mais 14
> de captura, zero falhas. O restante deste documento registra a etapa anterior.

## Abrir e jogar

Abra `Combate.tscn` ou `Campanha.tscn` no Godot 4 e pressione **F6**.
F5 continua abrindo o tabuleiro original. A campanha mantém os quatro capítulos,
inventário, comida, descansos, recompensas e as duas reações de Tripa Seca.

Na barra inferior, da esquerda para a direita:

| Carta | PA | Confirmação |
| --- | ---: | --- |
| Ataque | 3 | Selecione a carta e clique num inimigo destacado em dourado. |
| Defender | 1 | Executa a defesa existente: +2 até o próximo turno. |
| Mover | 2 | Selecione a carta e clique numa casa verde válida. |
| Correr | 3 | Selecione a carta e clique num destino válido pelo caminho ortogonal. |
| Ataque com Vantagem | 5 | Selecione a carta e confirme um inimigo destacado. |

Passe o mouse para ver descrição, custo e eventual motivo de indisponibilidade.
Seleção tem borda/faixa dourada e mensagem no registro. **Esc** ou clicar novamente
na mesma carta cancela sem pagar PA. Trocar de carta limpa a seleção anterior.
Ataques e deslocamentos só pagam ao confirmar uma ação válida; Defender executa
no clique. **Encerrar turno** continua separado das cinco cartas.

As cartas permanecem visíveis, inclusive desabilitadas no turno inimigo, durante
animações e após o uso. Não há compra, consumo, descarte, baralho ou cartas especiais.
Não há ações antigas duplicadas por baixo da barra.

## Regras preservadas

As cartas chamam as mesmas funções de ataque, defesa e deslocamento. A resolução
de PA, alcance, obstáculos, Defesa, condições, dados, Mestre das Armas, Muralha,
Golpe Sujo e Me Protejam! continua no combate existente. Vantagem anulada por
Desvantagem mantém custo de 5 PA, sem dano extra nem críticos.

Mover/Correr continuam respeitando modificadores alimentares já existentes,
incluindo Cuscuz. Sem modificadores, os limites são uma/duas casas ortogonais.
A IA, os PA individuais e os cálculos de iniciativa/dano não foram reimplementados.

Se houver outro inimigo vivo em alcance, a carta de ataque fica disponível mesmo
que o alvo previamente indicado esteja distante: é possível confirmar o outro
inimigo. Sem nenhum alvo em alcance, a carta fica escura e explica o motivo.

## Organização e arquivos

Criados:

- `cartas_basicas.gd`: dados de apresentação das cinco cartas; custos vêm de
  `regras_combate.gd`, sem uma segunda tabela de custos.
- `carta_combate.gd`: componente visual baseado em Button, arte substituível,
  estados e tooltip. A categoria aceita dados futuros, com padrão básica permanente.
- `barra_cartas_basicas.gd`: área permanente, composição e um único sinal por ação.
  Uma futura mão especial poderá ser outra área irmã, reutilizando o componente;
  nenhum sistema de cartas especiais foi implementado.
- `tests/teste_cartas.gd`: testes da nova interface e partida pelas cinco cartas.
- `tests/capturar_cartas.gd`: sete capturas e partida com renderização real.
- `tests/cartas_*.png`: capturas da apresentação, seleção e saldo insuficiente.
- Este documento, além de `.uid`/`.import` que o Godot gerar automaticamente.

Modificados:

- `combate.gd`: monta a barra, recebe ações e confirma ataque no alvo. Métodos
  anteriores e referências dos controles foram preservados, sem duplicação.
- `grade_combate.gd`: somente a apresentação dos possíveis alvos em dourado.
- `tests/teste_brokk.gd`: uma expectativa visual considera qualquer alvo em alcance.
- `CAMPANHA.md`: referência à nova interface.

Permanecem intactos `tabuleiro.gd`, `cena_principal.tscn`, `Combate.tscn`,
`Campanha.tscn`, `project.godot`, as fichas, sprites, sons e regras de combate.

## Substituir ilustrações por artes oficiais

Importe sua imagem no projeto e acrescente o campo opcional `arte` na definição
da carta correspondente em `cartas_basicas.gd`:

```gdscript
{"id": "atacar", "nome": "Ataque", "arte": preload("res://artes/ataque.png"),
 "descricao": "Selecione um inimigo em alcance para confirmar o ataque."}
```

Use o caminho real do PNG ou WebP importado, mantendo os demais campos da carta.
O TextureRect `Ilustracao` usa KEEP_ASPECT_CENTERED, preservando a proporção
sem recortar a arte. Nomes, medalhão de PA e efeitos continuam como texto legível.
Também é possível atribuir uma Texture2D à propriedade `arte` de uma instância
de `carta_combate.gd`. Sem arte, o placeholder desenhado no Godot é usado. Nenhuma imagem
externa foi gerada ou baixada.

## Validação

```text
Godot --headless --path . --script res://tests/teste_brokk.gd
Godot --headless --path . --script res://tests/teste_campanha.gd
Godot --headless --path . --script res://tests/teste_cartas.gd
```

As duas suítes anteriores cobrem o combate original, quatro capítulos completos,
IA ofensiva, Sucata, sons, dados e reações do chefe. A suíte nova usa os sinais
das cartas e a confirmação no tabuleiro, verifica custos, cancelamento, bloqueios,
alcance, obstáculos, defesa, anulação de Vantagem, permanência e geometria da UI.
Também executa Golpe Sujo e Me Protejam! pelo fluxo novo de confirmação.

A partida adicional usa todas as cinco cartas e vence o combate com turnos reais,
sem conceder PA, curar Brokk ou alterar PV dos inimigos. As sementes controlam
somente os dados para reprodução. Fixtures de testes isolados não alteram o jogo.

Resultado: **2.001 verificações automatizadas, zero falhas** — 906 do combate,
897 da campanha e 198 das cartas. A captura renderizada executa outras 14
verificações, incluindo uma partida pelas cinco cartas, também sem falhas.

Captura/renderização (sem `--headless`):

```text
Godot --path . --script res://tests/capturar_cartas.gd
```

## Limites desta etapa

A interface de combate usa área lógica de 960 × 720 para reservar espaço abaixo
do tabuleiro. O jogo ajusta a janela ao espaço útil da tela e preserva a proporção
ao redimensionar. Ao sair do combate, restaura tamanho, posição e configuração
de escala da janela anterior. Não modifica `project.godot` nem as outras cenas.
Em janelas menores, toda a interface reduz proporcionalmente; recomenda-se área
próxima de 960 × 720 para máxima legibilidade. A captura 800 × 600 também foi
inspecionada. Tabuleiro, dados, PV e registro permanecem livres.
Não foram adicionados arrastar cartas, atalhos novos ou uma mão especial.

## Redesign visual das cartas

As cartas agora usam tamanho base 152 × 228 (2:3), ilustração ocupando cerca de
43% da altura, cabeçalho com medalhão circular, pergaminho inferior e rodapé.
Moldura de bronze/metal, rebites e gravuras são desenhados localmente. Cada ação
tem sua própria paleta: vermelho, aço azul, musgo, âmbar e ouro/vermelho.

Os recursos existentes são folhas de sprites 32rogues e capturas de interface;
não havia ilustrações oficiais de cartas. Os novos placeholders de espada,
escudo, botas e espadas cruzadas usam formas nativas, com paisagem estilizada.

A mão tem sobreposição de quatro pixels e inclinação discreta. Hover sobe
12 pixels, amplia 3,5% e fica acima das vizinhas; a seleção mantém a elevação
e a moldura dourada. Transições de 0,12 segundo usam tempo real, sem consumir
RNG/PA do combate. Esc restaura a carta. Cartas indisponíveis ficam escuras,
com custo ainda visível, estado no rodapé e motivo no tooltip.

### Arquivos desta atualização visual

- Novo `animacao_carta.gd`: transições visuais separadas da aparência e das regras.
- Modificados `carta_combate.gd`, `barra_cartas_basicas.gd`, `cartas_basicas.gd`:
  composição vertical, TextureRect, paletas, textos curtos, mão e escala temporária.
- Modificado `combate.gd`: somente tipo do componente e espaço da barra/Encerrar.
- Modificados `tests/teste_cartas.gd`, `tests/teste_brokk.gd`: geometria nova e 48
  verificações adicionais de proporção, ilustração, custo, hover, seleção,
  cancelamento, estados, cores, ausência de efeitos nas regras e restauração da janela.
- Modificados `tests/capturar_cartas.gd`, sete capturas e este documento.
- A cena, o tabuleiro original, personagens, regras, campanha, sons e dados 3D
  permanecem intactos. Os hashes dos arquivos originais foram conferidos.

### Capturas reais

- `tests/cartas_basicas.png`: aparência normal da mão.
- `tests/cartas_foco.png`: hover ampliado e elevado.
- `tests/cartas_ataque_selecionado.png`: carta/alvo destacados.
- `tests/cartas_corrida_selecionada.png`: carta/destinos destacados.
- `tests/cartas_dados_3d.png`: dado de ataque visível durante a ação.
- `tests/cartas_pa_insuficientes.png`: bloqueio por saldo de PA.
- `tests/cartas_compactas.png`: janela 800 × 600.
