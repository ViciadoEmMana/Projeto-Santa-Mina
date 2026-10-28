# SANTA MINA — MODERNIZAÇÃO DA INTERFACE DE COMBATE

Atualize o projeto existente em Godot 4, preservando integralmente o sistema de combate já funcional.

## CONTEXTO

O jogo Santa Mina possui atualmente:
- Tabuleiro 3×6, com casas de 88 pixels.
- Brokk Pedraférrea, anão guerreiro com 14 PV, Machado de Ferro e Escudo de Madeira e Ferro.
- Bandido Arqueiro com 6 PV e Arco Curto.
- Bandido do Porrete com 8 PV.
- Três iniciativas e turnos independentes.
- Sistema de 5 Pontos de Ação por turno.
- Movimentação, corrida, ataques, Defesa e habilidades.
- Vantagem e Desvantagem, inclusive anulação simultânea.
- Condição Derrubado e imunidade racial do Brokk.
- Efeitos visuais e oito arquivos WAV para armas e bloqueios.
- Dados 3D animados e sincronizados com os cálculos.
- Seleção de alvos por clique.
- Vitória após derrotar ambos os bandidos.

A última validação relatada pelo Codex teve 857 verificações automatizadas e zero falhas. O usuário também confirmou que os efeitos funcionaram ao testar o jogo.

**Objetivo:** melhorar exclusivamente a interface visual e a experiência de uso do combate, sem modificar regras ou cálculos.

## 1. INSPEÇÃO INICIAL

Antes de editar:

1. Inspecione a cena `Combate.tscn` e os scripts associados.
2. Identifique os nós de interface já existentes e os sinais utilizados.
3. Examine como o estado de Brokk e dos dois bandidos é atualizado.
4. Identifique como os dados 3D e as mensagens de combate são exibidos.
5. Reutilize a arquitetura atual sempre que possível.

Não recrie a cena do zero. Não remova recursos ou controles que já funcionam.

## 2. IDENTIDADE VISUAL

Adotar estilo medieval de RPG:

- Painéis em tons de madeira escura, couro e pergaminho.
- Bordas discretas em ferro ou bronze.
- Textos claros, legíveis e com bom contraste.
- Destaques dourados para personagem ativo e ações importantes.
- Vermelho para PV.
- Dourado ou âmbar para PA.
- Ícones simples para ataques, movimento, Defesa e habilidades.

Preferir estilos, temas, fontes já disponíveis e componentes nativos do Godot.

Não baixar recursos externos sem necessidade.

Não criar texturas grandes que prejudiquem o desempenho.

## 3. PAINÉIS DOS PERSONAGENS

Criar ou aprimorar painéis para os três participantes:

**Brokk Pedraférrea**
- Nome.
- PV atual/máximo: 14 inicialmente.
- Barra visual de PV.
- PA disponíveis.
- Arma equipada: Machado de Ferro.
- Escudo equipado.
- Condições ativas.

**Bandido Arqueiro**
- Nome.
- PV atual/máximo: 6 inicialmente.
- Barra visual de PV.
- PA disponíveis.
- Arma: Arco Curto.
- Condições ativas.

**Bandido do Porrete**
- Nome.
- PV atual/máximo: 8 inicialmente.
- Barra visual de PV.
- PA disponíveis.
- Arma: Porrete.
- Condições ativas.

Os valores devem vir diretamente dos estados reais dos personagens.

Não manter números fictícios ou fixos na interface.

Atualizar os painéis após dano, cura, gasto de PA, início de turno, aplicação de condições e derrota.

Personagens derrotados devem permanecer identificáveis, mas visualmente desativados.

## 4. ORDEM DE INICIATIVA E TURNO ATIVO

Exibir a ordem real dos três participantes.

- Destacar claramente o personagem ativo.
- Mostrar quem será o próximo.
- Exibir o número da rodada, utilizando a contagem real do sistema.
- Atualizar quando houver derrota ou mudança na ordem.
- Não alterar o cálculo da iniciativa.

Evitar confusão entre turno do jogador e turno dos inimigos.

## 5. BARRAS DE VIDA E PA

Criar barras ou indicadores compactos e legíveis.

**PV**
- Mostrar valor atual e máximo.
- Atualização imediata após cada ataque.
- Não ultrapassar os limites de 0 e PV máximo.
- Animação curta e discreta de redução, se viável.

**PA**
- Mostrar valor atual e máximo.
- Atualizar após movimentação, corrida, ataque, Defesa e habilidades.
- Refletir penalidades e débitos já previstos nas regras.
- Não presumir que todos sempre terão 5 PA disponíveis.

As animações visuais não devem atrasar o cálculo do combate nem interferir na lógica.

## 6. PAINEL DE AÇÕES

Organizar os comandos existentes em uma área clara e compacta.

Exibir os controles realmente disponíveis no projeto, incluindo, quando existentes:
- Atacar.
- Ataque com Vantagem.
- Mover.
- Correr.
- Defender.
- Mestre das Armas.
- Muralha de Ferro.
- Encerrar turno.

Mostrar os custos reais de PA.

Exemplos:
- Ataque básico: 3 PA.
- Ataque com Vantagem: 5 PA.
- Movimento: 2 PA.
- Corrida: 3 PA.
- Defender: 1 PA.

Não criar botões que aparentem funcionar, mas não tenham implementação.

Não implementar ações novas apenas para preencher a interface.

Quando uma ação estiver indisponível, mostrar estado visual desativado e, se possível, uma explicação breve.

Preservar a regra de que um ataque comprado com Vantagem custa 5 PA mesmo quando a Vantagem é anulada por Desvantagem.

