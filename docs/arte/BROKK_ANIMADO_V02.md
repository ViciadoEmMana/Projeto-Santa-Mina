# Brokk — caminhada, corrida, defesa, dano e morte

Continuação da identidade aprovada e da primeira integração idle/ataque.
Versão animada inicial, produzida e integrada no Godot 4.7.2.

## Animações disponíveis

| Animação | Quadros | Acionamento |
| --- | ---: | --- |
| Idle | 8 | Repouso e retorno após ações |
| Machado | 8 | Ataque válido com Machado de Ferro, após dados/decisões |
| Caminhar | 8 | Deslocamento confirmado pela ação Mover |
| Correr | 8 | Deslocamento confirmado pela ação Correr |
| Defesa | 4 | Defender e impacto bloqueado por escudo/Muralha |
| Dano | 4 | Impacto de acerto com dano positivo, sem bloqueio visual |
| Morte | 8 | Transição para 0 PV, uma vez |

Total: 48 quadros em três imagens-fonte. As 16 poses de idle/ataque anteriores
foram preservadas. Duas novas imagens somam 32 poses de deslocamento e reação.

## Integração e preservação

- Mover continua custando 2 PA e Correr 3 PA. Caminho, obstáculos, ocupação e
  destinos continuam definidos pelo sistema atual. Animação não decide movimento.
- Para tornar as passadas visíveis, cada trecho visual dura 0,50 s ao caminhar
  e 0,30 s ao correr, em lugar do deslize anterior de 0,16 s. Isso não muda
  quantidade de casas, duração lógica de efeitos, iniciativa ou rodadas.
- Durante o trajeto, o bloqueio de ações concorrentes já existente é preservado.
  Ao terminar, o sprite volta ao idle. Não há PA ou rolagem extras.
- Defender conserva +2 Defesa e custo de 1 PA. A animação não prolonga o bônus;
  repetir ação já ativa não cobra nem reinicia a pose.
- O resolvedor de efeitos avisa somente a apresentação de Brokk sobre impacto
  ou bloqueio. Defesa, Muralha, dano e PV continuam calculados pelo código atual.
  Erro não provoca reação de acerto.
- Ao chegar a 0 PV, Brokk apresenta a queda; não recupera PV nem ganha ação.
  Ao terminar, fica oculto como no fluxo anterior. O mostruário conserva a
  última pose caída para inspeção e permite reiniciar pelo botão Idle.
- Repetir atualização da interface não reinicia a queda. A reação em andamento
  pode ser substituída pela morte; não fica um callback que retorne ao idle morto.
- Deslocamento e ataque orientam a apresentação horizontalmente. Esta versão
  usa flip_h da animação; poses direcionais com luz própria são polimento futuro.

Não foram modificados IA, dados, cartas, habilidades do chefe, recompensas,
descansos, alimentos ou progressão. Brokk permanece o único herói jogável.

## Arte e alinhamento

ImageGen integrado foi usado para as duas fontes novas, tendo exclusivamente
o atlas próprio aprovado de Brokk como referência. Sem assets 32rogues ou
imagens de Songs of Conquest como entrada. Prompts completos em
[PROMPTS_BROKK_COMPLEMENTOS_01.txt](PROMPTS_BROKK_COMPLEMENTOS_01.txt).

A fonte de movimento tem 1536×1024; a de reações, 1263×1246. Ambas têm alfa.
O fundo RGB visível em alguns visualizadores não é um cenário integrado:
a transparência foi conferida e os quadros renderizam sem retângulos no Godot.

AtlasTexture usa regiões individuais e tela virtual 384×384, sem editar o PNG.
Margens alinham o chão e centralizam as silhuetas. Ajustes de apresentação
compensam diferenças de escala entre as fontes; a raiz do personagem e a casa
de 88×88 permanecem intactas. A pose caída cabe na casa. Filtro nearest é local
ao personagem, sem afetar texto ou dados 3D.

Esses são frames raster detalhados gerados por IA e alinhados no Godot, não
pixel art desenhada manualmente em resolução nativa baixa. Permanecem sujeitos
a polimento de consistência, passadas e variantes direcionais. O conteúdo visual
das reações não cria habilidades novas.

