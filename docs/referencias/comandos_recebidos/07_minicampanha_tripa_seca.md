# SANTA MINA — MINICAMPANHA “O COVIL DE TRIPA SECA”

## MISSÃO PRINCIPAL

Implementar uma minicampanha jogável no projeto Godot 4 existente, preservando o combate atual, os personagens, as animações, os efeitos sonoros, a interface e as regras já aprovadas.

A campanha será protagonizada por **Brokk Pedraférrea**, um Anão Guerreiro, e terá quatro capítulos, culminando em um confronto contra o chefe goblin Tripa Seca.

**IMPORTANTE:**
- Não recriar o projeto.
- Não substituir a cena de combate atual.
- Não alterar regras existentes sem necessidade.
- Antes de editar, examinar a arquitetura e os testes.
- Implementar em módulos reutilizáveis.
- Manter uma forma de acessar o combate original para testes e regressão.
- Não implementar o sistema de críticos.
- Não criar regras permanentes para mecânicas ainda indefinidas.

A última validação relatada foi de 906 verificações automatizadas, sem falhas.

---

# 1. REGRAS GERAIS DOS PONTOS DE AÇÃO

Atualizar a arquitetura para permitir diferentes quantidades de PA por criatura.

**Brokk Pedraférrea**
- 5 PA por turno.

**Inimigos comuns**
- Normalmente 3 PA por turno.

**Chefes e minibosses**
- Podem possuir mais PA, conforme a ficha.

**Tripa Seca**
- 4 PA por turno.

Os bandidos existentes passam a utilizar 3 PA por turno, conforme a nova regra geral para inimigos comuns.

Preservar os custos atuais:
- Ataque básico: 3 PA.
- Ataque com Vantagem comprada: 5 PA.
- Movimento de uma casa: 2 PA.
- Corrida de até duas casas: 3 PA.
- Defender: 1 PA.

Uma criatura comum com 3 PA deve poder realizar um ataque básico ou uma corrida, respeitando os demais requisitos.

Não conceder ataques gratuitos automaticamente.

Preparar suporte para habilidades específicas que concedem movimentação gratuita.

O sistema deve consultar os PA máximos de cada personagem, e não assumir que todos possuem 5 PA.

Atualizar os indicadores da interface para refletir os valores reais.

---

# 2. BESTIÁRIO — NOVOS GOBLINS

Criar fichas reutilizáveis para os seguintes inimigos.

## 2.1 Goblin do Porrete

- Tipo: Humanoide.
- Nível: 2.
- PV: 6.
- Defesa: 0.
- FOR: +1.
- DES: +1.
- PA: 3.
- Arma: Clava.
- Dano: 1d6.
- Ataque corpo a corpo.
- Alcance: uma casa, incluindo diagonais.
- Drop: Porrete desgastado e 2 coroas.

Não atribuir automaticamente o efeito Derrubado da Maça de Ferro à Clava, pois esse efeito não consta da ficha do Goblin do Porrete.

## 2.2 Goblin Sucata

- Tipo: Humanoide.
- Nível: 2.
- PV: 6.
- Defesa: 2.
- FOR: +2.
- PA: 3.
- Arma: Gancho.
- Dano: 1d4.
- Ataque corpo a corpo.
- Alcance: uma casa, incluindo diagonais.
- Drop: Tampa de Ferro e 2 coroas.

A Defesa 2 já faz parte da ficha do inimigo. Não somar outra Defesa por causa da tampa sem regra adicional.

A DES não foi informada. Registrar esse campo como pendente e, somente se necessário para executar o protótipo, utilizar provisoriamente DES 0, documentando a decisão.

## 2.3 Goblin Tiro Certo

- Tipo: Humanoide.
- Nível: 2.
- PV: 5.
- Defesa: 0.
- DES: +2.
- PA: 3.
- Arma: Arco Podre.
- Dano: 1d6 − 1.
- Ataque à distância.
- Drop: Arco Desgastado e 2 coroas.

A FOR não foi informada. Se o sistema exigir esse atributo, utilizar provisoriamente FOR 0 e documentar.

Para o Arco Podre, reutilizar provisoriamente as regras gerais de alcance e proximidade dos arcos já existentes, sem modificar o Arco Curto original.

## 2.4 Goblin Faca Cega

- Tipo: Humanoide.
- Nível: 2.
- PV: 6.
- Defesa: 0.
- DES: +2.
- PA: 3.
- Arma: Duas Facas Cegas.
- Dano: 2d4.
- Ataque corpo a corpo.
- Alcance: uma casa, incluindo diagonais.
- Drop: Facas Cegas e 2 coroas.

