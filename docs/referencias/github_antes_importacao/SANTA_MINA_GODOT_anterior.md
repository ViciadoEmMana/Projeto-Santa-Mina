# SANTA MINA — GDD E PROMPT MESTRE | EDIÇÃO GODOT 4
**Versão:** 2.1 — 22/10/2026 • Edição GODOT 4  
**Idioma do jogo:** Português brasileiro  
**Engine obrigatória:** Godot 4.x (GDScript, cenas `.tscn`, recursos `.tres`, sprites, shaders e áudio reais)  
**Plataforma-alvo inicial:** Windows / PC  
**Gênero:** **RPG tático de fantasia sombria com cartas e exploração de masmorras**  
**Estágio:** protótipo de combate e minicampanha testados; documento para consolidação e evolução em um projeto jogável coeso.

> **INSTRUÇÃO PRINCIPAL PARA A IA DESENVOLVEDORA:** Leia integralmente este documento e **crie/complete um projeto Godot real, executável e visualmente elaborado**, preservando as regras aprovadas. Se receber o repositório existente, **inspecione-o primeiro e continue a partir dele**; não reescreva o que já funciona. Se estiver começando do zero, implemente uma versão vertical jogável com a mesma lógica, os mesmos parâmetros e o mesmo escopo de personagem inicial. Não declare funcionalidades implementadas sem testes reais. A execução deve ocorrer **dentro da Godot**, nunca em HTML Canvas, protótipo web ou interface simulada.

---

## 1. Visão criativa e diferenciais

Santa Mina é uma aventura de fantasia medieval sombria focada em **um herói individual, decisões táticas, dados de RPG, equipamentos e cartas universais**, explorando cenários e masmorras predominantemente feitos à mão.

**Pilares inegociáveis:**
1. **Tática por turnos:** tabuleiro de **3 linhas × 6 colunas** no combate, iniciativa, posicionamento, alcance, obstáculos e PA.
2. **RPG com dados e atributos:** FOR, DES, CON, INT, SAB e CAR, testes d20, armas com dados diferentes, defesa, condições e habilidades.
3. **Cartas híbridas:** cinco cartas básicas permanentes e mão/baralho de cartas especiais universais; sinergias, não proibições de classe.
4. **Equipamentos e recursos:** armas, escudos, inventário, saques, comida/bebida e descansos.
5. **Exploração autoral:** cenários, encontros, segredos e recompensas planejados; **pouca geração procedural**.
6. **Apresentação audiovisual própria:** pixel art refinada, sprites animados, efeitos de impacto, magia, partículas, iluminação, áudio e UI legível.
7. **Identidade:** não fazer um protótipo genérico com retângulos e bonecos-placeholder como produto final. Usar nomes, classes, criaturas, regras e ambientação próprias de Santa Mina.

**Não presumir** roguelike, permadeath, mapa aleatório, multiplayer, gerenciamento de cidades ou exércitos. Esses sistemas não são parte do escopo aprovado.

## 2. Referência artística: Songs of Conquest — interpretação permitida

**Referência visual prioritária:** *Songs of Conquest* (Lavapotion), especialmente sua combinação de **pixel art detalhada, profundidade 2.5D, ambientes com camadas, iluminação atmosférica, animações expressivas, partículas, efeitos mágicos, cenários ricos e combate tático visualmente legível**.

**IMPORTANTE:** inspiração em qualidades gerais, **não reprodução** de personagens, sprites, interfaces, cenários, efeitos identificáveis, trilha, logos, mapas, assets ou código do jogo de referência. Criar uma **direção artística original para Santa Mina**, com materiais, silhuetas, paleta, arquitetura, monstros e iconografia próprios.

