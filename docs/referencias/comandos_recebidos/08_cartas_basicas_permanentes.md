# SANTA MINA — SISTEMA DE CARTAS DE COMBATE
## ETAPA 1: CARTAS BÁSICAS PERMANENTES

### OBJETIVO

Implementar uma interface de cartas para representar as cinco ações básicas do combate, preservando integralmente as regras e funcionalidades existentes.

O projeto utiliza Godot 4 e já possui:
- Tabuleiro tático de 3 linhas por 6 colunas.
- Brokk Pedraférrea como personagem jogável.
- Inimigos com inteligência artificial.
- Sistema de Pontos de Ação (PA).
- Dados 3D animados.
- Efeitos visuais e sonoros.
- Minicampanha de quatro capítulos.
- Inventário, alimentação e descansos.
- Habilidades especiais de Tripa Seca.

O sistema de combate atual está funcional e foi testado pelo usuário.

**IMPORTANTE: esta etapa deve modificar principalmente a apresentação das ações, e não suas regras.**

Não recriar o projeto, não substituir o combate e não alterar o equilíbrio das criaturas.

---

# 1. NOVO SISTEMA DE CARTAS

O combate terá duas categorias de cartas.

**Categoria A — Cartas básicas permanentes**

Implementar agora.

São cartas que representam as ações comuns do personagem e permanecem disponíveis durante todo o combate.

Não são compradas, descartadas, consumidas nem retiradas da mão.

**Categoria B — Cartas especiais**

Não implementar nesta etapa.

No futuro, incluirá:
- Cartas mágicas.
- Cartas armadilhas.
- Cartas de ação rápida.
- Outras cartas especiais.

Preparar uma arquitetura que permita adicionar a segunda categoria posteriormente, sem precisar reconstruir a interface.

---

# 2. AS CINCO CARTAS BÁSICAS

## CARTA 1 — ATAQUE

Nome: Ataque

Custo: 3 PA.

Efeito:
- Realizar um ataque básico com a arma equipada.
- Utilizar o dano, atributo e alcance da arma.
- Respeitar Defesa, condições, Vantagem e Desvantagem.
- Permitir selecionar um inimigo válido.

Se o alvo estiver fora do alcance, impedir a ação sem gastar PA.

Reutilizar exatamente a função de ataque já existente.

## CARTA 2 — DEFENDER

Nome: Defender

Custo: 1 PA.

Efeito:
- Ativar a ação de defesa existente.
- Conceder +2 de Defesa até o início do próximo turno do personagem, conforme a regra atual.

Não alterar a interação com escudos ou Defesa natural.

## CARTA 3 — MOVER

Nome: Mover

Custo: 2 PA.

Efeito:
- Mover uma casa ortogonalmente.
- Respeitar obstáculos e casas ocupadas.
- Não permitir movimento diagonal.
- Utilizar a lógica de movimentação já existente.

Ao selecionar a carta, permitir escolher a casa de destino.

## CARTA 4 — CORRER

Nome: Correr

Custo: 3 PA.

Efeito:
- Mover até duas casas ortogonalmente.
- Respeitar caminhos válidos, obstáculos e ocupação.
- Não atravessar personagens.
- Utilizar a lógica de corrida existente.

Ao selecionar a carta, permitir escolher um destino válido.

## CARTA 5 — ATAQUE COM VANTAGEM

Nome: Ataque com Vantagem

Custo: 5 PA.

Efeito:
- Realizar um ataque utilizando a regra de Vantagem comprada.
- Rolar dois dados e utilizar o maior quando houver Vantagem efetiva.
- Respeitar a regra de cancelamento entre Vantagem e Desvantagem.
- Preservar o custo de 5 PA mesmo quando a Vantagem for anulada.
- Utilizar o dano e alcance da arma equipada.

Não adicionar dano extra nem implementar críticos.

---

# 3. INTERFACE VISUAL

Criar uma barra de cartas básicas na parte inferior da tela de combate.

As cartas devem ter estilo medieval sombrio, compatível com a interface atual:

- Madeira escura.
- Bordas de bronze.
- Detalhes dourados.
- Texto legível.
- Ícones distintos.
- Custo de PA claramente visível.

Cada carta deve mostrar:
1. Nome.
2. Ícone.
3. Custo em PA.
4. Breve descrição ao passar o mouse ou selecionar.

Para esta etapa, utilizar ícones ou ilustrações simples que possam ser substituídos futuramente pelas artes oficiais do usuário.

Não gerar imagens externas automaticamente.

Não depender de arquivos de terceiros para a interface funcionar.

### Estados visuais

**Disponível:** aparência normal, com borda discreta.

**Selecionada:** destaque dourado e indicação clara da ação ativa.

**Indisponível:** aparência escurecida e explicação do motivo.

**Ao passar o mouse:** apresentar descrição e custo.

**Ao clicar:** selecionar ou executar a ação conforme seu funcionamento.

