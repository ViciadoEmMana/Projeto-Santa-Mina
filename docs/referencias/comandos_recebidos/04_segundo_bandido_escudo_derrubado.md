# SANTA MINA — SEGUNDO BANDIDO, PORRETE, ESCUDO VISUAL E DERRUBADO

Atualize o projeto Godot 4 existente, preservando o combate funcional e todos os testes anteriores.

Antes de editar, inspecione a arquitetura de combate, a grade 3×6, os scripts de equipamentos, as fichas, o gerenciamento de turnos, a iniciativa, as animações e os testes.

**Objetivo:** transformar o combate atual de Brokk contra um bandido em Brokk contra dois bandidos, acrescentando elementos visuais para o escudo e o porrete.

## 1. BANDIDO ARQUEIRO EXISTENTE

- Manter o Arco Curto equipado.
- Reduzir PV máximos e iniciais de 8 para **6 PV**.
- Preservar os demais atributos existentes.
- Preservar alcance em todo o tabuleiro e Desvantagem contra inimigos adjacentes ortogonalmente.
- Manter sua participação na iniciativa e nos turnos.

## 2. NOVO BANDIDO DO PORRETE

Criar um segundo inimigo independente, sem substituir o arqueiro.

Atributos:
- Nome: Bandido do Porrete.
- PV máximos e iniciais: 8.
- Defesa: 0.
- FOR: +2.
- DES: 0.
- Arma: Porrete.

Características do Porrete:
- Arma comum.
- Corpo a corpo.
- Uma mão (1H).
- Dano físico: 1d6 + FOR.
- Erro automático somente com 1 natural.
- Alcance de uma casa, incluindo diagonais.
- Ao obter 6 natural, aplica a condição Derrubado ao alvo, desde que o portador tenha FOR +2 ou superior.
- Essa habilidade é equivalente ao efeito especial da Maça de Ferro.
- O efeito do porrete não é um acerto crítico.

O novo bandido deve ter PV, posição, PA, iniciativa e estado de combate próprios.

## 3. COMBATE COM TRÊS PERSONAGENS

Atualizar o gerenciamento de turnos para Brokk, Bandido Arqueiro e Bandido do Porrete.

- Cada participante rola 1d20 + DES efetiva.
- Ordenar os turnos por iniciativa decrescente.
- Preservar a regra existente de desempate, adaptando-a aos três participantes.
- Cada personagem recebe 5 PA por turno, descontadas as penalidades aplicáveis.
- Não permitir que um inimigo morto continue agindo.
- O combate termina com a derrota de Brokk ou dos dois bandidos.
- Atualizar a interface para mostrar claramente quem está agindo.
- Manter o sistema de escolha de posicionamento inicial de Brokk.
- Os dois bandidos começam em casas distintas e desocupadas do lado inimigo, usando posições fixas adequadas.
- O arqueiro deve manter distância quando possível, e o bandido do porrete deve tentar se aproximar para atacar. Implementar decisões simples usando as regras existentes de movimento, PA e alcance, sem criar um sistema complexo de IA.
- A movimentação dos inimigos deve respeitar obstáculos, ocupação, limites da grade e custos de PA.
- Se houver múltiplos alvos inimigos ao alcance de Brokk, permitir selecionar qual atacar.
- Não permitir ataques contra aliados.

## 4. CONDIÇÃO DERRUBADO

Implementar a condição Derrubado de forma reutilizável:

- Ataques contra um personagem Derrubado recebem Vantagem.
- O personagem Derrubado perde 1 PA no início do próximo turno.
- A penalidade deve ser aplicada apenas uma vez por aplicação da condição.
- Para este protótipo, após aplicar a penalidade no início do turno, encerrar a condição Derrubado. Registrar essa decisão como provisória, pois a duração geral das condições ainda poderá ser refinada.
- Preservar a regra de anulação entre Vantagem e Desvantagem.
- Não confundir Derrubado com Crítico.

**Firmeza de Rocha do Brokk:**
- Brokk é imune a Derrubado causado por proezas de armas comuns 1d6 e 1d8.
- Portanto, o Porrete 1d6 não consegue derrubá-lo, mesmo quando obtiver 6 natural.
- O dano normal do ataque ainda é calculado.
- Mostrar uma mensagem como "Firmeza de Rocha: Brokk resistiu ao Derrubado!".
- Preservar a futura vantagem em resistência contra armas pesadas 1d10 e 1d12, sem inventar testes de resistência agora.

## 5. ELEMENTOS VISUAIS

Adicionar um escudo visível ao Brokk e um porrete visível ao novo bandido.

**Escudo de Madeira e Ferro:**
- Aparência medieval, madeira com bordas ou reforços de ferro.
- Posicionar visualmente junto ao braço de Brokk.
- Preservar o Machado de Ferro.
- Não alterar os atributos nem a regra de Defesa já implementados.
- Se não houver sprite adequado, criar um elemento gráfico simples usando Polygon2D, Line2D ou outra solução nativa do Godot.

**Porrete:**
- Aparência de arma rústica de madeira.
- Exibir na mão do novo bandido.
- Se não houver recurso gráfico adequado, criar uma representação simples com elementos nativos do Godot.

Preservar a aparência geral da cena, os sprites existentes e as animações dos dados.

Evitar sobreposição dos personagens, escudo, armas, botões e indicadores de PV.

## 6. PRESERVAR MECÂNICAS EXISTENTES

Não alterar:
- Tabuleiro 3×6 com casas de 88 pixels.
- Posicionamento inicial conforme iniciativa.
- Sistema de 5 PA.
- Movimentação e corrida.
- Ataques físicos e Defesa dinâmica.
- Machado de Ferro e Escudo de Madeira e Ferro de Brokk.
- Arco Curto do arqueiro.
- Pele de Rocha.
- Mestre das Armas.
- Muralha de Ferro.
- Vantagem e Desvantagem, inclusive anulação simultânea.
- Alcance e cadastro das lanças grandes.
- Dados 3D e suas animações.

Não implementar Crítico Padrão ou Crítico Dobrado.

## 7. TESTES

Atualizar os testes automatizados para verificar:
- Arqueiro começa com 6 PV.
- Bandido do Porrete começa com 8 PV, FOR +2, DES 0 e Defesa 0.
- Três participantes entram corretamente na iniciativa.
- Cada participante possui turno e PA independentes.
- Porrete acerta alvos adjacentes, incluindo diagonais.
- Porrete não ataca fora do alcance.
- Resultado natural 6 ativa a tentativa de Derrubado.
- Brokk é imune ao Derrubado do Porrete.
- O dano do Porrete continua sendo aplicado mesmo quando Derrubado é impedido.
- Derrubado concede Vantagem contra alvos não imunes e desconta 1 PA.
- Um bandido derrotado não age.
- O combate continua quando apenas um dos bandidos é derrotado.
- A vitória ocorre quando ambos são derrotados.
- Movimentação, ocupação e seleção de alvos funcionam.
- As habilidades e os testes anteriores continuam passando.

Execute validação headless do Godot e informe o número de verificações e falhas.

Ao concluir, apresente os arquivos alterados, as novas funcionalidades, as regras provisórias e um roteiro simples de testes manuais com F6.

**Prioridade máxima:** não quebrar a versão estável do Santa Mina. Faça apenas as mudanças necessárias e preserve todos os recursos existentes.