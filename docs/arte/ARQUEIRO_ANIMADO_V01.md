# Bandido Arqueiro — primeira integração original

## Direção e revisão de proporções

O primeiro adversário original é o Bandido Arqueiro humano do combate original
e do capítulo I. A pedido do usuário, a proposta inicial de corpo atarracado
foi substituída: cabeça menor em relação ao corpo, peito/ombros de porte humano,
tronco e pernas mais longos. A altura corporal renderizada fica em torno de
70 px contra aproximadamente 51 px de Brokk, mantendo os pés no mesmo chão.

O desenho usa cabelo curto escuro, barba por fazer, túnica oliva remendada,
colete de couro, lenço vinho, aljava e arco de madeira. É uma proposta visual,
sem acrescentar história, equipamento lógico, bônus ou habilidade ao inimigo.

As imagens foram geradas com ImageGen integrado. Referências: apenas a prancha
própria de Santa Mina e as versões do próprio personagem. Nenhum arquivo
32rogues, captura com sprites legados ou imagem de Songs of Conquest foi usado
como entrada. A referência do jogo comercial é somente a direção geral de
profundidade, materiais e iluminação definida no GDD.

## Animações

| Nome | Quadros | Integração |
| --- | ---: | --- |
| Idle | 4 | Respiração em loop, sem gastar PA ou RNG |
| Caminhar | 4 | Movimento real da IA; acelera visualmente em corrida |
| Disparo | 8 | Preparar, mirar, soltar e recuperar |
| Dano | 4 | Reação no impacto calculado pelo sistema existente |
| Morte | 8 | Queda e manutenção da última pose no tabuleiro |

O disparo emite o evento de soltura no quadro 5 (índice começando em zero).
Nesse momento começam o som e a flecha já existentes, dirigidos ao alvo real
resolvido, inclusive no fogo amigo. Não ocorre uma segunda resolução de ataque,
um segundo custo ou uma nova rolagem causada pela animação.

Idle e caminhada usam a fonte humana revisada v02. As poses de disparo foram
isoladas em duas fontes próprias para impedir que botas de uma linha entrassem
no recorte de outra. AtlasTexture faz recorte e alinhamento nativos. O chão é
compensado entre fontes e poses; não foi aplicado esticamento horizontal ao PNG.

Há cinco animações e 28 quadros usados. São fontes raster detalhadas geradas
por IA e organizadas em recursos Godot, não pixel art desenhada manualmente em
baixa resolução. Passadas, consistência e variantes direcionais podem receber
polimento posterior. A direção oposta usa flip_h no filho visual.

## Preservação

- A ficha continua com 6 PV, Defesa 0, DES +1, 3 PA e Arco Curto 1d6+1.
- Iniciativa, IA ofensiva, alcance, Desvantagem ortogonal, dados e fogo amigo
  continuam no resolvedor existente. O visual não conhece PV, PA nem RNG.
- Só o Bandido Arqueiro humano recebe a substituição. O ID interno `Bandido`
  também representa goblins e Tripa Seca em outros capítulos; eles não recebem
  a arte humana. Os clones antigos são criados antes da troca visual.
- O nó continua acessível como `BandidoSprite`, e o controlador/adaptador usam
  a mesma instância. Outros sprites não herdam o script do arqueiro.
- Ao morrer, a pose final permanece sem a rotação de 90 graus da arte provisória.
  A casa é liberada e vitória/saques usam os mesmos estados anteriores.
- O visual de movimento do arqueiro dura 0,30 s por trecho. Custos, caminho,
  obstáculos e orçamento individual de PA não foram alterados.
- Brokk permanece o único personagem jogável. Não houve mudança de classe,
  raça, campanha, tabuleiro ou regras do chefe.

## Arquivos novos usados

- `assets/enemies/bandits/arqueiro/arqueiro_acoes_fonte_v02.png`
- `assets/enemies/bandits/arqueiro/arqueiro_reacoes_fonte_v02.png`
- `assets/enemies/bandits/arqueiro/arqueiro_disparo_preparo_v02.png`
- `assets/enemies/bandits/arqueiro/arqueiro_disparo_soltura_v02.png`
- `assets/enemies/bandits/arqueiro/arqueiro_animacoes.tres`
- `scripts/presentation/arqueiro_visual.gd`
- `scripts/presentation/mostruario_arqueiro.gd`
- `scenes/characters/BandidoArqueiro.tscn`
- `ArqueiroAnimacoes.tscn`
- `tests/teste_arqueiro_visual.gd`, `tests/capturar_arqueiro_visual.gd`
- Este relatório e os prompts de produção/revisão/limpeza em `docs/arte/`.

