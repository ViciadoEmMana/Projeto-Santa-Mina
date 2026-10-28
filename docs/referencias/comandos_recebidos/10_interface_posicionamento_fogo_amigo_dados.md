# SANTA MINA — ATUALIZAÇÃO DE INTERFACE, POSICIONAMENTO, FOGO AMIGO E DADOS 3D

## OBJETIVO

Atualizar o projeto Santa Mina, desenvolvido no Godot 4, em quatro áreas:

1. Corrigir problemas visuais e de legibilidade da interface.
2. Implementar posicionamento inicial estratégico das criaturas.
3. Implementar fogo amigo para arqueiros jogadores e inimigos.
4. Criar um sistema visual aprimorado de dados 3D: d4, d6, d8, d10, d12 e d20.

O usuário testou a versão atual no F6. As cinco cartas básicas estão funcionando, mas existem problemas de texto pequeno, sobreposição e organização dos painéis.

A captura de tela fornecida pelo usuário deve ser utilizada como referência para os problemas visuais. Caso a imagem não esteja acessível no ambiente do Codex, solicitar seu envio ou realizar uma nova captura equivalente do jogo.

**Preservar todas as regras e funcionalidades existentes. Não recriar o projeto.**

---

# ETAPA 1 — CORREÇÃO DA INTERFACE

## Problemas identificados

- Informações sobrepostas nas fichas superiores.
- Textos pequenos nas cartas e nos painéis.
- Descrições das cartas comprimidas.
- Mensagens de iniciativa próximas de outros elementos.
- Registro de combate pequeno.
- Botão de encerrar turno isolado e com pouco espaço.
- Elementos visuais com aparência pouco nítida.

## Requisitos

### A. Organização dos painéis

Separar claramente:
- Informações do herói.
- Informações dos inimigos.
- Tabuleiro.
- Ordem de iniciativa.
- Registro de combate.
- Mão de cartas.
- Controles de turno.

Nenhum painel deve encobrir outro.

Criar áreas responsivas usando os containers e as âncoras apropriados do Godot.

### B. Tipografia

- Aumentar a legibilidade dos textos.
- Corrigir textos cortados ou sobrepostos.
- Usar fontes adequadas à resolução do jogo.
- Evitar escalonamento fracionário de textos e controles quando provocar borramento.
- Verificar filtros de textura e configurações de renderização.
- Não reduzir a fonte como solução principal para falta de espaço.

### C. Cartas

Manter o estilo visual inspirado em jogos de cartas como Slay the Spire, mas com identidade própria.

Preservar:
- Molduras ornamentadas.
- Ilustrações.
- Custos de PA.
- Destaque da carta selecionada.
- Bloqueio quando não houver PA.
- Cancelamento com Esc.

Melhorar:
- Legibilidade do nome.
- Legibilidade da descrição.
- Espaçamento interno.
- Organização da mão.
- Animações de seleção.
- Clareza do estado disponível/indisponível.

Não modificar os custos nem os efeitos das cinco cartas.

### D. Testes visuais

Capturar imagens reais do jogo em diferentes situações:
- Escolha de posição inicial.
- Turno do jogador.
- Turno inimigo.
- Carta selecionada.
- Carta indisponível.
- Registro de combate com várias mensagens.

Verificar que não existem textos cortados ou sobreposições.

---

# ETAPA 2 — POSICIONAMENTO ESTRATÉGICO DAS CRIATURAS

## A. Criaturas corpo a corpo

Toda criatura inimiga que utiliza ataques corpo a corpo deve começar na primeira fileira da formação inimiga.

A primeira fileira significa a fileira ou coluna da área inimiga mais próxima da área dos heróis, considerando a orientação real do tabuleiro.

A criatura deve:
- Identificar os heróis disponíveis.
- Escolher a casa livre que minimize a distância até seu alvo.
- Respeitar obstáculos e ocupação.
- Não ocupar uma casa já escolhida por outra criatura.
- Não começar fora da área de posicionamento permitida.

Usar distância compatível com as regras de movimentação existentes.

## B. Criaturas à distância

Criaturas que utilizam arco ou outros ataques à distância devem começar preferencialmente na segunda ou terceira fileira da formação inimiga.

A preferência deve ser configurável por criatura.

Exemplos:
- Arqueiro comum: preferência pela segunda fileira.
- Arqueiro que procura maior proteção: preferência pela terceira fileira.

Esses exemplos não devem alterar automaticamente a ficha de todas as criaturas. A preferência precisa ser definida de acordo com cada inimigo existente.

Se a fileira preferida estiver ocupada, buscar outra casa válida.

## C. Iniciativa e posicionamento

A iniciativa deve influenciar a ordem de escolha das posições iniciais.

- Calcular a iniciativa antes de finalizar o posicionamento.
- Respeitar a ordem da iniciativa na escolha das posições.
- Quem escolhe primeiro ocupa uma casa válida.
- Quem escolhe depois deve considerar as posições já escolhidas.
- Se o herói escolheu antes, o inimigo corpo a corpo pode escolher a casa mais próxima da posição real do herói.
- Se o inimigo escolheu antes, ele não pode conhecer uma posição futura ainda não escolhida pelo herói.
- Não alterar o resultado da iniciativa.
- Não conceder PA ou movimento gratuitos.

Se o fluxo atual de escolha de posição exigir ajustes, reorganizá-lo preservando as regras existentes.

Não transformar o posicionamento inicial em uma rodada de combate.

