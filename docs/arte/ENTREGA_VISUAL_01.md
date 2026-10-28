# Santa Mina — apresentação original da minicampanha

Entrega de 22–23/10/2026, dando continuidade ao Brokk e ao arqueiro aprovados.
Escopo: concluir a integração visual dos sete inimigos, quatro locais, cartas
básicas e apresentação das reações do chefe. Brokk continua o único jogável.
As regras oficiais não foram reescritas.

## O que foi integrado

| Personagem | Animações e quadros | Onde aparece |
| --- | --- | --- |
| Bandido Arqueiro | Idle 4, caminhada 4, disparo 8, dano 4, morte 8 | Original e capítulo I; visual aprovado preservado |
| Bandido do Porrete | Idle 4, caminhada 4, golpe 8, dano 4, morte 8 | Original e capítulo I |
| Goblin do Porrete | Idle 4, caminhada 4, golpe 4, dano 4, morte 8 | II e IV |
| Goblin Sucata | Idle 4, caminhada 4, gancho 4, dano 4, morte 8 | II e IV |
| Goblin Tiro Certo | Idle 4, caminhada 4, disparo 4, dano 4, morte 8 | III |
| Goblin Faca Cega | Idle 4, caminhada 4, facas 4, dano 4, morte 8 | III |
| Tripa Seca | Idle 4, caminhada 4, espada 4, dano 4, morte 8, reação 4 | IV |

São 180 quadros usados nos sete inimigos. Brokk conserva seu conjunto anterior.
Humanos têm corpo mais alto e pernas longas, conforme a correção do usuário;
goblins são menores, de orelhas compridas e silhueta própria. Cores, roupas e
armas diferenciam as fichas sem conceder equipamento ou bônus novos.
Tripa Seca recebeu uma proposta visual humana e magra; a ficha lógica continua
Humanoide, sem adicionar raça jogável ou passivas raciais.

O porrete humano é empunhado com uma mão. As poses de golpe foram isoladas em
fontes pares/ímpares para impedir fragmentos das poses vizinhas. Faca Cega e
Tripa usam ações v02, com mais espaço entre os quadros. Recorte, margem e pivô
são AtlasTextures nativos: os scripts de ferramentas não editam pixels.

### Cenários e cartas

- Capítulo I: estrada aberta, carroça e mantimentos nas bordas.
- Capítulo II: floresta e caminho sob a copa das árvores.
- Capítulo III: passagem rochosa e entrada da caverna.
- Capítulo IV e combate original: covil/mina, madeira, ferro e luz âmbar.
- Camadas separadas de fundo, piso, props e brilhos discretos. O fundo fica
  escurecido sob a interface; os props não cobrem os controles. As casas continuam
  planas, retangulares, de 88 px, com três linhas e seis colunas.
- Cinco ilustrações próprias nas cartas existentes: machado, escudo, movimento,
  corrida e ataque com Vantagem. Textos, seleção, hover, custos e cancelamento
  continuam nos componentes já existentes. Não foi criado baralho especial.
- A tela de exploração usa o fundo do capítulo, sem mudar seus controles.

### Reações e áudio

Golpe Sujo usa o gesto do chefe e areia visual na direção de Brokk. Me Protejam!
usa o mesmo gesto e destaca o goblin que realmente recebe o dano. Os efeitos
começam no quadro do gesto, sem mover personagens, rolar novamente ou recalcular
a Defesa do protetor. Os limites de uso permanecem no estado de combate.

Seis WAVs adicionais, sintetizados localmente, apresentam passos em pedra/terra,
carta, dados e dois ambientes discretos. Os oito sons de impacto anteriores são
preservados. Não há trilha musical composta nem amostras externas. O jogo não
depende de Node para tocar: usa os WAVs prontos. O gerador está em
`audio/ambiente/gerar_ambiente.cjs`.

## Arquitetura e preservação

- `inimigo_visual.gd`: apresentação compartilhada dos novos inimigos; não lê nem
  altera PV, PA, Defesa, inventário ou RNG. Os recursos configuram escala/quadros.