### Direção concreta
- **Pixel art 2D com apresentação 2.5D**: personagens em sprites, múltiplas camadas de cenário, sombras de contato, luzes e partículas; câmera tática lateral/oblíqua conforme o projeto existente. **Não trocar o tabuleiro 3×6 por hexágonos.**
- Cenários com **pedra úmida, madeira antiga, ferro, vegetação, ruínas, minas e masmorras**, riqueza de detalhes e leitura limpa da grade.
- Sprites com silhueta identificável mesmo pequenos: anão robusto com machado/escudo; bandidos e goblins distintos; arqueiros com arco legível.
- Animações: idle (respiração), ataque, defesa/bloqueio, deslocamento, corrida, dano, morte, reações, uso de item e rolagem de dados. Adicionar anticipation, impacto, recuperação, pequenas vibrações de câmera e efeitos de acerto **sem excesso**.
- FX: trilhas de golpes, faíscas, poeira, sangue estilizado opcional, flechas e rastros, bloqueios, indicadores de dano, condições e destaques de alcance.
- Iluminação: contraste de fontes quentes (tochas) e sombras frias, profundidade por paralaxe e sombras; preservar a legibilidade dos sprites e da UI.
- Áudio: impactos distintos por arma, escudo, passos, flechas, dados, confirmação/cancelamento de carta, ambiente e música discreta.
- UI: pergaminho escuro, bronze, madeira, tipografia nítida; **cartas realmente verticais**, com ilustração, moldura, nome, custo e texto; apresentação de mão inspirada na ergonomia de deckbuilders, mas design original.
- Importação de pixel art: filtros de textura apropriados (evitar borramento), escala coerente, fontes legíveis, não esticar sprites de forma irregular.
- Não usar assets de terceiros sem licença compatível e atribuição quando exigida. Manter `ASSET_CREDITS.md`. Priorizar assets originais e materiais fornecidos pelo usuário.
- Se a IA não tiver gerador de imagens, criar sprites/efeitos originais simples por meios compatíveis com Godot, usar recursos livres licenciados ou sinalizar o que precisa de arte. **Nunca afirmar que há arte final se só existem placeholders.**

## 3. Escopo de personagens — obrigatório nesta fase

**Implementar SOMENTE a classe GUERREIRO e a raça ANÃO como jogáveis**, com o herói **Brokk Pedraférrea**.

Classes futuras **não implementar agora**: Mago, Ladino, Clérigo, Caçador e Feiticeiro. Outras raças também ficam para fases posteriores. A arquitetura pode ser extensível, mas **não criar seletores de classes vazios nem fingir que estão jogáveis**.

### Brokk Pedraférrea
- Raça: Anão; classe: Guerreiro.
- PV máximos: **14**; PA por turno: **5**.
- Bônus da classe: FOR +2, DES +2, CON +2, INT 0, SAB +1, CAR +1.
- Bônus raciais: FOR +1, CON +1. Portanto FOR **+3**, CON **+3**; DES base +2, **DES efetiva +1 com o escudo inicial que impõe −1 DES**.
- Arma inicial: **Machado de Ferro**, dano **1d6 + FOR**; se o resultado natural do dado de arma for **6** e FOR ≥ 2, adicionar **+2 de dano**, conforme implementação existente.
- Escudo inicial: **+2 Defesa quando o dado natural relevante do atacante for 2 ou 3**; penalidade de **−1 DES**.
- **Pele de Rocha:** +1 Defesa natural enquanto PV atuais > metade dos PV máximos.
- **Firmeza de Rocha:** imune a Derrubado por armas 1d6/1d8; Vantagem em resistência contra Derrubado por 1d10/1d12.
- **Físico Atlético (Guerreiro):** Vantagem em desafios puros de FOR e resistência a doenças conforme regras existentes.
- **Mestre das Armas:** uma vez por combate, 0 PA, repetir dado de ataque escolhido após resultado; o novo resultado é obrigatório.
- **Muralha de Ferro:** reação uma vez por combate, reduzir pela metade dano físico recebido (arredondar para baixo), com **1 PA descontado do próximo turno**.
- **Não inventar novas passivas, poderes, níveis, custos ou modificadores sem confirmação.**

## 4. Combate tático: tabuleiro, turnos e PA