`arqueiro_acoes_fonte_v01.png` e `arqueiro_reacoes_fonte_v01.png` são rascunhos
anteriores à correção do usuário. Não são referenciados pelo recurso final.
Não foram apagados recursos legados nem substituídos os demais inimigos.

Modificados: `adaptador_encontro.gd`, `combate.gd`, `efeitos_combate.gd`,
`tools/inspecionar_atlas_brokk.gd` (inspeção com número de linhas e apoio dos pés),
inventário de arte, créditos e documentação. `Combate.tscn` não precisou mudar.
O mostruário reserva altura acima do personagem para o arco erguido, sem
invadir título ou subtítulo. `tests/teste_cartas.gd` aguarda um frame após os
timers de hover/seleção: a execução paralela revelou uma disputa de ordem entre
timer e tween. As mesmas asserções e contagens foram preservadas; não houve
mudança no comportamento das cartas.

## Como testar no Godot

1. Abra `ArqueiroAnimacoes.tscn` com **F6**. A figura maior permite inspecionar
   as poses, e a comparação à direita mostra Brokk e humano em casas de 88×88.
   Use Disparar, Caminhar, Dano, Morte e Idle/reiniciar.
2. Abra `Combate.tscn` com **F6**. Após iniciativa e posicionamento, encerre
   o turno para observar o disparo do arqueiro. Aproximar Brokk ortogonalmente
   mantém a Desvantagem do arco, sem movimento inútil para compensá-la.
3. Abra `Campanha.tscn` com **F6**. O novo arqueiro aparece no capítulo I;
   capítulos II–IV preservam os sprites atuais de goblins e do chefe.
4. Fogo amigo: com outro personagem na trajetória, natural 1/2 mantém o
   redirecionamento e a nova rolagem de dano. As regressões cobrem os valores.

## Validação e capturas

Executado no Godot 4.7.2:

| Suíte | Verificações | Falhas finais |
| --- | ---: | ---: |
| Combate/Brokk | 906 | 0 |
| Campanha | 1.009 | 0 |
| Cartas | 198 | 0 |
| Interface, formação, fogo amigo e dados | 961 | 0 |
| Cliques | 7 | 0 |
| Brokk visual | 68 | 0 |
| Complementos de Brokk | 135 | 0 |
| Arqueiro visual | 90 | 0 |
| **Total automatizado** | **3.374** | **0** |
| Captura renderizada | 21 | 0 |

O teste específico confere proporção relativa a Brokk, fontes revisadas, margens,
referências dos nós, isolamento dos outros capítulos, disparo real, custo único,
RNG, movimento da IA, reação, morte e ocupação. As regressões cobrem fogo amigo
dos dois lados e os quatro capítulos. A falha intermitente de hover na execução
paralela foi corrigida na sincronização do teste e reexecutada; o quadro acima
registra os resultados finais. Avisos ambientais de certificado Windows e driver
ANGLE não alteram as verificações do jogo.

As 21 verificações da captura incluem preparação do encontro; são oito imagens,
não 21 capturas. Elas foram renderizadas e inspecionadas, incluindo a correção
de fragmentos no disparo e o enquadramento da ampliação no mostruário.

Capturas reais em `tests/`:

- `arqueiro_humano_comparacao.png`
- `arqueiro_disparo_original.png`
- `arqueiro_caminhada_original.png`
- `arqueiro_dano_original.png`
- `arqueiro_morte_original.png`
- `arqueiro_combate_idle.png`
- `arqueiro_combate_disparo.png`
- `arqueiro_combate_morte.png`

As capturas de combate usam fixtures de iniciativa e estado para reprodução;
o disparo e o ataque fatal passam pelos controladores reais. A pausa de captura
é feita no evento de soltura, sem montar interface ou pintar personagens por cima.

```text
Godot --headless --path . --script res://tests/teste_arqueiro_visual.gd
Godot --path . --script res://tests/capturar_arqueiro_visual.gd
```

## Pendências

Os demais inimigos ainda precisam de sprites próprios, começando pelo Bandido
do Porrete. O covil em camadas permanece uma etapa posterior. A produção atual
não significa que todos os assets provisórios do projeto já foram substituídos.