## Arquivos desta entrega

Criados:

- `assets/characters/brokk/brokk_movimento_fonte_v01.png`
- `assets/characters/brokk/brokk_reacoes_fonte_v01.png`
- `assets/characters/brokk/brokk_complementos.tres`
- `tests/teste_brokk_complementos.gd`
- `tests/capturar_brokk_complementos.gd`
- `docs/arte/PROMPTS_BROKK_COMPLEMENTOS_01.txt` e este relatório.
- Oito capturas reais listadas abaixo, além dos metadados de importação Godot.

Modificados:

- `scripts/presentation/brokk_visual.gd`: composição dos recursos por instância,
  deslocamentos, reações, orientação e finalização da morte.
- `scripts/presentation/mostruario_brokk.gd`: botões para as sete animações.
- `combate.gd`: acionamento das animações nas ações reais e visibilidade da queda.
- `efeitos_combate.gd`: aviso de impacto/bloqueio à apresentação de Brokk.
- `tools/inspecionar_atlas_brokk.gd`: aceita caminho-fonte opcional para inspeção.
- `tests/teste_brokk_visual.gd`: valida queda e ocultação após seu encerramento.
- Documentos de arte, inventário, créditos e campanha: referência para este estado.

`Combate.tscn` não precisou ser alterada nesta entrega. O tabuleiro original,
`cena_principal.tscn` e `project.godot` permanecem inalterados. Nenhum arquivo
ou asset legado foi apagado. A substituição dos inimigos ainda está pendente.

## Como testar

1. Abra `BrokkAnimacoes.tscn` com **F6**. Use Caminhar, Correr, Defender, Dano,
   Morte e Idle/reiniciar. A figura pequena mostra a escala real; a maior, 4×.
2. Abra `Combate.tscn` com **F6**, escolha posição e use Mover/Correr. Confira
   destino e PA. Defender aciona a pose; ataques recebidos mostram reações.
3. A campanha usa as mesmas animações. Morte não pode ser acionada por um novo
   botão de combate; é consequência de chegar a 0 PV pelas regras existentes.

## Validação

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| Combate/Brokk | 906 | 0 |
| Campanha | 1.009 | 0 |
| Cartas | 198 | 0 |
| Interface, formação, fogo amigo e dados | 961 | 0 |
| Cliques do layout | 7 | 0 |
| Brokk visual | 68 | 0 |
| Novas animações e integração | 135 | 0 |
| **Total automatizado** | **3.284** | **0** |
| Captura renderizada | 23 | 0 |

As 23 verificações da captura incluem a preparação do encontro; não são 23
imagens. Foram produzidos oito PNGs e inspecionados. Testes exercitam movimento
real, gasto de PA, Defesa, escudo condicional, erro, dano, ataque fatal e o
encerramento da queda. A campanha completa continua coberta pelas regressões.
Avisos ambientais do driver/ANGLE e certificados Windows não são falhas de GDScript.

```text
Godot --headless --path . --script res://tests/teste_brokk_complementos.gd
Godot --path . --script res://tests/capturar_brokk_complementos.gd
```

Capturas em `tests/`:

- `brokk_caminhar_original.png`
- `brokk_correr_original.png`
- `brokk_defesa_original.png`
- `brokk_dano_original.png`
- `brokk_morte_original.png`
- `brokk_caminhada_combate.png`
- `brokk_corrida_combate.png`
- `brokk_morte_combate.png`

O script de captura usa fixtures para iniciativa e para demonstrar derrota,
sem modificar a ficha do jogo; câmera lenta e pausa no evento real de quadro
são usadas apenas para capturar o trajeto, sem forçar posição ou frame.
As animações, o cenário existente e a interface das imagens são renderizados
pelo Godot, não uma montagem de interface.

## Continuação recomendada

Produzir o primeiro adversário original, expandir aos demais e então integrar
o covil em camadas. Cenário autoral, inimigos e sons adicionais continuam pendentes.