### Grade
- **3 linhas A/B/C × 6 colunas 1–6**, casas quadradas (protótipo usava 88 px por casa; adaptar escala visual sem mudar topologia).
- Movimento básico **ortogonal**, não atravessa criaturas/obstáculos.
- Ataque corpo a corpo padrão alcança adjacência **inclusive diagonal** (distância de Chebyshev ≤ 1), salvo regras específicas de arma.
- Algumas lanças alcançam **2 casas inclusive diagonal**, podendo atingir através de unidades/obstáculos segundo regras existentes; movimento nunca atravessa ocupação.
- Arcos sofrem **Desvantagem contra alvo adjacente ortogonal**, não diagonal, conforme regra atual.
- A grade de combate **não é** o mapa inteiro de exploração; separar os dois sistemas.

### Iniciativa e turnos
- Iniciativa: **1d20 + DES efetiva**, maior age primeiro; preservar desempates do projeto existente ou documentar se não existirem.
- Brokk: **5 PA** por turno.
- Inimigos comuns: geralmente **3 PA** por turno.
- Tripa Seca: **4 PA** por turno.
- Gastos de PA são validados antes da ação; seleção/cancelamento/ação inválida **não consomem PA**.
- Ações do jogador bloqueadas durante turno inimigo.
- A IA prioriza **atacar quando o alvo está em alcance e possui PA suficientes**; senão, busca deslocamento útil.

### Cinco cartas básicas permanentes — JÁ TESTADAS
| Carta | PA | Efeito |
|---|---:|---|
| Ataque | **3** | Ataca com a arma equipada |
| Defender | **1** | **+2 Defesa** até o início do próximo turno |
| Mover | **2** | Move **1 casa ortogonal** |
| Correr | **3** | Move **até 2 casas** ortogonalmente, sem atravessar obstáculos |
| Ataque com Vantagem | **5** | Compra Vantagem para um ataque; respeita cancelamento com Desvantagem |

As cinco cartas ficam **sempre disponíveis**, não são compradas, descartadas nem consumidas. Destacar seleção, destinos/alvos válidos, custo, estados indisponíveis; cancelar com **Esc**. Reutilizar as **mesmas funções centrais** de combate, nunca duplicar lógica.

### Rolagens, acerto e dano
- Dados suportados: **d4, d6, d8, d10, d12, d20**; geometria 3D real, faces numeradas, resultado visual idêntico ao resultado lógico; suporte a múltiplos dados (2d4), Vantagem e Desvantagem.
- Vantagem: rolar 2 e selecionar maior; Desvantagem: 2 e selecionar menor; ambas se cancelam.
- **1 natural no dado de ataque da arma normalmente erra**, ressalvada a exceção de fogo amigo de arco.
- **Não há regra universal de crítico aprovada.** Natural máximo pode ativar efeitos específicos de arma, mas não adicionar críticos globais.
- Dano: dados da arma + modificadores pertinentes − Defesa, respeitando limites e regras existentes. Se código atual diferir em detalhes, examinar os testes e registrar a divergência antes de mudar.

### Posicionamento inicial por iniciativa — JÁ TESTADO
- Determinar iniciativa antes de concluir posições iniciais.
- Personagens escolhem posição na ordem de iniciativa.
- Inimigos **corpo a corpo** escolhem a **primeira fileira da área inimiga**, casa válida mais próxima do herói conforme informações disponíveis naquele momento.
- Inimigos **à distância** preferem a **segunda ou terceira fileira inimiga**, configurável por criatura.
- Quem posiciona depois do herói pode reagir à posição real dele; quem posiciona antes não conhece escolha futura.
- Não ocupar obstáculos, unidades ou áreas proibidas; não consumir PA por posicionamento inicial.
- Evitar painéis transparentes interceptando cliques do tabuleiro: ajustar `mouse_filter` e testar seleção real.

