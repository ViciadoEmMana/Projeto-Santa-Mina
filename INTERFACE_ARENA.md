# Santa Mina — arena maior e inspeção dos personagens

> **24/10/2026 — Protagonista oficial atual: Zeno, Humano Guerreiro.**
> As regras/IDs técnicos abaixo são registros da implementação anterior.
> A transição mantém os sistemas e troca ficha, equipamento e apresentação.
> [Estado atual e validação](docs/ATUALIZACAO_ZENO.md).


Ajuste solicitado em 23/10/2026, após a validação do salvamento.

## Interface

- Os quadros permanentes de Brokk e dos inimigos saíram da faixa superior.
- A iniciativa continua identificada em uma faixa compacta; rodada, ordem dos
  turnos e PA atuais de Brokk permanecem visíveis.
- O tabuleiro ocupa **792×396 px lógicos**, contra os 528×264 anteriores:
  aumento de 50% em cada dimensão. Continua sendo 3 linhas × 6 colunas.
- Cada personagem mostra uma barra e o número de PV atual/máximo sobre a cabeça,
  com azul para Brokk e vermelho para os inimigos. Mudanças de PV atualizam os
  indicadores pelo sinal do estado; a posição acompanha o ator ao se mover.
- Passe o mouse na casa de um personagem ou no seu indicador para inspecioná-lo.
  Clique para fixar os detalhes e poder rolar o conteúdo. **Fechar** ou **Esc**
  devolve o registro de combate.
- A inspeção ocupa a área lateral do registro, sem cobrir a grade, as cartas
  ou o dado. Brokk conserva acesso à ficha completa pelo botão **Ficha**.
- Durante ataques/movimentos, a inspeção dá lugar à apresentação do resultado.
  Não há uma janela modal adicional para selecionar personagens.

Dados mostrados: identificação, PV/PA, arma, condições, atributos e habilidades.
Na inspeção de Brokk, os atributos são os efetivos, incluindo modificadores
existentes; a origem classe/raça continua disponível na ficha completa.
Sucata mostra sua Defesa 2; Tripa Seca mostra as duas reações existentes.

## Preservação

A ampliação usa um único Node2D de apresentação para grade, piso, atores e
efeitos. A lógica continua em casas de 88 px, sem alterar posições táticas,
caminhos, obstáculos, alcance ou custos. Cliques na grade usam seu transform
real; clicar num indicador de PV encaminha a seleção à casa do seu dono.

O componente de inspeção não rola dados, não aplica dano nem gasta PA.
Seleção de alvos, cartas, movimento e ataque continuam no controlador existente.
Dados 3D permanecem fora da arena, nas cores e animações anteriores.
Fundo/props e partículas do escudo foram ajustados ao transform de apresentação.

Permanecem os sistemas de iniciativa, posicionamento, turnos, dano/Defesa,
Vantagem/Desvantagem, fogo amigo, habilidades, inventário, alimento, descanso,
recompensas e salvamento. Nenhum sprite, PNG ou áudio foi substituído.

## Arquivos

Código:

- Novo `inspecao_combate.gd`: inspeção por mouse/seleção e PV sobre os atores.
- `layout_combate.gd`: remove a faixa de quadros, amplia a arena e reorganiza
  os elementos existentes.
- `combate.gd`: instancia a inspeção e prepara a camada de efeitos.
- `scripts/presentation/cenario_combate.gd`: enquadra o fundo na arena ampliada.
- `efeitos_combate.gd`: converte a posição do escudo para o espaço dos efeitos.

Validação:

- Novos `tests/teste_arena_interface.gd` e `tests/capturar_arena_interface.gd`.
- Atualizados os testes de layout em `teste_brokk.gd`, `teste_campanha.gd`,
  `teste_cartas.gd` e `teste_atualizacao.gd`: verificam a inspeção e os
  indicadores novos, substituindo a expectativa dos antigos quadros no topo.
- `teste_arqueiro_visual.gd`, `teste_porrete_visual.gd` e
  `teste_visuais_campanha.gd` verificam os mesmos atores e a ordem do cenário
  dentro do novo nó de apresentação. A câmera é consultada pela referência do
  viewport, que agora pertence à camada de interface.
- `tools/validar_apresentacao.ps1` inclui a nova suíte.
- Dez capturas reais em `tests/arena_*.png`, incluindo a textura do próprio
  viewport 3D, com metadados do Godot.
- Este documento, `CAMPANHA.md` e o registro no GDD local.

`Combate.tscn`, `tabuleiro.gd`, `cena_principal.tscn` e `project.godot`
não precisaram de alterações. F5 continua no tabuleiro original.

## Como conferir

1. Abra `Combate.tscn` ou `Campanha.tscn` com **F6**.
2. Aguarde a iniciativa e clique em uma casa inicial válida.
3. Passe o mouse sobre Brokk e cada inimigo: a lateral mostra os detalhes.
4. Clique no personagem ou no seu PV, tire o mouse e confira a ficha fixada.
   Use a rolagem para ler tudo; **Fechar/Esc** devolve o registro.
5. Ataque e mova pelas cartas: o custo continua o mesmo e o PV acompanha o ator.
6. No capítulo IV, inspecione Sucata e Tripa Seca.

## Validação final — Godot 4.7.2

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| Combate/Brokk | 906 | 0 |
| Campanha e quatro vitórias reais | 1.009 | 0 |
| Cartas | 198 | 0 |
| Dados, formação, alcance, fogo amigo e layout | 838 | 0 |
| Input real da grade | 7 | 0 |
| Brokk visual | 68 | 0 |
| Complementos de Brokk | 135 | 0 |
| Arqueiro visual | 90 | 0 |
| Porrete visual | 154 | 0 |
| Visuais, cenários, áudio e chefe | 786 | 0 |
| Salvamento e combate retomado | 758 | 0 |
| Arena, hover, seleção, PV e ações reais | 92 | 0 |
| Save entre dois processos encerrados/reabertos | 8 | 0 |
| **Total automatizado** | **5.049** | **0** |
| Capturas renderizadas adicionais | 53 | 0 |

As verificações dos quadros antigos foram substituídas pelas verificações do
layout solicitado; por isso a contagem não é uma soma direta sobre a entrega
anterior. Os testes das regras de combate e da campanha foram preservados.
O validador confirmou os hashes originais do tabuleiro, cena principal e
configuração. A importação terminou sem erros de GDScript; os avisos ambientais
conhecidos de certificado Windows, gravação de editor_settings e fallback ANGLE
permanecem separados das verificações do jogo.

Para repetir as suítes e capturas:

```powershell
./tools/validar_apresentacao.ps1 -Godot 'caminho/para/Godot.exe'
```

```text
Godot --path . --script res://tests/capturar_arena_interface.gd
```

As capturas são do renderizador real: arena limpa, inspeção de Brokk/bandido,
personagens em linhas vizinhas, duas resoluções, ataque real com dado e dano
sincronizados, encontro do chefe e sua inspeção. Fixtures de posição/seed são
explícitas no script; a imagem do ataque usa o resolvedor e as animações reais.
O quadro do resultado é congelado só pela ferramenta de captura; os timers
escalados também são congelados, enquanto o SubViewport continua renderizando.
Na imagem do ataque, o d6 azul mostra 2, o registro mostra 2 + 3 = 5 e o bandido
fica com 1/6 PV. São **53 verificações de captura, zero falhas**. As dez imagens
foram inspecionadas, incluindo 1280×960 e 864×648.
Os testes de salvamento continuam usando arquivos temporários isolados.