**Habilidade especial — Passo Ágil**
- Pode mover uma casa gratuitamente uma vez por rodada.
- Não consome PA.
- Movimento ortogonal, como na regra geral.
- Não atravessa obstáculos nem personagens.
- Não pode terminar em casa ocupada.
- Reinicia sua disponibilidade a cada nova rodada.
- Não concede ataque gratuito.

A FOR não foi informada. Se necessária, utilizar provisoriamente FOR 0.

Preservar a rolagem de dois dados de dano para a arma 2d4. Não transformar automaticamente esse ataque em dois ataques separados.

---

# 3. CHEFE — GOBLIN LÍDER TRIPA SECA

Criar o chefe com as seguintes características:

- Nome: Tripa Seca.
- Tipo: Humanoide.
- Nível: 4.
- Categoria: Chefe.
- PV: 13.
- Defesa: 2.
- FOR: +2.
- DES: +2.
- PA: 4.
- Arma: Espada Curta.
- Dano: 1d6.
- Ataque corpo a corpo.
- Alcance: uma casa, incluindo diagonais.

**Drop do chefe:**
- 7 coroas.
- Escudo de Madeira e Ferro.

## 3.1 Mestre das Armadilhas

A ficha do chefe prevê:
- Ativação de armadilha.
- Golpe sujo.
- Jogar terra nos olhos do alvo.

Essas habilidades ainda não possuem custos, duração, testes de resistência ou efeitos numéricos definidos.

Criar a estrutura de dados e os identificadores das habilidades, mas não inventar seus efeitos definitivos.

Para esta primeira versão, elas podem aparecer na apresentação do chefe como habilidades futuras, sem interferir nos cálculos do combate.

## 3.2 Me Protejam!

A ficha prevê que Tripa Seca possa utilizar um goblin aliado próximo como escudo para absorver um ataque de dano alto, inclusive sacrificando esse aliado.

Ainda não foram definidos:
- O que constitui dano alto.
- A distância exata de um aliado próximo.
- O custo de PA.
- O limite de utilizações.
- Como o dano é transferido.

Preparar a estrutura reutilizável dessa habilidade, mas mantê-la desativada até a definição oficial desses parâmetros.

Não inventar valores definitivos.

## 3.3 Comportamento do chefe

Implementar uma IA básica e funcional:
- Aproximar-se quando necessário.
- Atacar Brokk quando estiver ao alcance e possuir PA.
- Respeitar ocupação e obstáculos.
- Não atravessar personagens.
- Encerrar o turno quando não houver ação válida.

Não implementar comportamentos complexos dependentes das habilidades ainda indefinidas.

---

# 4. MINICAMPANHA — HISTÓRIA E PROGRESSÃO

Título:

**SANTA MINA: O COVIL DE TRIPA SECA**

Criar uma sequência de quatro capítulos, com introduções narrativas, combates e transições.

Utilizar textos curtos, em português brasileiro, com atmosfera medieval e humor discreto.

## CAPÍTULO I — O CARREGAMENTO DESAPARECIDO

Enredo:

Uma carroça que transportava mantimentos para Santa Mina desapareceu na estrada. Brokk é enviado para investigar e encontra dois bandidos saqueando os restos da carga.

Inimigos:
- Bandido Arqueiro: 6 PV, 3 PA.
- Bandido do Porrete: 8 PV, 3 PA.

Após a vitória, Brokk descobre que os bandidos trabalhavam para um líder goblin conhecido como Tripa Seca.

Exibir uma breve transição narrativa.

## CAPÍTULO II — RASTROS NA MATA

Enredo:

Seguindo pegadas e marcas de carroça, Brokk encontra um acampamento improvisado onde goblins desmontam os suprimentos roubados.

Inimigos:
- Goblin do Porrete.
- Goblin Sucata.

Após a vitória, Brokk encontra um mapa rudimentar que aponta para uma entrada escondida nas rochas.

## CAPÍTULO III — A PASSAGEM DOS COVARDES

Enredo:

Na entrada da caverna, dois goblins vigiam a passagem. Um utiliza flechas, enquanto o outro avança com duas facas enferrujadas.

Inimigos:
- Goblin Tiro Certo.
- Goblin Faca Cega.

O combate deve permitir testar a movimentação gratuita do Goblin Faca Cega.

Após a vitória, Brokk encontra a passagem para o covil do chefe.

## CAPÍTULO IV — O COVIL DE TRIPA SECA

Enredo:

Brokk encontra o líder goblin sentado sobre caixas roubadas, cercado pelos seus capangas.

Diálogo sugerido:

Tripa Seca:
"Quem deixou esse anão entrar aqui? Eu mandei vigiar a entrada!"

Brokk:
"Vim buscar os mantimentos de Santa Mina. E acho que vou levar sua espada também."

Tripa Seca:
"Me protejam, seus imprestáveis!"

Inimigos:
- Tripa Seca: 13 PV, 4 PA.
- Goblin do Porrete: 6 PV, 3 PA.
- Goblin Sucata: 6 PV, 3 PA.

A batalha termina somente quando todos os inimigos forem derrotados.

Após a vitória, apresentar o encerramento narrativo e as recompensas.

---

# 5. SISTEMA DE CAMPANHA

Criar um gerenciador reutilizável de campanha.

Deve controlar:
- Capítulo atual.
- Inimigos do capítulo.
- Estado de vitória e derrota.
- Transições narrativas.
- Inventário do jogador.
- Coroas.
- Recompensas recebidas.
- PV atuais de Brokk.
- Habilidades gastas.
- Efeitos alimentares ativos.
- Condições e suas durações.

**Os PV de Brokk não devem ser restaurados automaticamente entre os capítulos.**

Habilidades gastas também não devem ser restauradas automaticamente.

Recuperação deve ocorrer exclusivamente por efeitos previstos nas regras, como descansos ou consumíveis.

A campanha deve possuir uma opção de reiniciar desde o primeiro capítulo.

Manter acesso separado ao combate original para testes.

---

# 6. INVENTÁRIO E MANTIMENTOS

Criar um inventário simples, reutilizável e funcional.

Registrar:
- Comidas e bebidas.
- Quantidade de cada consumível.
- Equipamentos obtidos.
- Coroas.
- Recompensas especiais.

Não implementar loja completa nesta atualização.

Não inventar preços.

Não permitir quantidades negativas.

O inventário deve persistir entre os capítulos da mesma campanha.

**Regra oficial: qualquer comida ou bebida pode ser consumida para pagar o custo de um Descanso Curto ou Longo.**

O consumo remove exatamente uma unidade do inventário.

Além dos benefícios do descanso, o personagem recebe o efeito próprio do alimento ou bebida consumido.

Não permitir consumo de alimentos ou bebidas durante o combate.

---

# 7. CARDÁPIO DA TAVERNA

Cadastrar os seguintes itens como dados reutilizáveis.

| Item | Efeito |
|---|---|
| Pão de Queijo | +2 PV temporários |
| Caldo de Ovo | Vantagem contra doenças e +1 PV |
| Cuscuz com Manteiga | +1 movimento por 3 rodadas |
| Café | +1 iniciativa por 3 rodadas |
| Rabada | +1 dano com armas por 3 rodadas |
| Moqueca | +1 dano com magias por 3 rodadas |
| Galinhada | Efeito ainda não definido |
| Cerveja | +1 FOR por 3 rodadas |
| Doce | +1 DES por 1 rodada |
| Costela de Porco | +3 PV temporários por 3 rodadas |
| Salada de Frutas | +1 DES por 3 rodadas |
| Acarajé | +1 SAB por 3 rodadas |
| Vinho | +1 INT por 3 rodadas |
| Campari | +1 CAR por 3 rodadas |

Regras:
- Todos são consumíveis fora de combate.
- Todos podem pagar o custo de um descanso.
- Os efeitos não devem ser confundidos com habilidades de classe.
- Os PV temporários são separados dos PV normais.
- A vida normal não ultrapassa os PV máximos.
- Não criar efeitos para a Galinhada.
- Não inventar preços ou valores de venda.
- Não implementar efeitos de doenças se o sistema de doenças ainda não existir; preparar a informação para uso futuro.

**Duração:** como ainda não foi estabelecido oficialmente se as rodadas de exploração e combate compartilham a mesma contagem, criar uma estrutura de duração desacoplada e configurável. Evitar decisões irreversíveis sobre esse ponto.

Não permitir acumulação ilimitada de bônus pela repetição do mesmo alimento. Se for necessário definir uma política provisória, renovar a duração do mesmo efeito em vez de somar infinitamente o bônus, documentando a escolha.

---

# 8. MECÂNICA DE DESCANSO

Implementar Descanso Curto e Descanso Longo como ações fora de combate.

## 8.1 Descanso Curto

Requisitos:
- Estar fora de combate.
- Estar ao final de um turno de movimentação pelo mapa.
- Possuir pelo menos uma comida ou bebida.

