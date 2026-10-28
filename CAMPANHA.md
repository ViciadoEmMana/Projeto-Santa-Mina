# Santa Mina — O Covil de Tripa Seca

> **Protagonista atual — 24/10/2026:** Zeno, Humano Guerreiro, com Espada de Ferro
> e Escudo de Ferro e Madeira. Veterano de Batalha tem bônus independentes de
> Defesa/Dano +1, limitados ao combate. Brokk permanece como protótipo legado.
> [Regras, arquivos, migração de save, testes e limites](docs/ATUALIZACAO_ZENO.md).
> **6.452 verificações automatizadas + 20 renderizadas, zero falhas finais.**
> Os registros de validação de 23/10 abaixo são históricos.

> **Goblin Faca Cega — 23/10/2026:** cada d4 representa um golpe. Natural 1
> erra somente aquele golpe; 2/3 ativa o escudo equipado de Brokk (+2 no total,
> mesmo se ambos ativarem). Somam-se os golpes que acertaram, aplicando a Defesa
> uma vez, no mesmo ataque de 3 PA. Dados e registro identificam os dois golpes.
> **Validação: 5.872 verificações automatizadas + 10 de captura nativa, zero
> falhas.** A suíte específica cobre as 16 combinações dos d4, Vantagem,
> Desvantagem, escudo removido, Pele de Rocha, Defender, Muralha, PV temporários,
> PA insuficientes e morte. Tabuleiro, cena principal e configuração preservados.
>
> Arquivos da regra: `catalogo_criaturas.gd`, `regras_combate.gd`, `combate.gd`
> e `efeitos_combate.gd`. Testes: `tests/teste_faca_cega.gd`,
> `tests/capturar_faca_cega.gd` e `tools/validar_apresentacao.ps1`.
> Documentação: este arquivo e `docs/SANTA_MINA_GODOT.md`.
> Para testar jogando, abra `Campanha.tscn` com F6, chegue ao capítulo III e
> deixe o Goblin Faca Cega atacar Brokk. O registro mostra os dois naturais,
> cada acerto/erro, a soma válida, a Defesa e os PV resultantes.

> **Interface de combate — 23/10/2026:** quadros superiores substituídos por
> inspeção ao passar o mouse ou selecionar, PV sobre as cabeças e tabuleiro
> ampliado em 50%. [Controles, arquivos e validação](INTERFACE_ARENA.md).
> **5.049 verificações automatizadas + 53 de captura, zero falhas nesta etapa.**
> Os números dos registros abaixo pertencem às entregas anteriores.

> **Salvamento local — 23/10/2026:** botões **Salvar** e **Carregar** na campanha,
> com um slot manual entre confrontos e cópia de segurança. Capítulo, PV,
> inventário, efeitos e habilidades usadas persistem no disco.
> [Como usar, arquivos e validação](SALVAMENTO.md).
> **5.080 verificações automatizadas e 19 de captura desta etapa, zero falhas.**
> Os registros abaixo documentam as entregas anteriores.

> Apresentação original de 23/10/2026: sete inimigos animados, quatro ambientes,
> ilustrações das cinco cartas e reações visuais do chefe.
> [Arquivos, validação e controles](docs/arte/ENTREGA_VISUAL_01.md).
> **4.314 verificações automatizadas e 55 de captura, zero falhas finais.**
> As contagens abaixo são registros das etapas anteriores.

> Bandido Arqueiro humano original integrado no capítulo I e no combate original:
> [relatório](docs/arte/ARQUEIRO_ANIMADO_V01.md). Validação mais recente:
> 3.374 verificações automatizadas e 21 de captura, zero falhas finais.

> Brokk com sete animações: [BROKK_ANIMADO_V02.md](docs/arte/BROKK_ANIMADO_V02.md).
> Validação mais recente: 3.284 verificações automatizadas e 23 de captura,
> zero falhas. Relatórios anteriores abaixo registram entregas passadas.

> Brokk idle/ataque original integrado: [BROKK_ANIMADO_V01.md](docs/arte/BROKK_ANIMADO_V01.md).
> Validação desta entrega: 3.148 verificações automatizadas e 18 de captura,
> zero falhas. As contagens anteriores abaixo são históricas.