### Fogo amigo dos arqueiros — JÁ TESTADO
- Para **arcos**, tanto inimigos quanto heróis.
- Se existe personagem diretamente na **trajetória** entre arqueiro e alvo, e o resultado natural efetivo do dado de ataque for **1 ou 2**, ativa fogo amigo.
- Atinge **o primeiro personagem interceptador** na linha; pode ser aliado ou inimigo.
- O alvo original não recebe o mesmo disparo.
- **Nova rolagem do dado de dano da arma**; aplicar modificadores/Defesa uma vez; custo do ataque uma vez.
- Natural 1 sem interceptador segue erro normal; exceção especial para arcos com interceptador.
- Não aplicar automaticamente a magias ou outras armas.
- Mostrar efeito de flecha e mensagem de log.

## 5. Inimigos, criaturas e minicampanha existente

### Campanha de teste: **O Covil de Tripa Seca**
1. **O Carregamento Desaparecido** — bandido arqueiro **6 PV** e bandido de porrete **8 PV** (3 PA cada).
2. **Rastros na Mata** — Goblin do Porrete **6 PV**, Defesa 0, FOR +1, DES +1, porrete 1d6; Goblin Sucata **6 PV**, **Defesa 2**, FOR +2, gancho 1d4.
3. **A Passagem dos Covardes** — Goblin Tiro Certo **5 PV**, Defesa 0, DES +2, arco podre 1d6−1; Goblin Faca Cega **6 PV**, Defesa 0, DES +2, duas facas cegas **2d4**, deslocamento gratuito de **1 casa por rodada**.
4. **O Covil de Tripa Seca** — chefe Tripa Seca **13 PV**, Defesa 2, FOR +2, DES +2, **4 PA**, espada 1d6, acompanhado de Goblin do Porrete e Goblin Sucata. Vitória só após derrotar **todos** os inimigos.

**Habilidades do chefe:**
- **Golpe Sujo (Comum):** reação **uma vez por combate**, sem custo de PA do chefe, após declaração de ataque corpo a corpo válido contra ele; atacante testa **1d20 + DES ou SAB (à escolha) contra CD 12**. Falha faz o ataque errar; sucesso permite resolução normal. Não vale contra ataques à distância; PA do atacante já gastos.
- **Me Protejam!:** reação sem custo de PA; quando chefe receberia **≥5 de dano final ou dano fatal**, se existir goblin aliado vivo **até 1 casa inclusive diagonal**, transfere **todo o dano já calculado** ao aliado, sem nova Defesa. Se vários, escolher o de maior PV, desempate estável. Pode ocorrer repetidamente enquanto houver protetores válidos; não move unidades.
- Ordem: validar ataque/custo → Golpe Sujo → ataque/dano → Me Protejam! → dano/mortes/saque/vitória.

### Saques e recompensa
- Goblin do Porrete: porrete gasto + **2 coroas**.
- Goblin Sucata: tampa de ferro + **2 coroas**.
- Goblin Tiro Certo: arco gasto + **2 coroas**.
- Goblin Faca Cega: facas cegas + **2 coroas**.
- Tripa Seca: escudo de madeira/ferro + **7 coroas**.
- Total histórico de coroas da campanha, considerando goblins repetidos no capítulo IV: **19 coroas**.
- Recompensa da masmorra: espada de ferro, arco curto e **1 porção/poção comum** com efeito ainda não definido; não inventar efeito.
- Saque único, não equipar automaticamente.
- A campanha atual é **vertical slice de testes**, não história principal definitiva.

## 6. Equipamentos, inventário, alimentação e descansos

- Inventário de armas, escudos, armaduras futuras, itens, ouro/coroas e consumíveis.
- Armas definem tipo de dado, alcance, atributos, condições e efeitos próprios.
- Equipar/desequipar e saquear sem alterar estatísticas de forma silenciosa.
- Alimentos/bebidas são consumidos **fora do combate** e também servem como unidade de **Comida** para descansos; efeito próprio do consumível continua valendo.