Custo:
- Exatamente 1 unidade de comida ou bebida escolhida.

Benefício:
- Recuperar o uso de exatamente uma habilidade de classe já gasta, escolhida pelo jogador.
- Não recuperar PV diretamente pelo descanso.
- Aplicar também o efeito do alimento consumido.

Se nenhuma habilidade estiver gasta, não permitir executar um Descanso Curto sem benefício de recuperação, salvo futura regra específica.

## 8.2 Descanso Longo

Requisitos:
- Estar fora de combate.
- Estar ao final de um turno.
- Estar em Cidade, Vila ou Acampamento Protegido.
- Possuir pelo menos uma comida ou bebida.

**Descanso Longo é proibido dentro de masmorras.**

Custo:
- Exatamente 1 unidade de comida ou bebida escolhida.

Benefícios:
- Recuperar todas as habilidades de classe gastas.
- Recuperar PV equivalentes à metade dos PV máximos + modificador de CON.
- Aplicar também o efeito do alimento consumido.

A recuperação não pode ultrapassar os PV máximos normais.

## 8.3 Exemplo de Brokk

- PV máximos: 14.
- CON: +3.
- Metade de 14: 7.
- Recuperação do Descanso Longo: 7 + 3 = 10 PV.

Se Brokk estiver com 4/14 PV, recuperará até 14/14 PV com o Descanso Longo.

Se consumir Costela de Porco, também receberá +3 PV temporários, conforme a duração prevista para o alimento.

Preservar o controle de usos das habilidades Mestre das Armas e Muralha de Ferro.

## 8.4 Limitação da exploração atual

Se ainda não existir um sistema completo de exploração por turnos, criar uma tela ou etapa simples de exploração entre capítulos, com estados de localização claramente identificados.

Não simular um Descanso Longo dentro da dungeon.

Não permitir descansar livremente após cada combate sem cumprir os requisitos.

Criar uma estrutura que possa ser integrada posteriormente ao mapa de exploração definitivo.

---

# 9. LOCAIS DA CAMPANHA

Criar estados de localização para controlar descansos:

- Estrada: exploração.
- Acampamento Protegido: local seguro.
- Floresta: exploração.
- Entrada da Caverna: exploração.
- Interior da Dungeon: masmorra.
- Covil de Tripa Seca: masmorra.

Na progressão da campanha, permitir ao jogador utilizar um Acampamento Protegido após o primeiro capítulo, antes de seguir para os confrontos seguintes.

Dentro da dungeon, proibir Descanso Longo.

A exploração poderá ser representada inicialmente por uma interface simples com narrativa e escolhas, sem necessidade de criar um mapa aberto completo.

---

# 10. RECOMPENSAS E DROPS

Registrar os drops individuais:

**Goblin do Porrete**
- Porrete Desgastado.
- 2 coroas.

**Goblin Sucata**
- Tampa de Ferro.
- 2 coroas.

**Goblin Tiro Certo**
- Arco Desgastado.
- 2 coroas.

**Goblin Faca Cega**
- Facas Cegas.
- 2 coroas.

**Tripa Seca**
- Escudo de Madeira e Ferro.
- 7 coroas.

Recompensa final da dungeon:
- Espada de Ferro.
- Arco Curto.
- 1 Porção Comum.

A Porção Comum deve ser cadastrada como recompensa, mas não inventar efeitos ainda não definidos.

Garantir que recompensas não sejam concedidas repetidamente pela mesma vitória.

Os equipamentos obtidos devem entrar no inventário. Não equipá-los automaticamente em Brokk.

---

# 11. INTERFACE DA CAMPANHA

Preservar a interface medieval atual.

Adicionar, de maneira organizada:
- Título do capítulo.
- Texto narrativo.
- Botão para iniciar o confronto.
- Indicador de progresso da campanha.
- Inventário de mantimentos.
- Coroas disponíveis.
- PV atuais de Brokk.
- Habilidades disponíveis ou gastas.
- Acesso ao descanso quando permitido.
- Tela de vitória de capítulo.
- Tela de derrota.
- Tela de vitória final.

Evitar sobrecarregar a tela de combate com informações de exploração.

Utilizar os mesmos padrões visuais:
- Madeira escura.
- Bordas bronze.
- Destaques dourados.
- Barras de PV vermelhas.
- Indicadores de PA âmbar.

Preservar os dados 3D, sprites, sons, efeitos e animações existentes.

---

# 12. ARQUITETURA RECOMENDADA