A interface deve permitir cancelar uma seleção sem consumir PA.

---

# 4. INTEGRAÇÃO COM O COMBATE EXISTENTE

As cartas devem atuar como uma nova interface para as ações já existentes.

Não criar uma segunda implementação das mecânicas.

Por exemplo:

A carta Ataque deve chamar o mesmo sistema que atualmente executa um ataque básico.

A carta Defender deve utilizar o sistema de defesa atual.

As cartas Mover e Correr devem reutilizar a validação de deslocamento existente.

### Evitar ações duplicadas

Se os botões tradicionais ainda estiverem presentes, não permitir que a mesma ação seja executada duas vezes por um único clique.

Preferencialmente, substituir visualmente os botões correspondentes pelas cartas, preservando os métodos internos e os sinais utilizados pelo combate.

### Seleção de alvos

Ao selecionar Ataque ou Ataque com Vantagem:
- Destacar inimigos válidos.
- Permitir selecionar o alvo.
- Exibir indicação de alcance.
- Não consumir PA antes de uma ação válida ser confirmada.

Ao selecionar Mover ou Correr:
- Destacar casas válidas.
- Permitir selecionar o destino.
- Não consumir PA ao cancelar.

Preservar o comportamento das habilidades especiais, inclusive Golpe Sujo e Me Protejam! de Tripa Seca.

---

# 5. ORGANIZAÇÃO DAS CARTAS

Ordem sugerida na interface:

1. Ataque — 3 PA.
2. Defender — 1 PA.
3. Mover — 2 PA.
4. Correr — 3 PA.
5. Ataque com Vantagem — 5 PA.

As cartas devem permanecer visíveis durante o turno de Brokk.

Durante o turno dos inimigos, não devem permitir ações do jogador.

Se necessário, deixá-las visíveis, porém desabilitadas.

A interface deve adaptar o tamanho das cartas ao espaço disponível, sem encobrir o tabuleiro, os dados 3D, as barras de vida ou o registro de combate.

---

# 6. ARQUITETURA PARA EXPANSÃO FUTURA

Criar componentes reutilizáveis, se isso for adequado à estrutura atual, como:

- CartaCombate.tscn.
- carta_combate.gd.
- barra_cartas_basicas.gd.
- Definições de cartas em recursos ou dados estruturados.

Evitar concentrar toda a lógica visual em `combate.gd`.

Preparar a possibilidade de adicionar uma segunda área de interface para a mão de cartas especiais.

Não implementar ainda:
- Compra de cartas.
- Baralho.
- Pilha de descarte.
- Cartas mágicas.
- Cartas armadilhas.
- Cartas de ação rápida.
- Consumo de cartas.
- Custos especiais de cartas.

Essas funcionalidades serão desenvolvidas na segunda etapa.

---

# 7. TESTES AUTOMATIZADOS

Preservar todos os testes existentes e acrescentar verificações para:

1. As cinco cartas básicas aparecem na interface.
2. Todas apresentam os custos corretos.
3. Ataque consome exatamente 3 PA.
4. Defender consome exatamente 1 PA.
5. Mover consome exatamente 2 PA.
6. Correr consome exatamente 3 PA.
7. Ataque com Vantagem consome exatamente 5 PA.
8. Cartas não podem ser usadas sem PA suficientes.
9. Cartas não podem ser usadas durante o turno inimigo.
10. Selecionar e cancelar não consome PA.
11. Ataque fora do alcance é impedido.
12. Movimento inválido não consome PA.
13. Corrida respeita obstáculos.
14. Defesa continua funcionando corretamente.
15. Vantagem e Desvantagem continuam funcionando.
16. As cartas permanecem disponíveis após sua utilização.
17. Nenhuma carta básica é descartada.
18. Os dados 3D continuam funcionando.
19. Os sons e efeitos permanecem sincronizados.
20. A inteligência artificial dos inimigos não é afetada.
21. Golpe Sujo e Me Protejam! continuam funcionando.
22. O combate original continua jogável.
23. Os quatro capítulos da campanha continuam jogáveis.
24. A interface não encobre elementos essenciais do combate.

Executar os testes automatizados anteriores e novos testes de interface.

---

# 8. ENTREGA

Ao concluir, apresentar:

1. Resumo das alterações.
2. Arquivos criados e modificados.
3. Quantidade de testes executados e falhas.
4. Como abrir e testar a nova interface no Godot.
5. Como substituir futuramente os ícones pelas artes oficiais.
6. Eventuais limitações.

Realizar pelo menos um teste real de combate usando as cinco cartas.

**RESULTADO ESPERADO:**

O jogador poderá controlar Brokk utilizando cinco cartas básicas permanentes, mantendo as mesmas regras de combate, os mesmos custos de PA e todas as funcionalidades já implementadas.

Esta é apenas a primeira etapa do sistema de cartas do Santa Mina. Priorizar estabilidade, legibilidade e facilidade de expansão.