- `porrete_visual.gd`: configuração pequena sobre esse componente. O arqueiro
  aprovado conserva seu componente próprio e suas animações.
- `adaptador_encontro.gd`: escolhe a cena pela ficha, após preparar os clones.
  IDs reutilizados entre capítulos não confundem humanos, goblins e chefe.
- Nós e referências do controlador/adaptador continuam apontando à mesma
  instância. A âncora antiga do porrete continua válida, porém transparente,
  evitando desenhar uma segunda arma sobre o PNG.
- O impacto físico e a soltura da flecha aguardam os quadros de contato. O alvo
  real do fogo amigo continua sendo o calculado pelo resolvedor existente.
- Morte mantém o último quadro, libera a ocupação e não aplica a antiga rotação
  de 90 graus nem recoloração sobre os sprites próprios.
- `Combate.tscn` não referencia mais a textura 32rogues. Os arquivos antigos
  permanecem no disco, sem serem usados pelo combate/campanha atuais.
- `tabuleiro.gd`, `cena_principal.tscn` e `project.godot` mantêm os hashes de antes
  desta etapa. F5 continua abrindo o tabuleiro original.

Preservados: iniciativa e desempates, posicionamento, turnos, PA individuais,
alcance, Vantagem/Desvantagem, dados 3D, fogo amigo, Defesa de Sucata, escudo,
Pele de Rocha, Muralha, Mestre das Armas, Derrubado, Passo Ágil, habilidades do
chefe, alimentos, descansos, inventário, recompensas e progressão dos capítulos.
O texto antigo da introdução do capítulo IV, que dizia que as habilidades não
eram executadas, foi corrigido. Não foram adicionados críticos.

## Arquivos

### Novos recursos e cenas

- `assets/enemies/bandits/porrete/`: fontes PNG, atlas e inspeções de regiões.
- `assets/enemies/goblins/goblin_{porrete,sucata,tiro,faca}/`: fontes e atlas.
- `assets/enemies/tripa_seca/`: fontes de ações, reações e gesto; atlas.
- `assets/environments/{estrada,floresta,passagem,covil}/`: quatro fundos.
- `assets/environments/pisos/pisos_atlas_v01.png` e `props/props_atlas_v01.png`.
- `assets/cards/cartas_ilustracoes_v01.png` e cinco recursos `.tres`.
- `scenes/characters/BandidoPorrete.tscn`, `GoblinPorrete.tscn`,
  `GoblinSucata.tscn`, `GoblinTiroCerto.tscn`, `GoblinFacaCega.tscn`, `TripaSeca.tscn`.
- `scripts/presentation/inimigo_visual.gd`, `porrete_visual.gd`,
  `cenario_combate.gd`, `audio_ambiente.gd`, `mostruario_porrete.gd`,
  `mostruario_inimigos.gd`.
- `PorreteAnimacoes.tscn`, `InimigosAnimacoes.tscn`.
- `audio/ambiente/`: seis WAVs e gerador reproduzível.
- `tests/teste_porrete_visual.gd`, `teste_visuais_campanha.gd`,
  `capturar_porrete_visual.gd`, `capturar_visuais_campanha.gd` e capturas PNG.
- `tools/montar_atlas_inimigos.mjs`, `perfis_inimigos.json`,
  `corrigir_atlas_porrete.mjs`, `validar_apresentacao.ps1`.

`tools/ampliar_controlador_inimigos.mjs` registra a migração pontual já executada;
possui proteção contra repetição. Não é necessário rodá-lo para jogar ou importar.
Fontes v01 substituídas e o primeiro atlas de ataque do porrete são rascunhos
preservados; não são os quadros usados pela integração final.

### Modificados

`Combate.tscn`, `combate.gd`, `adaptador_encontro.gd`, `efeitos_combate.gd`,
`grade_combate.gd` (só opacidade do piso), `layout_combate.gd` (enquadramento),
`cartas_basicas.gd`, `barra_cartas_basicas.gd`, `tela_campanha.gd`,
`capitulos_campanha.gd` (frase desatualizada), `tools/inspecionar_atlas_brokk.gd`
(saída JSON opcional), inventário/direção de arte, créditos, GDD local e relatórios.