> **Estado das habilidades do chefe:** Golpe Sujo e Me Protejam! já estão
> implementados e testados. A etapa artística aprimorará somente sua apresentação.
> Nova direção visual original: [docs/arte/DIRECAO_ARTISTICA.md](docs/arte/DIRECAO_ARTISTICA.md).

> Atualização mais recente: [ATUALIZACAO_COMBATE.md](ATUALIZACAO_COMBATE.md),
> com interface, formação por iniciativa, fogo amigo e seis dados 3D.
> Validação atual: 3.074 verificações e 14 de captura, zero falhas.
> Contagens abaixo documentam as etapas anteriores da campanha.

## Como jogar

As cinco ações básicas agora são cartas permanentes. Para controles, artes,
arquitetura e testes da etapa 1, consulte [CARTAS_COMBATE.md](CARTAS_COMBATE.md).

Abra `Campanha.tscn` no Godot 4 e pressione F6. O F5 do projeto continua abrindo
o tabuleiro original. `Combate.tscn` continua disponível para F6 e pelo botão
**Combate original** da campanha, com os bandidos usando os novos 3 PA oficiais.

Cada capítulo tem introdução, confronto, vitória e transição. Os PV, os usos das
habilidades, os débitos pendentes, os mantimentos e os efeitos de Zeno persistem
na campanha atual. Use **Salvar** fora do combate para guardar o progresso em
disco e **Carregar** para retomá-lo após reabrir a cena. **Reiniciar** limpa a
partida em memória, mantendo o slot salvo até uma nova gravação. Não há autosave.

Depois do capítulo I, o botão Próximo capítulo leva à preparação no Acampamento
Protegido. Use **Concluir deslocamento** para registrar o final de um turno de
exploração. Escolha um alimento e a habilidade gasta para o Descanso Curto, ou
use Descanso Longo no local seguro. Um descanso consome exatamente uma unidade
e a oportunidade de fim de turno. É preciso concluir outro turno para descansar
novamente. O estoque é finito. Descansar no interior da dungeon nunca permite o
Descanso Longo. Consumir alimentos diretamente é possível apenas na exploração.

As recompensas são concedidas uma vez por vitória completa. Novos equipamentos
ficam guardados no inventário e não substituem a Espada ou o Escudo de Zeno.
A Porção Comum é apenas uma recompensa registrada, com efeito pendente.

## Regras definidas implementadas

- Zeno 5 PA; bandidos/goblins comuns 3 PA; Tripa Seca 4 PA. Custos mantidos.
- Quatro capítulos e todas as fichas especificadas. Defesa da Sucata é 2 total.
- Passo Ágil: uma casa ortogonal gratuita por rodada, respeitando ocupação e
  obstáculos. Não oferece ataque gratuito. Uso consumido só em movimento válido.
- Duas Facas: dois d4 de dano em **um** ataque por 3 PA; ambos os cubos exibem
  seus valores. Vantagem/desvantagem compara a soma de conjuntos completos.
  Cada natural 1 erra só seu golpe. Somam-se os valores dos golpes que acertaram;
  a Defesa é aplicada uma vez. Um ou dois naturais 2/3 ativam um único bônus
  de +2 do escudo equipado de Zeno, com um único efeito visual/sonoro.
- Curto recupera só a habilidade gasta escolhida e não cura por si só.
- Longo em local seguro cura metade dos PV máximos + CON (Zeno: 10), respeita
  o máximo e recupera ambas as habilidades. Ambos aplicam o alimento consumido.
- PV temporários são separados e absorvem dano antes dos PV normais.
- Drops individuais e recompensa final só depois de derrotar todos no confronto.
- IA verifica ataque antes de mover, inclusive na diagonal e com arco em
  Desvantagem ortogonal. Quando necessário, segue o menor caminho livre até
  uma casa de ataque, sem atravessar personagens/obstáculos ou ganhar PA.