## D. Múltiplos heróis

Preparar a lógica para funcionar futuramente com mais de um herói controlado pelo jogador.

Evitar regras específicas exclusivamente para Brokk.

---

# ETAPA 3 — FOGO AMIGO PARA ARQUEIROS

## A. Regra

O fogo amigo vale tanto para arqueiros inimigos quanto para arqueiros jogadores.

Quando um arqueiro dispara contra um alvo e existe outro personagem diretamente na trajetória da flecha:

- Resultado natural 1 ou 2 no dado de ataque: ativar fogo amigo.
- Resultado natural 3 ou superior: não ativar fogo amigo.

O personagem intermediário atingido pode ser aliado ou inimigo do arqueiro, conforme sua posição real.

Não escolher personagens fora da linha de tiro.

## B. Resolução

Quando o fogo amigo for ativado:

1. Identificar o primeiro personagem na trajetória entre o arqueiro e o alvo.
2. Desviar o ataque para esse personagem.
3. Rolar novamente o dado de dano da arma.
4. Aplicar os modificadores de dano e as regras de Defesa pertinentes.
5. Aplicar o dano ao personagem intermediário.
6. Registrar o ocorrido no histórico de combate.

O alvo original não deve receber o dano desse mesmo disparo.

O ataque deve consumir apenas seu custo normal de PA.

Não criar um segundo ataque independente.

## C. Interação com erro natural

A regra atual de erro natural 1 deve continuar funcionando para os demais ataques.

Para ataques com arco, quando existir personagem interceptando a trajetória, o resultado natural 1 ou 2 deve ser avaliado pela regra especial de fogo amigo.

Quando não houver personagem interceptando, preservar as regras normais do ataque.

## D. Geometria

Detectar personagens realmente alinhados na trajetória do disparo.

Respeitar:
- Linha de tiro.
- Casas ocupadas.
- Obstáculos.
- Primeiro personagem interceptador.

Não utilizar apenas proximidade ou distância como critério.

## E. Registro e efeitos

Exibir mensagem como:

"FOGO AMIGO! A flecha atingiu [nome do personagem]!"

Adicionar efeito visual e sonoro compatível com a animação de flecha existente.

Não implementar fogo amigo para magias ou armas não especificadas.

---

# ETAPA 4 — NOVOS DADOS 3D

Criar dados tridimensionais com geometria correspondente ao número de faces.

Dados obrigatórios:

- d4 — tetraedro.
- d6 — cubo.
- d8 — octaedro.
- d10 — sólido de dez faces.
- d12 — dodecaedro.
- d20 — icosaedro.

## Requisitos visuais

- Geometria tridimensional real.
- Números legíveis e corretamente posicionados.
- Materiais inspirados em metal, pedra ou osso.
- Estética medieval sombria.
- Iluminação que valorize as faces.
- Animação de lançamento e rotação.
- Parada suave.
- Efeitos de impacto discretos.
- Identificação visual de dados do jogador e dos inimigos.

## Requisitos funcionais

- O resultado visual deve corresponder exatamente ao resultado da lógica do combate.
- Não executar uma segunda rolagem que altere o resultado.
- Suportar rolagens com vários dados, como 2d4.
- Suportar Vantagem e Desvantagem.
- Suportar testes de atributos com d20.
- Preservar as animações e sons já existentes quando apropriado.
- Não modificar os cálculos de dano.
- Não alterar as regras de críticos.

## Desempenho

Evitar efeitos excessivamente pesados.

Criar componentes reutilizáveis para que qualquer criatura ou habilidade possa solicitar uma rolagem de d4, d6, d8, d10, d12 ou d20.

---

# ETAPA 5 — VALIDAÇÃO

Executar os testes existentes e acrescentar novos testes.

Verificar especialmente:

1. Nenhum texto fica sobreposto.
2. A interface permanece legível.
3. As cinco cartas continuam funcionando.
4. As criaturas corpo a corpo começam na primeira fileira.
5. As criaturas à distância preferem a segunda ou terceira fileira.
6. A ordem da iniciativa influencia o posicionamento.
7. Não há sobreposição de criaturas na escolha inicial.
8. O fogo amigo funciona para inimigos.
9. O fogo amigo funciona para jogadores.
10. O fogo amigo ativa com 1 ou 2 quando existe interceptador.
11. O fogo amigo não ativa sem interceptador.
12. O dano é aplicado ao personagem correto.
13. O alvo original não recebe dano duplicado.
14. Todos os seis tipos de dados funcionam.
15. Os números apresentados correspondem aos resultados calculados.
16. O combate original continua funcionando.
17. Os quatro capítulos da campanha continuam jogáveis.
18. As habilidades de Tripa Seca continuam funcionando.
19. A inteligência artificial mantém seu comportamento ofensivo.
20. Os efeitos visuais e sonoros permanecem sincronizados.

## ENTREGA

Ao finalizar:

- Informar arquivos modificados e criados.
- Apresentar resumo das correções visuais.
- Explicar o posicionamento por iniciativa.
- Explicar a resolução do fogo amigo.
- Demonstrar os seis tipos de dados.
- Informar o total de testes aprovados e falhas.
- Produzir capturas de tela da interface corrigida.
- Explicar como testar tudo no F6.

**IMPORTANTE:** não considerar a correção visual concluída apenas porque os testes automatizados passaram. Inspecionar as capturas renderizadas e corrigir problemas reais de legibilidade e sobreposição.