## Validação no Godot 4.7.2

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| Combate/Brokk | 906 | 0 |
| Campanha e quatro vitórias reais | 1.009 | 0 |
| Cartas | 198 | 0 |
| Dados, formação, alcance, fogo amigo, interface | 961 | 0 |
| Input real do Viewport | 7 | 0 |
| Brokk visual | 68 | 0 |
| Complementos de Brokk | 135 | 0 |
| Arqueiro aprovado | 90 | 0 |
| Porrete visual | 154 | 0 |
| Visuais da campanha, cenários, áudio e reações | 786 | 0 |
| **Total automatizado** | **4.314** | **0** |

Captura renderizada: 21 verificações no mostruário/combate do porrete (8 PNGs),
mais 34 no elenco/cenários/chefe (12 PNGs). São 55 verificações de captura, não
55 imagens. As imagens foram inspecionadas; fragmentos do golpe, ordem das
camadas, enquadramento e contraste foram corrigidos durante a revisão.
As duas verificações adicionais conferem que areia e destaque do protetor
começam no quadro 2 do gesto. As cinco telas anteriores de campanha também
foram recapturadas: exploração, descanso, iniciativa do chefe, combate e vitória.
Os avisos ambientais conhecidos de certificado Windows, editor_settings e
fallback ANGLE não são falhas de sintaxe ou execução dos scripts do jogo.

Para repetir as suítes em PowerShell:

```powershell
./tools/validar_apresentacao.ps1 -Godot 'caminho/para/Godot.exe'
```

O script exige um resultado explícito de cada suíte, falha em erro GDScript e
confere os hashes dos três arquivos protegidos. Logs ficam no temporário do SO.
Capturas exigem Godot com renderizador, sem `--headless`:

```text
Godot --path . --script res://tests/capturar_visuais_campanha.gd
```

## Como conferir no editor

1. Abra `InimigosAnimacoes.tscn` e pressione **F6**. Os botões apresentam ataque,
   caminhada, dano, morte e reinício dos sete inimigos e de Brokk, sem gastar PA.
2. `PorreteAnimacoes.tscn` permite conferir o humano ampliado em 3× junto de
   Brokk e arqueiro em escala de combate. Os mostruários anteriores continuam.
3. Abra `Campanha.tscn` com **F6** e use Iniciar confronto. Após iniciativa,
   clique numa casa inicial válida, selecione cartas e confirme alvos/destinos.
   Os locais e inimigos mudam ao avançar os quatro capítulos normalmente.
4. No capítulo IV, ataque Tripa Seca corpo a corpo para escolher DES/SAB no
   Golpe Sujo. Um ataque elegível de dano final 5+ ou fatal destaca o goblin
   protetor adjacente; a transferência mantém os números do cálculo original.
5. `Combate.tscn` com **F6** continua acessível como encontro independente.
   **F5** continua no tabuleiro original.

## Origem e limites desta entrega

Fontes raster produzidas pelo ImageGen integrado com referências exclusivamente
próprias. Não são pixel art desenhada manualmente em resolução nativa. A direção
geral segue a referência de materiais, luz e profundidade aprovada; não foram
usadas imagens de Songs of Conquest, 32rogues ou capturas que os contivessem.
Todos os assets consumidos estão dentro do projeto.

Prompts completos: [PROMPTS_INIMIGOS_CENARIOS_01.txt](PROMPTS_INIMIGOS_CENARIOS_01.txt).
Escalas são uniformes por fonte, com filtro nearest nos sprites. A direção oposta
usa flip_h; não há oito direções redesenhadas nem promessa de 60 FPS medidos.
Os efeitos são nós nativos e tweens reutilizados, não um pacote externo de VFX.

Concluída a integração desta etapa de apresentação. Isso não transforma a
minicampanha em um jogo comercial completo: cartas especiais, outras classes,
outras raças, campanha principal, save em disco e uma trilha musical continuam
fora desta entrega. Mecânicas pendentes no GDD não receberam regras inventadas.