- Defesa 2 da Sucata é aplicada uma única vez pelo cálculo centralizado nos
  capítulos II e IV e fica visível no cartão. Já estava presente no estado e
  no cálculo anterior; a atualização acrescenta apresentação e regressões do
  caminho completo do dano, sem duplicar a Tampa de Ferro.
- Golpe Sujo: reação automática de Tripa Seca, uma vez por combate, sem PA,
  após declarar/pagar um ataque corpo a corpo válido. Zeno escolhe DES ou SAB
  efetiva (incluindo equipamentos/alimentos), rola 1d20 contra CD 12. Sucesso
  permite o ataque normal; falha causa erro automático sem devolver PA.
  O d20 azul reutiliza o cubo existente; iniciativa e d6 mantêm seus cálculos.
- Me Protejam!: dano final de pelo menos 5 OU fatal é transferido integralmente
  a um goblin vivo a até uma casa, incluindo diagonais. Prefere mais PV atuais;
  empate usa IDs ordenados. Não cobra PA, não move ninguém e não recalcula Defesa.
  Pode repetir em outros ataques, uma transferência por ataque. Sem aliado
  elegível, o chefe recebe o dano normal. A mensagem oficial aparece no registro.

## Decisões provisórias e pontos em aberto

1. DES da Sucata e FOR dos goblins de arco/facas: 0 provisório, marcado nas fichas.
2. Novos danos seguem literalmente as expressões da ficha: Clava 1d6, Gancho 1d4,
   Arco Podre 1d6−1, Facas 2d4, Espada Curta 1d6. Não se somam atributos adicionais
   não escritos. Os ataques dos bandidos mantêm 1d6+1 e 1d6+2.
3. As Duas Facas possuem regra aprovada por golpe: 1 erra apenas seu golpe,
   2/3 ativa o escudo sem acumular. A soma continua sem natural único: os efeitos
   usam cada resultado real do conjunto selecionado, nunca os dados descartados
   por Vantagem/Desvantagem. Não há críticos.
4. Arco Podre usa provisoriamente alcance e proximidade do Arco Curto.
5. Provisões iniciais de **teste**: uma unidade de cada um dos 14 alimentos/bebidas.
   Não são preços nem um estoque inicial oficial. Configuração em `reiniciar()`.
6. Durações alimentares usam, por padrão, rodadas de combate: uma unidade por
   ciclo terminado, inclusive o último ciclo do confronto. Restante persiste ao
   próximo capítulo. O relógio pode ser `combate`, `exploracao` ou `compartilhado`.
   Mesmo alimento renova seu efeito/duração, sem acumulação infinita. Fontes de
   comidas diferentes permanecem separadas. Pão de Queijo e vantagem contra
   doenças não recebem prazo inventado; temporários acabam ao absorver dano.
7. Cuscuz: provisoriamente +1 casa às ações Mover/Correr, sem alterar seus custos.
   O campo de aplicação fica separado para ajuste futuro.
8. Moqueca guarda bônus de magia e Caldo guarda vantagem contra doenças; não são
   criados sistemas de magia/doença. Galinhada continua sem efeito próprio.
9. Armadilha e Terra nos Olhos continuam desativados, sem regras próprias
   definidas. A areia de Golpe Sujo pertence à reação oficial acima; não ativa
   uma segunda habilidade separada. Me Protejam! não possui limite por combate.
10. Exploração é uma tela de etapas/turnos, sem mapa aberto. Goblins e os demais
    inimigos já usam os sprites próprios animados da entrega visual de 23/10.

## Testes

`Godot --headless --path . --script res://tests/teste_brokk.gd`

`Godot --headless --path . --script res://tests/teste_campanha.gd`

As verificações antigas são mantidas; expectativas de PA inimigos foram adaptadas
de 5 para 3 onde a nova regra oficial exige. Testes isolados de cálculo que
fornecem PA explicitamente não definem o orçamento de um turno real.