### Efeitos de alimentos/bebidas definidos no protótipo
| Consumível | Efeito |
|---|---|
| Pão de queijo | +2 PV temporários |
| Caldo de ovo | Vantagem contra doenças e +1 PV |
| Cuscuz com manteiga | +1 movimento por 3 rodadas |
| Café | +1 iniciativa por 3 rodadas |
| Rabada | +1 dano de arma por 3 rodadas |
| Moqueca | +1 dano mágico por 3 rodadas |
| Galinhada | **Ainda não definido** |
| Cerveja | +1 FOR por 3 rodadas |
| Doce | +1 DES por 1 rodada |
| Costela de porco | +3 PV temporários por 3 rodadas |
| Salada de frutas | +1 DES por 3 rodadas |
| Acarajé | +1 SAB por 3 rodadas |
| Vinho | +1 INT por 3 rodadas |
| Campari | +1 CAR por 3 rodadas |

**Descanso Curto:** fora de combate, ao fim de turno de movimento no mapa, consome 1 alimento/bebida e recupera **exatamente uma habilidade de classe já utilizada**; não recupera PV diretamente, salvo efeito próprio do consumível.

**Descanso Longo:** fora de combate, ao fim do turno em **cidade/vila/acampamento protegido**, **nunca em masmorra**; consome 1 alimento/bebida; recupera todas as habilidades de classe e **metade dos PV máximos + CON** (Brokk: 7+3=10), sem ultrapassar PV máximos; aplicar efeito próprio do consumível.

Algumas durações e efeitos de atributos ainda têm decisões pendentes: documentar em vez de criar regras definitivas.

## 7. Cartas especiais universais — arquitetura, não inventar catálogo numérico

**Decisão aprovada:** **todas as cartas especiais são universais**; Guerreiro pode usar magia, Mago pode usar armadilha, etc. A classe **não bloqueia** cartas. Classes, atributos, habilidades e equipamentos podem melhorar efeitos, custos, duração ou alcance **somente quando regras específicas forem aprovadas**.

Categorias planejadas:
- **Mágicas:** Bola de Fogo, Raio, Mísseis Mágicos, Escudo Mágico, Estaca de Gelo, Sono, Controle Mental, Teleporte, Dreno Vital, Invocação Selvagem etc.
- **Armadilhas:** Armadilha de Urso, Rede, Agulhas Venenosas, Granada de Fumaça, Corda Esticada, Lança Oculta, Chuva de Flechas etc.
- **Ações Rápidas:** Contra-Ataque, Anti-Magia, Ataque Surpresa, Segunda Chance Divina, Defesa de Espinhos, Ponto Fraco, Tática de Batalha etc.

**Status:** cartas básicas estão implementadas; **baralho, compra, mão especial, descarte, custo e efeitos exatos das cartas especiais ainda não foram aprovados/implementados**. O jogo físico original previa **3 cartas iniciais**, mas confirmar adaptação digital antes de consolidar.

Criar estruturas de dados extensíveis (`CardDefinition`, `CardInstance`, `Deck`, `Hand`, `Discard`, `EffectResolver`) **sem fingir que o sistema completo está pronto**. Para a primeira versão jogável, não implementar dezenas de cartas com efeitos inventados; criar apenas quando o usuário definir texto, custos, duração, alvos e timing.

## 8. Exploração e mapas — pouca proceduralidade

- Criar **mapas autorais e fixos** (cidade, floresta, estrada, ruínas, caverna, masmorra), com encontros e tesouros colocados intencionalmente.
- A exploração deve ter cenários artísticos ricos, passagens, baús, armadilhas, interação e transição para o combate 3×6.
- Pequena variação opcional: ordem de eventos menores, saque secundário, efeitos ambientais ou aparições **sem alterar o desenho principal das áreas**.
- Não gerar labirintos aleatórios intermináveis.
- Narrativa principal, NPCs, missões e diálogos completos **ficam para depois**; não inventar enredo canônico. Manter minicampanha de Tripa Seca como conteúdo de demonstração.
- Possíveis referências de lugares já concebidos no universo de tabuleiro: Santa Cruz (igreja, quartel, loja, taverna, banco), porto de Vera Cruz, estradas, ponte, cemitério, acampamento de bandidos e masmorras. **São material de referência, não exigência de implementar tudo agora.**