## 7. SELEÇÃO DE ALVO E ALCANCE

Ao selecionar um inimigo:
- Destacar sua casa ou personagem.
- Mostrar claramente qual alvo está selecionado.
- Se a ação escolhida for um ataque, indicar se o alvo está no alcance.
- Preservar as regras existentes de alcance e ocupação.
- Preservar a seleção por clique.
- Não permitir selecionar personagens derrotados como alvos válidos.

Não alterar as regras de movimentação ou ataque.

Não mostrar uma casa como alcançável quando as regras impedirem o ataque.

## 8. CONDIÇÕES E EFEITOS ATIVOS

Exibir indicadores discretos para condições existentes.

Inicialmente:
- Derrubado.
- Defender, quando o bônus temporário estiver ativo.
- Outros efeitos que já estejam implementados e tenham estado verificável.

Não mostrar condições que ainda não existem no sistema.

A duração dos indicadores deve corresponder exatamente à duração real dos efeitos.

Preservar a regra provisória atual de Derrubado: a condição termina após descontar 1 PA no início do próximo turno.

Não implementar novas condições.

## 9. REGISTRO DE COMBATE

Criar ou melhorar um painel de mensagens contendo eventos recentes:

- Início de turno.
- Resultado de ataques.
- Dano causado.
- Bloqueio de escudo.
- Ativação de habilidades.
- Aplicação ou resistência a condições.
- Derrota de personagens.
- Vitória ou derrota final.

Preservar as mensagens úteis que já existem.

O registro deve:
- Exibir mensagens em ordem cronológica.
- Permitir leitura sem ocupar grande parte da tela.
- Limitar a quantidade de mensagens mantidas, para evitar consumo desnecessário de memória.
- Não duplicar eventos.

Se já existir um registro funcional, aprimorá-lo em vez de substituí-lo desnecessariamente.

## 10. ORGANIZAÇÃO DA TELA

Preservar:
- Tabuleiro original 3×6.
- Sprites e posições lógicas.
- Escudo e porrete visíveis.
- Dados 3D.
- Efeitos de corte, pancada, flecha e bloqueio.
- Áudio de combate.

Organizar a interface de modo que:
- O tabuleiro continue sendo o elemento central.
- Painéis não cubram casas nem personagens.
- Botões permaneçam acessíveis.
- Dados 3D continuem visíveis.
- A interface funcione na resolução atual do projeto.

Caso seja necessário ajustar o tamanho da janela ou a distribuição visual, priorizar a preservação das proporções do tabuleiro e dos elementos existentes.

Não alterar a dimensão lógica das casas.

## 11. ARQUITETURA E DESEMPENHO

Preferir componentes nativos do Godot, como:
- Control.
- PanelContainer.
- HBoxContainer.
- VBoxContainer.
- GridContainer.
- ProgressBar.
- TextureProgressBar, quando adequado.
- Label.
- Button.
- Theme e StyleBoxFlat.

Se a interface estiver excessivamente concentrada em `combate.gd`, avaliar extrair componentes visuais para um script reutilizável, sem refatorações desnecessárias.

Atualizar a interface por eventos ou mudanças de estado sempre que possível.

Evitar recriar todos os elementos visuais a cada frame.

Não adicionar dependências externas.

Priorizar desempenho adequado para computadores modestos.

## 12. REGRAS QUE NÃO PODEM SER MODIFICADAS

Preservar integralmente:
- Iniciativa e desempate.
- Posicionamento inicial.
- Turnos independentes.
- Custos de PA.
- Movimento e corrida.
- Ataque e Defesa.
- Erro automático no 1 natural.
- Vantagem e Desvantagem.
- Escudo condicional no 2 ou 3.
- Pele de Rocha.
- Firmeza de Rocha.
- Machado de Ferro.
- Porrete e Derrubado.
- Arco Curto.
- Mestre das Armas.
- Muralha de Ferro.
- Lanças grandes cadastradas.
- Todos os efeitos audiovisuais.
- Condições e suas durações atuais.
- Vitória após derrotar ambos os inimigos.

Não implementar sistema de críticos.

Não alterar atributos, equipamentos ou dano dos personagens.

## 13. TESTES AUTOMATIZADOS

Preservar todos os testes anteriores e adicionar verificações para:

1. Painéis exibem PV reais dos três personagens.
2. Barras de PV atualizam após dano.
3. PA exibidos correspondem ao estado real.
4. Indicador de turno ativo acompanha a iniciativa.
5. Ordem de iniciativa exibida corresponde à lógica.
6. Seleção visual corresponde ao alvo realmente selecionado.
7. Alvos derrotados não podem ser atacados.
8. Botões refletem disponibilidade real das ações.
9. Custos de PA exibidos estão corretos.
10. Condição Derrubado aparece e desaparece no momento correto.
11. Registro de combate recebe eventos sem duplicação indevida.
12. Interface não altera cálculos de dano ou Defesa.
13. Interface não interfere na movimentação.
14. Efeitos audiovisuais continuam funcionando.
15. Todos os testes anteriores permanecem aprovados.

Executar os testes headless disponíveis.

Se possível, abrir a cena principal e verificar a ausência de erros de carregamento.

## 14. ENTREGA

Ao concluir, apresentar:

- Resumo das melhorias visuais.
- Arquivos criados e modificados.
- Quantidade de testes executados e falhas.
- Eventuais limitações.
- Roteiro de testes manuais usando F6.

Se possível, gerar uma captura de tela da nova interface para inspeção visual.

**Prioridade máxima:** melhorar a experiência visual e a clareza dos controles, mantendo o combate estável e funcional.