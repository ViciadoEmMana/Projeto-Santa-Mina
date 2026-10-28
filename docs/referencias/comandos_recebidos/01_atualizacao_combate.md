ATUALIZAÇÃO DO SISTEMA DE COMBATE — SANTA MINA (GODOT 4)

Analise primeiro o projeto existente, especialmente combate.gd, ficha_brokk.gd, estado_combate_brokk.gd, Combate.tscn e os testes. Implemente a atualização abaixo aproveitando a arquitetura atual.

IMPORTANTE:
- Não recrie o projeto.
- Preserve o tabuleiro 3x6, cenas, sprites, animações, dados 3D, iniciativa, habilidades Mestre das Armas e Muralha de Ferro, barras de PV e fluxo de combate.
- Não apague arquivos ou funcionalidades.
- Faça mudanças incrementais e mantenha compatibilidade com Godot 4.
- Não implemente ainda críticos, magias, doenças ou estados adicionais.

1. REGRA GERAL DE ERRO NATURAL
Todos os ataques físicos com arma, inclusive os ataques do bandido, erram automaticamente SOMENTE quando o resultado natural do dado de ataque é 1.
Resultados naturais 2 ou superiores não são erros automáticos por regra geral.
Remova a antiga exceção do bandido que fazia o resultado 2 errar.
Mantenha os dados visuais sincronizados com os resultados efetivamente usados.

2. SISTEMA DE DANO E DEFESA
Fórmula oficial:
Dano Real = max(0, resultado do dado da arma + atributo relevante (FOR ou DES) - Defesa Total do alvo).
Não existe rolagem separada para acertar armadura.
O valor natural 1 causa erro automático e 0 de dano antes de aplicar modificadores.
A Defesa deve ser calculada dinamicamente por fontes separadas: Defesa Natural, equipamentos e efeitos temporários.
Não invente uma Defesa base além dos bônus expressamente definidos; se o projeto já tiver uma regra de Defesa base, identifique-a e informe antes de alterá-la.

BROKK:
- FOR total +3, DES +2, CON +3, 14 PV máximos.
- Espada de Ferro 1d6 físico; dano bruto = dado + FOR (+3).
- Pele de Rocha: +1 Defesa Natural enquanto PV atuais forem maiores que metade dos PV máximos. Com 14 PV, ativa de 8 a 14, inativa de 0 a 7.
- Escudo de Madeira e Ferro: +2 Defesa SOMENTE quando o resultado NATURAL do dado de ataque inimigo for 2 ou 3. O escudo REDUZ dano, não causa erro automático.
- Ação Defender: +2 Defesa temporária até o início do próximo turno do personagem, custo de 1 PA.
- Os bônus aplicáveis se acumulam: por exemplo, com Pele de Rocha, escudo acionado e Defender ativo, a Defesa total é 1 + 2 + 2 = 5, salvo outros bônus explicitamente existentes.
- Dano nunca pode ser negativo.

BANDIDO:
- 8 PV.
- Arma 1d6, bônus de ataque +1.
- Resultado natural 1 erra; 2 a 6 acertam, sujeitos à redução de dano pela Defesa.
- Não inventar novas habilidades defensivas para o bandido.

3. SISTEMA DE PONTOS DE AÇÃO (PA)
Cada personagem começa seu turno com 5 PA, aplicando débitos e penalidades já registrados.
Exemplo: se Brokk utilizou Muralha de Ferro no turno inimigo, começa o próximo turno com 4 PA.
Exibir PA atuais e PA máximos na interface.
Impedir ações com PA insuficientes.
Ações:
- Ataque básico: 3 PA.
- Ataque com Vantagem: custo adicional de 2 PA, total 5 PA.
- Defender: 1 PA, concede +2 Defesa até o início do próximo turno do personagem.
- Mover uma casa: 2 PA.
- Correr duas casas: 3 PA.
- Trocar posição com aliado: 1 PA (preparar para combate com múltiplos aliados; não criar aliado fictício).
- Fugir: 1 PA (não implementar fuga definitiva sem fluxo de encerramento definido).
- Trocar arma ou usar poção: 1 PA cada, apenas se os sistemas existirem.
- Mestre das Armas: 0 PA, um uso por combate, preservando a decisão de repetir o dado e a obrigatoriedade de aceitar o novo resultado.
- Muralha de Ferro: reação, 1 PA descontado do próximo turno, um uso por combate; reduzir dano físico à metade arredondando para baixo. Integrar cuidadosamente com a Defesa para não aplicar reduções duplicadas.

