# SANTA MINA — ATUALIZAÇÃO DE EQUIPAMENTOS, ALCANCE E COMBATE

Atualize o projeto existente em Godot 4, preservando todas as funcionalidades já implementadas e testadas.

**IMPORTANTE:** Antes de modificar qualquer arquivo, inspecione a arquitetura atual, especialmente:

- `combate.gd`
- `ficha_brokk.gd`
- `estado_combate_brokk.gd`
- `regras_combate.gd`
- `grade_combate.gd`
- `tests/teste_brokk.gd`
- Cena de combate existente.

Não recrie o projeto, não substitua cenas funcionais e não altere o tabuleiro original de 3 linhas por 6 colunas, com casas de 88 pixels.

## 1. NOVOS EQUIPAMENTOS DO COMBATE DE TESTE

### Brokk Pedraférrea — Guerreiro Anão

Substituir a Espada de Ferro atualmente equipada por:

**Machado de Ferro**
- Arma comum, corpo a corpo, uma mão (1H).
- Dano físico: 1d6 + FOR.
- Brokk possui FOR +3.
- Se o dado de ataque apresentar 6 natural, acrescentar +2 ao dano bruto, pois Brokk possui pelo menos 2 de FOR.
- Manter erro automático somente com 1 natural.
- Permitir atacar inimigos em casas imediatamente adjacentes, incluindo diagonais.
- Não permitir ataques contra inimigos fora do alcance.
- O bônus especial de +2 do machado é distinto do sistema geral de crítico. Não implementar ainda novas regras de crítico nesta atualização.

**Escudo de Madeira e Ferro**
- Equipamento de uma mão (1H).
- Concede +2 de Defesa quando o dado natural do ataque inimigo apresentar 2 ou 3.
- O bônus reduz o dano, não provoca erro automático.
- Aplica −1 de Destreza enquanto estiver equipado.
- Não aplicar penalidades de Movimento nesta etapa.
- Manter o bônus racial Pele de Rocha e a ação Defender funcionando normalmente.

**Atributos do Brokk:**
- FOR +3.
- DES base +2.
- DES efetiva +1 com o escudo equipado.
- CON +3.
- INT 0.
- SAB +1.
- CAR +1.
- PV máximos 14.

Utilizar a Destreza efetiva nas rolagens de iniciativa e em outras mecânicas que dependam de DES, sem alterar permanentemente o atributo base.

A iniciativa de Brokk equipado com o escudo passa a ser 1d20 +1.

### Bandido — Arco Curto

Substituir a arma provisória do bandido por:

**Arco Curto**
- Arma comum, de distância, duas mãos (2H).
- Dano físico: 1d6 + atributo de ataque aplicável.
- Preservar o bônus de ataque +1 já utilizado pelo bandido.
- No combate de teste, permitir atingir qualquer casa válida do tabuleiro 3×6, independentemente da distância.
- Se houver um inimigo em casa imediatamente adjacente na horizontal ou vertical ao bandido, seus ataques com Arco Curto recebem Desvantagem.
- Um inimigo apenas na diagonal NÃO provoca essa Desvantagem.
- Erro automático somente com resultado natural 1.

Não criar outros inimigos ou personagens nesta etapa.

## 2. ALCANCE DOS ATAQUES

Implementar um sistema reutilizável de alcance associado ao equipamento.

**Corpo a corpo comum:**
- Permite atacar inimigos nas casas imediatamente adjacentes.
- Inclui horizontal, vertical e diagonal.
- Não permite atacar a própria casa.
- Não permite atacar inimigos fora do alcance.

**Armas de distância:**
- Utilizar o alcance configurado no equipamento.
- O Arco Curto do bandido, neste teste, alcança qualquer casa do tabuleiro.

**Armas com alcance estendido:**
- Preparar a estrutura para armas como Lança de Ferro Grande e Lança de Aço Imperial.
- Não equipar essas armas nem implementar suas habilidades especiais agora.
- Não inventar regras adicionais de alcance para elas.

O alcance deve utilizar as posições lógicas dos personagens no tabuleiro e atualizar automaticamente quando eles se movimentarem.

Se o alvo estiver fora do alcance, bloquear o ataque, informar o motivo e não consumir PA.

## 3. VANTAGEM E DESVANTAGEM

Preservar o sistema existente de Vantagem:

- Rolar dois dados do mesmo tipo.
- Utilizar o maior resultado.
- Manter os dados visuais sincronizados com o resultado aplicado.

Implementar Desvantagem:

- Rolar dois dados do mesmo tipo.
- Utilizar o menor resultado.
- O valor selecionado determina erro natural, dano e efeitos especiais da arma.
- Apresentar visualmente os dois resultados e indicar qual foi utilizado.

Para o Arco Curto do bandido:

- Verificar a posição de Brokk no momento do ataque.
- Se Brokk estiver adjacente horizontal ou verticalmente, aplicar Desvantagem.
- Se estiver apenas na diagonal, atacar normalmente.
- Se estiver distante, atacar normalmente.

Não inventar novas regras de combinação entre Vantagem e Desvantagem. Se ambas ocorrerem simultaneamente e não existir uma regra no projeto, sinalizar a pendência sem introduzir um comportamento arbitrário.

## 4. DANO E DEFESA

Preservar a fórmula:

Dano Real = máximo(0, Dano Bruto − Defesa Total).

Dano Bruto = resultado do dado + atributo relevante + bônus aplicáveis da arma.

Regras:
- Resultado natural 1 no dado utilizado provoca erro automático.
- O escudo do Brokk concede +2 de Defesa quando o resultado natural utilizado pelo inimigo é 2 ou 3.
- Pele de Rocha concede +1 Defesa Natural enquanto Brokk tiver mais da metade dos PV máximos.
- Defender concede +2 Defesa temporária conforme a regra existente.
- Muralha de Ferro reduz pela metade, arredondando para baixo, o dano físico restante após a Defesa.
- Dano mínimo é zero.

Não alterar o funcionamento já validado de Mestre das Armas e Muralha de Ferro.

## 5. PONTOS DE AÇÃO E MOVIMENTAÇÃO

Preservar integralmente:

- 5 PA por turno.
- Ataque básico: 3 PA.
- Ataque com Vantagem: 5 PA no total.
- Defender: 1 PA.
- Mover uma casa: 2 PA.
- Correr duas casas: 3 PA.
- Encerramento voluntário de turno.
- Desconto de PA pendente da Muralha de Ferro.
- Posicionamento inicial conforme a iniciativa.
- Movimentação ortogonal e bloqueio de casas ocupadas.

**Não implementar nenhum bônus ou penalidade de Movimento proveniente de equipamentos nesta etapa.**

A penalidade de −1 DES do escudo não modifica PA nem quantidade de casas percorridas.

## 6. INTERFACE

Atualizar as informações exibidas:

**Brokk**
- Nome, classe e raça.
- Machado de Ferro e Escudo de Madeira e Ferro.
- FOR +3.
- DES base +2 e DES efetiva +1.
- PV e PA atuais.
- Bônus de Defesa ativos.
- Habilidades disponíveis ou utilizadas.

**Bandido**
- Arco Curto equipado.
- PV e informações relevantes.
- Indicação visual quando estiver atacando com Desvantagem.

Durante o combate:
- Mostrar quando o ataque estiver fora do alcance.
- Mostrar o bônus especial do Machado de Ferro quando sair 6 natural.
- Mostrar os resultados dos dois dados na Desvantagem.
- Preservar as animações 3D, os sprites, a legibilidade da interface e o tabuleiro 3×6.

## 7. TESTES AUTOMATIZADOS

Atualizar os testes existentes e adicionar verificações para:

1. Brokk utiliza Machado de Ferro em vez de Espada de Ferro.
2. Resultado natural 6 do Machado de Ferro acrescenta +2 ao dano bruto.
3. O bônus do machado não é ativado com outros resultados.
4. Ataques físicos erram somente no 1 natural.
5. Ataques corpo a corpo atingem casas adjacentes horizontais, verticais e diagonais.
6. Ataques corpo a corpo fora do alcance são bloqueados sem gastar PA.
7. Arco Curto atinge qualquer casa válida do tabuleiro de teste.
8. Arco Curto recebe Desvantagem com inimigo adjacente horizontal ou verticalmente.
9. Arco Curto não recebe Desvantagem por inimigo apenas na diagonal.
10. Desvantagem utiliza o menor resultado de dois dados.
11. O resultado visual corresponde ao valor utilizado na mecânica.
12. Escudo reduz a DES efetiva de Brokk de +2 para +1.
13. Iniciativa utiliza a DES efetiva.
14. Escudo mantém +2 de Defesa contra resultados naturais 2 ou 3.
15. Pele de Rocha, Defender e Muralha de Ferro continuam funcionando.
16. PA, movimento, corrida e posicionamento inicial permanecem corretos.
17. Nenhuma penalidade de Movimento é aplicada por equipamentos.

## 8. VALIDAÇÃO FINAL

Execute os testes automatizados e a validação do Godot em modo headless, se disponível.

Ao concluir, apresente:

- Arquivos modificados e adicionados.
- Regras implementadas.
- Quantidade de testes executados e falhas encontradas.
- Funcionalidades preservadas.
- Pendências de implementação.
- Instruções simples para testar a cena de combate com F6.

**Prioridade absoluta:** preservar a versão estável do Santa Mina. Não reestruture sistemas que já funcionam sem necessidade. Caso encontre ambiguidades, não invente regras; implemente somente o que estiver definido e informe as pendências.