## 9. Experiência do jogador e interface

### Fluxo jogável mínimo
1. Tela inicial com **Novo Jogo**, **Continuar** (somente se save implementado), **Opções** e **Sair**.
2. Introdução breve não canônica à minicampanha.
3. Brokk anão guerreiro com ficha e equipamentos.
4. Exploração de área construída à mão, interação com ao menos um objeto/saque.
5. Combate tático 3×6 com iniciativa, escolha de posição, cartas básicas, IA e dados 3D.
6. Vitória, saque, inventário, descanso quando permitido, progressão de capítulo.
7. Quatro capítulos de demonstração e encerramento claro.
8. Sem travamentos, botões inacessíveis ou controles invisíveis interceptando mouse.

### Interface de combate
- Ficha de Brokk e fichas dos inimigos legíveis, com PV/PA, condições e atributos relevantes.
- Tabuleiro central com personagens grandes o suficiente para leitura e destaques de alcance/destino.
- Ordem de iniciativa e log de combate em painéis que **não sobreponham** a grade.
- Cinco cartas básicas com proporção vertical, moldura, custo, arte e descrição, em mão inferior; hover eleva/amplia discretamente; seleção dourada; bloqueio por PA.
- Espaço futuro para mão de cartas especiais.
- Botão encerrar turno sempre acessível.
- **Mouse filter** correto em painéis transparentes; clicar casas deve funcionar após iniciativa.
- Suporte a diferentes resoluções; evitar borramento por escala fracionária; texto em pt-BR.

## 10. Pipeline de assets e sprites (obrigatório)

Criar uma estrutura clara, por exemplo:

```text
res://
  scenes/
    menu/
    exploration/
    combat/
    dice/
    ui/
  scripts/
    core/
    combat/
    cards/
    inventory/
    exploration/
    ai/
  assets/
    characters/brokk/
    enemies/bandits/
    enemies/goblins/
    enemies/tripa_seca/
    environments/
    tilesets/
    cards/
    ui/
    vfx/
    audio/sfx/
    audio/music/
  resources/
    characters/
    enemies/
    equipment/
    cards/
  tests/
  docs/
```

### Entregáveis artísticos mínimos do vertical slice
- **Brokk:** sprite original consistente, animações de idle, deslocamento, ataque com machado, defesa, dano e morte.
- **Inimigos:** sprites distintos para bandido arqueiro, bandido porrete, Goblin Porrete, Sucata, Tiro Certo, Faca Cega e Tripa Seca; animações proporcionais à função.
- **Ambientes:** tiles e fundos originais de floresta, passagem e covil/masmorra, com props e iluminação.
- **Cartas:** molduras, medalhões de custo, ilustrações provisórias originais claramente identificáveis, ícones e efeitos de seleção.
- **FX:** slash, impacto contundente, flecha, bloqueio, poeira, dano, morte, destaque de casas e transição de turno.
- **Dados:** seis sólidos 3D reais, faces numeradas, lançamento e parada sincronizados ao resultado.
- **Som:** ao menos variações funcionais de passos, golpes, flecha, escudo, dados, cartas, UI e ambiente.

Usar spritesheets, AnimatedSprite2D/AnimationPlayer, GPUParticles2D/CPUParticles2D, shaders e nós de luz da Godot conforme apropriado. **Não renderizar todo o jogo por desenho manual em `_draw()` nem usar Canvas web**; UI da Godot com Controls é permitida e desejada.

**Qualidade exigida:** sem placeholders genéricos como entrega final. Se os assets finais não forem possíveis nesta execução, separar explicitamente os itens pendentes e fornecer versões temporárias honestamente identificadas.

## 11. Arquitetura técnica e arquivos existentes