Avaliar a criação de scripts separados para:
- Gerenciador da campanha.
- Catálogo de criaturas.
- Catálogo de consumíveis.
- Inventário.
- Sistema de descanso.
- Progressão de capítulos.
- Recompensas.
- Interface de exploração.

Reutilizar `estado_inimigo.gd`, `condicoes_combate.gd`, `equipamentos_combate.gd`, `regras_combate.gd`, `interface_combate.gd` e `efeitos_combate.gd` sempre que possível.

Evitar concentrar toda a nova lógica em `combate.gd`.

Não fazer uma refatoração geral desnecessária.

---

# 13. TESTES AUTOMATIZADOS

Preservar os 906 testes anteriormente aprovados e adicionar verificações para:

## Pontos de Ação
1. Brokk mantém 5 PA.
2. Bandidos comuns possuem 3 PA.
3. Goblins comuns possuem 3 PA.
4. Tripa Seca possui 4 PA.
5. PA de cada personagem são independentes.
6. IA não realiza ações sem PA suficientes.

## Goblins
7. Cada goblin possui os PV corretos.
8. Defesa e atributos correspondem às fichas.
9. Armas utilizam os dados corretos.
10. Goblin Faca Cega move uma casa gratuitamente uma vez por rodada.
11. Movimento gratuito respeita ocupação e obstáculos.
12. O ataque 2d4 funciona corretamente.

## Campanha
13. Os capítulos seguem a ordem correta.
14. Cada capítulo carrega os inimigos correspondentes.
15. A vitória exige derrotar todos os inimigos da batalha.
16. PV de Brokk persistem entre os capítulos.
17. Habilidades gastas persistem até recuperação válida.
18. A derrota interrompe o progresso.
19. Reiniciar a campanha restaura o estado inicial.

## Inventário e Descanso
20. Consumir comida reduz o inventário em uma unidade.
21. Qualquer comida ou bebida pode pagar um descanso.
22. Descanso Curto recupera exatamente uma habilidade gasta.
23. Descanso Curto não cura PV diretamente.
24. Descanso Longo recupera todas as habilidades.
25. Descanso Longo recupera metade dos PV máximos + CON.
26. A recuperação respeita o limite de PV.
27. Descanso Longo é bloqueado dentro de masmorras.
28. Descanso Longo é permitido em local seguro válido.
29. Consumo de alimentos é bloqueado durante combate.
30. Efeitos alimentares são aplicados sem alterar indevidamente as regras.

## Recompensas
31. Drops correspondem às criaturas derrotadas.
32. Coroas são adicionadas corretamente.
33. Equipamentos entram no inventário.
34. Recompensas não são duplicadas.
35. Recompensa final é concedida uma única vez.

## Regressão
36. Interface de combate continua funcionando.
37. Dados 3D continuam sincronizados.
38. Efeitos sonoros e visuais permanecem funcionais.
39. Vantagem e Desvantagem continuam corretas.
40. Defesa e habilidades de Brokk continuam corretas.
41. O combate original permanece acessível.
42. Todos os testes anteriores continuam aprovados.

Executar validação headless e, se possível, captura real das novas telas.

---

# 14. PLANO DE IMPLEMENTAÇÃO

Como esta atualização é maior que as anteriores, trabalhar por etapas, verificando o projeto após cada uma:

**Etapa 1 — Estrutura**
- Catálogo de criaturas.
- PA individuais.
- Fichas dos goblins e Tripa Seca.
- Testes.

**Etapa 2 — Campanha**
- Gerenciador de capítulos.
- Transições.
- Combates.
- Persistência de PV e habilidades.
- Testes.

**Etapa 3 — Recursos**
- Inventário.
- Comidas e bebidas.
- Descansos.
- Drops.
- Testes.

**Etapa 4 — Apresentação**
- Telas narrativas.
- Interface de exploração.
- Recompensas.
- Vitória e derrota.
- Testes finais.

Se a execução completa não couber em uma única sessão, concluir uma etapa estável, informar o que foi implementado e o que permanece pendente. Não apresentar funcionalidades incompletas como concluídas.

---

# 15. ENTREGA FINAL

Ao concluir, informar:

1. Resumo das funcionalidades implementadas.
2. Arquivos criados e modificados.
3. Total de verificações e falhas.
4. Funcionalidades provisórias ou pendentes.
5. Como iniciar a minicampanha no Godot.
6. Como acessar o combate original.
7. Como testar os quatro capítulos, os descansos e as recompensas.

**PRIORIDADE MÁXIMA: preservar a estabilidade do Santa Mina e transformar as regras já definidas em uma minicampanha realmente jogável.**