A suíte da campanha inclui uma partida completa usando apenas comandos reais
de mover/atacar/defender/encerrar, descanso válido e alimentos fora de combate.
As sementes são fixas nesse teste para reprodução, mas o jogo normal continua
aleatório. Testes de transição também utilizam fixtures de vitória controlada,
separadas dessa partida. As capturas de apresentação usam fixtures explicitadas
em `tests/capturar_campanha.gd` e não representam um salvamento de jogo.

## Arquivos desta atualização

Novos:

- `Campanha.tscn`, `tela_campanha.gd`: entrada e interface narrativa/exploração.
- `sistema_campanha.gd`, `capitulos_campanha.gd`: progresso, estado e narrativa.
- `catalogo_criaturas.gd`, `rolagem_arma.gd`, `adaptador_encontro.gd`: fichas,
  múltiplos dados, PA e apresentação de encontros com até três inimigos.
- `catalogo_consumiveis.gd`, `inventario.gd`, `efeitos_alimentares.gd`,
  `sistema_descanso.gd`: mantimentos, efeitos, equipamento guardado e descanso.
- `tests/teste_campanha.gd`, `tests/capturar_campanha.gd`: testes e capturas reais.
- `tests/campanha_*.png`: início, preparação/descanso, iniciativas, chefe e final.
- Este documento e metadados `.uid`/`.import` gerados pelo Godot, quando presentes.

Modificados:

- `combate.gd`: integração dos encontros/estados, PA individuais, dados e sinal de
  encerramento. A cena `Combate.tscn` não foi substituída nem editada.
- `estado_inimigo.gd`: PA máximos por criatura e ficha independente.
- `ficha_brokk.gd`: modificadores temporários separados dos atributos permanentes.
- `efeitos_combate.gd`: reconhece os dois d4 como um único impacto normal.
- `tests/teste_brokk.gd`: expectativas ajustadas à regra oficial de 3 PA inimigos.

Permanecem intactos: `tabuleiro.gd`, `cena_principal.tscn`, `Combate.tscn`,
`project.godot`, os sprites originais e os oito arquivos WAV de combate.

## Validação desta entrega

- Regressão do combate: 906 verificações, zero falhas.
- Campanha/recursos/interface/partida completa: 897 verificações, zero falhas.
- Total: 1.803 verificações, zero falhas (480 novas sobre as 1.323 anteriores).
- Cena principal original carregada em modo headless.
- Cinco capturas reais geradas e inspecionadas: início, descanso, iniciativa do
  chefe, confronto final e encerramento. As cenas e o tabuleiro originais mantêm
  os mesmos hashes de conteúdo anteriores à atualização.

## Atualização da IA e reações de Tripa Seca

Arquivos alterados nesta atualização:

- `combate.gd`: ataque prioritário, busca de caminho e ambas as reações, com
  pagamento/validação antes de Golpe Sujo e transferência após calcular Defesa.
- `estado_inimigo.gd`: uso temporário separado de Golpe Sujo; turnos não o restauram.
- `catalogo_criaturas.gd`: parâmetros oficiais das duas reações.
- `adaptador_encontro.gd`: Defesa visível e explicação das reações no cartão.
- `tests/teste_brokk.gd`: expectativas de IA ofensiva e Defesa visível.
- `tests/teste_campanha.gd`: 480 verificações adicionais de IA, Sucata e reações.
- `CAMPANHA.md`: regras, testes e este registro de mudanças.

Para testar manualmente: abra `Campanha.tscn` com F6. No primeiro capítulo,
observe o arqueiro atacar sem recuar, mesmo adjacente. Nos capítulos II e IV,
confira Defesa 2 da Sucata e a redução no registro. No capítulo IV, declare um
ataque corpo a corpo contra Tripa Seca e escolha o atributo. Depois de gastar
Golpe Sujo, ataques com dano final 5+ (ou fatal) atingirão um goblin próximo
e exibirão a fala do chefe. Confira os PV dos três inimigos e as casas intactas.

Validação visual adicional: três capturas temporárias do Godot renderizado
inspecionadas (escolha de atributo, resultado do d20 e transferência), sem
alterar sprites, sons ou cenas. As duas suítes continuam executáveis pelos
comandos da seção Testes; a campanha completa também usa ataques reais.
