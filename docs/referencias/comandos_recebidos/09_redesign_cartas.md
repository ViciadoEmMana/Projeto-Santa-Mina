# SANTA MINA — REDESIGN VISUAL DAS CARTAS DE COMBATE

## OBJETIVO

Reformular visualmente as cinco cartas básicas permanentes do Santa Mina para que se pareçam com cartas reais de um RPG de construção de baralho, utilizando **Slay the Spire como referência de experiência visual**, mas mantendo identidade artística própria.

**ATENÇÃO:** as cinco cartas já estão implementadas e funcionando. Esta tarefa é principalmente visual.

O último relatório apresentou 1.953 verificações automatizadas e 11 verificações com renderização, todas aprovadas.

Preservar esse funcionamento.

## 1. PROBLEMA ATUAL

As cartas básicas estão funcionando, mas visualmente ainda se parecem com botões tradicionais.

Quero cartas verticais de verdade, com:
- Moldura ornamental medieval.
- Área grande para ilustração.
- Nome da carta.
- Custo de PA destacado no canto superior.
- Texto explicando o efeito.
- Cores diferentes conforme a categoria.
- Animações de seleção e destaque.
- Aparência de cartas físicas colocadas na mão do jogador.

Não quero simplesmente aumentar o tamanho dos botões existentes.

## 2. FORMATO DAS CARTAS

Criar componentes visuais com proporção aproximada de 2:3.

Cada carta deverá conter:

**Cabeçalho**
- Nome da carta.
- Custo de PA dentro de um medalhão circular.
- Moldura com detalhes medievais.

**Ilustração**
- Ocupar aproximadamente metade da altura da carta.
- Utilizar uma área TextureRect preparada para receber a arte oficial.
- Preservar a proporção da imagem.
- Evitar distorção ou cortes excessivos.

**Descrição**
- Área inferior com fundo semelhante a pergaminho escuro.
- Texto legível.
- Custo e efeitos claramente identificados.

**Rodapé**
- Identificação discreta da categoria: Básica.

Criar uma aparência medieval sombria, com madeira, bronze, metal envelhecido e pergaminho.

Não copiar diretamente artes, molduras ou outros elementos protegidos de Slay the Spire.

## 3. CORES E IDENTIDADE VISUAL

Sugestão:

- Ataque: vermelho escuro e bronze.
- Defender: azul-acinzentado e aço.
- Mover: verde-musgo.
- Correr: âmbar e couro.
- Ataque com Vantagem: dourado e vermelho escuro.

Manter unidade visual entre as cinco cartas.

## 4. ILUSTRAÇÕES

As artes oficiais serão fornecidas posteriormente pelo usuário.

Nesta etapa:

- Verificar se já existem artes apropriadas no projeto.
- Reutilizar somente recursos existentes e autorizados.
- Se não houver ilustrações, criar placeholders visuais estilizados usando elementos gráficos do Godot.
- Não depender de imagens baixadas automaticamente.
- Manter o campo `arte` já implementado.
- Permitir substituir cada ilustração facilmente por um arquivo PNG ou WebP.

Os placeholders devem ser visualmente agradáveis e não apenas quadrados vazios.

## 5. POSICIONAMENTO NA TELA

Criar uma mão de cartas na região inferior da interface de combate.

Requisitos:

- Cinco cartas visíveis.
- Distribuição horizontal.
- Espaçamento reduzido, semelhante a uma mão de cartas.
- Pequena sobreposição ou inclinação visual, se possível.
- A carta selecionada deve subir ligeiramente.
- A carta sob o cursor deve ganhar destaque e ampliar suavemente.
- Não cobrir permanentemente o tabuleiro.
- Não impedir a visualização dos dados 3D.
- Não encobrir barras de PV, PA ou o registro de combate.

A disposição deve se adaptar à resolução da janela.

Caso não haja espaço suficiente, reduzir proporcionalmente o tamanho das cartas ou usar um layout compacto que preserve a legibilidade.

## 6. INTERAÇÕES E ANIMAÇÕES

Implementar transições suaves.

**Ao passar o mouse:**
- Carta sobe alguns pixels.
- Aumenta discretamente.
- Ganha iluminação na moldura.
- Aparece acima das cartas vizinhas.

**Ao selecionar:**
- Moldura dourada.
- Carta permanece destacada.
- Alvos ou destinos válidos continuam destacados no tabuleiro.

**Ao cancelar com Esc:**
- Carta retorna ao estado normal.
- Nenhum PA é consumido.

**Quando indisponível:**
- Carta fica escurecida.
- Custo permanece visível.
- Exibir motivo do bloqueio.
- Não permitir execução inválida.

**Durante o turno inimigo:**
- Cartas permanecem visíveis, mas indisponíveis.

Não utilizar animações exageradas que prejudiquem a velocidade do combate.

## 7. CINCO CARTAS EXISTENTES

Preservar exatamente:

1. Ataque — 3 PA.
2. Defender — 1 PA.
3. Mover — 2 PA.
4. Correr — 3 PA.
5. Ataque com Vantagem — 5 PA.

Não alterar dano, Defesa, movimentação, alcance, Vantagem ou Desvantagem.

Não criar novas cartas nesta atualização.

## 8. ARQUITETURA

Reutilizar os três componentes de cartas já criados.

Inspecionar a implementação atual antes de modificá-la.

Separar:
- Dados e regras da carta.
- Aparência visual.
- Animações.
- Integração com o combate.

Preparar o sistema para receber posteriormente uma mão de cartas especiais, incluindo magias, armadilhas e ações rápidas.

Não implementar compra, descarte ou baralho nesta etapa.

## 9. VALIDAÇÃO VISUAL OBRIGATÓRIA

Não considerar o trabalho concluído apenas porque os testes de lógica passaram.

Executar o jogo com renderização e capturar imagens reais da interface.

Verificar visualmente:
- As cartas possuem formato vertical de carta de RPG.
- O custo está no canto superior.
- A área de ilustração é grande.
- O texto é legível.
- As cartas estão organizadas como uma mão.
- A carta selecionada se destaca.
- A carta indisponível fica escurecida.
- O tabuleiro permanece visível.
- Não há elementos sobrepostos indevidamente.
- Os dados 3D continuam aparecendo.

Corrigir problemas de alinhamento, tamanho e posicionamento encontrados nas capturas.

Executar os testes anteriores e acrescentar testes específicos da nova interface.

## 10. ENTREGA

Ao concluir, informar:
- Arquivos modificados.
- Como ficou o novo design.
- Total de testes aprovados e falhas.
- Local das capturas de tela.
- Como substituir as ilustrações pelas artes oficiais.
- Como testar no F6.

**RESULTADO ESPERADO**

Quero abrir o Santa Mina e reconhecer imediatamente cinco cartas de RPG na parte inferior da tela, com aparência semelhante à experiência de Slay the Spire, mas com identidade visual própria.

Não quero cinco botões retangulares estilizados.

A prioridade é a qualidade visual, preservando integralmente a funcionalidade já implementada.