O jogador pode encerrar o turno voluntariamente mesmo com PA restantes. Quando PA forem insuficientes para uma ação, apresentar mensagem clara.
Evitar que ações gratuitas causem loops ou travamentos.

4. MOVIMENTAÇÃO NO TABULEIRO 3x6
Manter as três linhas A, B, C e seis colunas 1 a 6.
Casas: A1–A6, B1–B6, C1–C6.
Colunas 1, 2 e 3 = lado dos heróis.
Colunas 4, 5 e 6 = lado dos inimigos para posicionamento inicial.
Implementar movimento ortogonal (cima, baixo, esquerda, direita) de uma casa por 2 PA, sem movimento diagonal.
Implementar Correr: deslocamento de até duas casas por 3 PA, com caminho ortogonal válido e sem atravessar casas ocupadas.
Não permitir que dois personagens ocupem a mesma casa.
Não permitir sair dos limites do tabuleiro.
Permitir deslocamento pelo tabuleiro inteiro durante o combate, respeitando ocupação e custos.
Oferecer seleção visual de destino, indicação de casas válidas e atualização da posição do personagem.
Se não houver seleção de personagens na cena atual, implementar de modo simples e compatível com os sprites existentes.
A posição visual deve corresponder à posição lógica.
Não alterar o tamanho do tabuleiro.

5. POSICIONAMENTO INICIAL POR INICIATIVA
A iniciativa continua sendo 1d20 + DES e determina a ordem dos turnos.
O mesmo resultado TOTAL determina as opções de posicionamento inicial de Brokk:
- Menor que 10: somente coluna 3 (A3, B3, C3).
- De 10 a 14: colunas 2 ou 3.
- 15 ou mais: qualquer casa disponível das colunas 1, 2 ou 3.
Os inimigos mantêm posições iniciais fixas. Não usar iniciativa inimiga para posicionamento.
A escolha do posicionamento ocorre depois das rolagens de iniciativa e antes da primeira ação de combate.
Não consumir PA para escolher a posição inicial.
Se uma casa estiver ocupada, não permitir selecioná-la.
Manter desempate de iniciativa conforme o sistema existente.

6. INTERFACE
Exibir:
- PV de Brokk e do bandido.
- PA atuais de quem está agindo.
- Estado de Defender e Pele de Rocha.
- Defesa total aplicada e detalhamento dos bônus após ataques.
- Botões ou controles claros para Atacar, Defender, Mover, Correr e Encerrar Turno.
- Indicação de turno e posição atual (ex.: B3).
Preservar os dados 3D e suas animações, sem cobrir os personagens ou o tabuleiro.
Adaptar o layout ao tamanho atual da janela.

7. TESTES E VALIDAÇÃO
Atualizar testes automatizados existentes e adicionar testes para:
- Bandido erra no 1 e acerta no 2.
- Escudo reduz dano com 2 ou 3 e não causa erro automático.
- Pele de Rocha ativa em 8 PV e desativa em 7 PV.
- Defender concede +2 Defesa e expira no início do próximo turno.
- Bônus defensivos acumulam corretamente.
- Dano mínimo 0.
- PA começa em 5 e é consumido corretamente.
- Muralha de Ferro desconta 1 PA no próximo turno.
- Ataque sem PA suficiente é bloqueado.
- Movimento custa 2 PA, corrida custa 3 PA.
- Movimentos inválidos, diagonais, casas ocupadas e saída do tabuleiro são bloqueados.
- Posicionamento inicial obedece às três faixas de iniciativa.
- Mestre das Armas continua funcionando.
- Dados 3D mostram o mesmo resultado usado nas regras.

Execute validação Godot headless se disponível.
Ao terminar, informe:
1. Arquivos alterados.
2. Regras implementadas.
3. Testes executados e resultados.
4. Regras ainda pendentes.
5. Como testar manualmente a cena de combate com F6.

Se alguma regra conflitar com a implementação existente, preserve os dados e o funcionamento do projeto, explique o conflito e implemente apenas a parte segura. Não invente regras ausentes.