Se o repositório existente estiver disponível, verificar primeiro:
- `Combate.tscn`, `Campanha.tscn`, `Dados.tscn`;
- `combate.gd`, `ficha_brokk.gd`, `estado_combate_brokk.gd`, `regras_combate.gd`, `grade_combate.gd`, `equipamentos_combate.gd`, `estado_inimigo.gd`, `condicoes_combate.gd`, `efeitos_combate.gd`, `interface_combate.gd`;
- `formacao_inicial.gd`, `geometria_dados.gd`, `trajetoria_arco.gd`, `layout_combate.gd`;
- documentação `CAMPANHA.md`, `CARTAS_COMBATE.md`, `ATUALIZACAO_COMBATE.md`;
- testes existentes em `tests/`.

**Esses caminhos são referências históricas**: descobrir os caminhos reais, não assumir que todos estão na raiz ou que estão disponíveis no novo ambiente.

Arquitetura: estado de combate separado de apresentação; um único resolvedor de ações; IA usa as mesmas regras de alcance/custo/dano; fichas e equipamentos em dados; UI não decide resultados de dados; componentes de carta reutilizáveis; eventos/sinais para animações e log.

Persistência: verificar se já existe save real; se não, implementar salvamento local simples e testado para progresso entre capítulos e inventário **apenas se couber no escopo**, sem inventar que o protótipo já possui save em disco.

## 12. Plano de execução do pedido de “projeto completo”

**Não confundir “um prompt único” com “fazer tudo de uma vez sem verificar”.** Executar internamente em etapas, sempre mantendo uma versão jogável:

**Fase A — Auditoria e preservação**
- Examinar projeto, cenas, scripts, assets, testes e documentação.
- Rodar o projeto e registrar o que funciona.
- Corrigir apenas regressões bloqueantes.

**Fase B — Vertical slice visual de alta qualidade**
- Atualizar o visual de Brokk, inimigos, cenário e UI com sprites, animações, VFX e áudio originais.
- Preservar grade 3×6 e combate já testado.
- Demonstrar um combate inteiro.

**Fase C — Exploração e campanha**
- Conectar mapas autorais, encontros, loot, inventário, descanso e quatro capítulos.
- Testar transições e progresso.

**Fase D — Polimento**
- Responsividade, legibilidade, feedback, performance, acessibilidade básica, menus, controles, salvamento se implementado.

**Fase E — Preparação para expansão**
- Estrutura de cartas especiais universais e futuras classes/raças, **sem implementá-las antes de aprovação**.

**Critério de sucesso:** um projeto Godot executável e jogável, com identidade audiovisual própria, Brokk Anão Guerreiro, combate tático 3×6, quatro capítulos de demonstração e sistemas aprovados funcionando; sem precisar de um navegador.

## 13. Testes obrigatórios e critérios de aceitação

- Godot abre projeto sem erros de parse, cenas ou recursos ausentes.
- Menu, exploração e combate acessíveis via F5/F6 conforme cenas disponíveis.
- Iniciativa, escolha de posição e clique nas casas funcionam **de verdade**.
- Brokk tem 14 PV e 5 PA; inimigos comuns 3 PA e Tripa Seca 4.
- Cinco cartas têm custos corretos e não são consumidas.
- Mover 2 PA + Atacar 3 PA = 5 PA, sem gastos extras.
- Vantagem/Desvantagem, Defesa, alcance e dados sincronizados.
- Inimigos posicionam conforme iniciativa e estilo de ataque.
- Fogo amigo de arco com natural 1/2 e interceptador, incluindo arqueiro jogador.
- Dados d4/d6/d8/d10/d12/d20 com geometria e valores corretos.
- Golpe Sujo e Me Protejam! conforme regras.
- Inventário, saques únicos, descansos e consumíveis conforme regras.
- Quatro capítulos vencíveis; vitória do chefe somente após todos derrotados.
- Sprites animam corretamente; impactos, flechas e dados sincronizados.
- Textos não cortados, sem UI sobreposta, sem painéis invisíveis bloqueando mouse.
- Capturas de tela reais de combate e exploração, inspecionadas.
- Testes automatizados e testes renderizados; registrar totais e falhas.

**Histórico informado pelo Codex:** última atualização geral reportou **3.074 verificações automatizadas e 14 capturas, zero falhas**; correção posterior do filtro de mouse também testada. **Não repetir esses números como resultado de uma nova execução.**

## 14. Regras de colaboração com o usuário

- O usuário é diretor criativo e aprovador das regras.
- Não inventar custos de cartas especiais, números de progressão, novas classes, raças, habilidades, história principal ou sistemas de crítico.
- Para ambiguidades que alterem equilíbrio, perguntar antes de consolidar; para detalhes visuais reversíveis, fazer proposta original e mostrar capturas.
- Não trocar Godot por Unity, HTML Canvas, JavaScript ou motor próprio.
- Não importar personagens, sprites, UI, áudio ou efeitos extraídos de *Songs of Conquest*.
- Não remover código testado para “simplificar”.
- Não esconder limitações artísticas/técnicas nem declarar jogo completo sem os critérios mínimos.

## 15. Formato obrigatório de entrega da IA

Ao concluir, apresentar:
1. Local do projeto Godot e instruções para abrir/rodar.
2. Resumo do que já existia, do que foi implementado e do que permanece planejado.
3. Lista dos principais arquivos/cenas/assets criados ou alterados.
4. Capturas reais e, se possível, demonstração curta do combate e da exploração.
5. Relatório de testes com quantidade e falhas.
6. Créditos/licenças dos assets de terceiros.
7. Pendências explícitas (principalmente arte final, cartas especiais e história).
8. Próximas tarefas recomendadas, sem modificar regras não aprovadas.

---

# PROMPT EXECUTIVO FINAL (PARA COLAR COM ESTE ARQUIVO ANEXADO)

> Você é uma equipe multidisciplinar de desenvolvimento de jogos Godot 4 (game design, GDScript, pixel art, animação, VFX, UI/UX, áudio e QA). Desenvolva ou complete **Santa Mina**, um **RPG tático de fantasia sombria com cartas e exploração de masmorras**, obedecendo integralmente ao GDD anexo. **Use apenas Godot 4, não HTML Canvas**. Priorize **assets reais, sprites animados, efeitos, cenários feitos à mão e apresentação pixel art 2.5D original**, tomando *Songs of Conquest* apenas como referência de qualidade e linguagem visual, sem copiar assets ou designs protegidos. Mantenha **combate 3×6, iniciativa, PA, cinco cartas básicas, equipamentos, dados d4–d20, posicionamento inimigo, fogo amigo, Brokk Pedraférrea Anão Guerreiro e a minicampanha de quatro capítulos**. **Somente Guerreiro/Anão são jogáveis nesta fase**. Outras classes, raças, história principal e regras de cartas especiais ficam para depois. Cartas especiais serão universais, com futuras sinergias por classe. Prefira **conteúdo autoral fixo e pouca proceduralidade**. Se houver projeto existente, preserve e amplie-o; se não houver, crie um vertical slice completo e executável. Implemente incrementalmente, teste com Godot real, capture telas e relate com precisão o que está funcional, o que é temporário e o que ainda depende de definição ou arte. Não entregue um protótipo genérico e não declare conclusão sem verificação.


## Anexo A — Configuração recomendada para Codex, Claude Code ou Gemini com repositório Godot

1. Abrir o projeto Godot existente e ler `project.godot`, cenas, recursos, testes e documentos antes de editar.
2. Manter nomenclatura, sinais e arquitetura já em funcionamento, inclusive correção de `mouse_filter` do layout de combate.
3. Usar GDScript e recursos nativos Godot 4; importar sprites PNG/WebP e spritesheets como texturas, com filtro adequado à pixel art.
4. Implementar cenas jogáveis, não um preview web. Confirmar as ações por mouse e teclado na janela do jogo.
5. Sempre mostrar capturas da execução e o comando/testes usados. O histórico de testes documentado não substitui uma nova execução.
6. Se a ferramenta não puder acessar o diretório do projeto, solicitar que o usuário forneça os arquivos/repositório; não afirmar que editou o computador do usuário.
