# SANTA MINA — AJUSTE DE VANTAGEM, DESVANTAGEM E ALCANCE DAS LANÇAS

Atualize o projeto existente em Godot 4, preservando todas as funcionalidades já implementadas e testadas.

Antes de modificar arquivos, examine a implementação atual de combate, equipamentos, alcance, Vantagem e Desvantagem, especialmente os scripts `combate.gd`, `regras_combate.gd`, `equipamentos_combate.gd`, `grade_combate.gd` e os testes automatizados.

**Não recrie o projeto e não altere sistemas que já funcionam sem necessidade.**

## 1. VANTAGEM E DESVANTAGEM SIMULTÂNEAS

Implementar a seguinte regra oficial:

- Quando um personagem possuir somente Vantagem, rolar dois dados e utilizar o maior resultado.
- Quando possuir somente Desvantagem, rolar dois dados e utilizar o menor resultado.
- Quando possuir Vantagem e Desvantagem simultaneamente, os efeitos se anulam.
- Nesse último caso, realizar uma rolagem normal com apenas um dado.

Essa regra deve funcionar independentemente da origem dos efeitos.

Exemplo: se o bandido estiver com Desvantagem por utilizar Arco Curto perto de Brokk, mas receber Vantagem de outra habilidade, realizará uma rolagem normal.

Preservar as animações e a correspondência entre os resultados visuais e os valores utilizados nos cálculos.

Não consumir custos adicionais nem usos de habilidades além daqueles previstos nas regras existentes.

Se uma ação comprada com Vantagem custar 2 PA adicionais, esse custo continua sendo pago mesmo quando outra condição anular a Vantagem. Não devolver PA automaticamente.

Preparar essa resolução para utilização futura em ataques, testes de desafio e testes de resistência.

## 2. ALCANCE DAS LANÇAS GRANDES

Cadastrar ou atualizar os seguintes equipamentos na estrutura reutilizável existente:

**Lança de Ferro Grande**
- Categoria: Comum.
- Tipo: Corpo a Corpo.
- Empunhadura: 2H.
- Dano físico: 1d6.
- Valor: 5 coroas.
- Alcance: até duas casas, incluindo diagonais.
- Pode atacar através de obstáculos e personagens intermediários.
- Ao obter 6 natural no dado, ignora a Defesa do alvo, desde que o usuário possua pelo menos +3 de FOR ou DES.

**Lança de Aço Imperial**
- Categoria: Rara.
- Tipo: Corpo a Corpo.
- Empunhadura: 2H.
- Dano físico: 1d8.
- Valor: 10 coroas.
- Alcance: até duas casas, incluindo diagonais.
- Pode atacar através de obstáculos e personagens intermediários.
- Ao obter 6 ou mais no dado, ignora a Defesa do alvo, desde que o usuário possua pelo menos +3 de FOR ou DES.

Para calcular o alcance, considerar a maior distância entre as diferenças de linha e coluna, permitindo diagonais.

Exemplo: um personagem em B3 pode atingir um alvo em A5, B5 ou C5.

O ataque continua direcionado a um único alvo. Não causar dano a personagens intermediários.

Ignorar obstáculos apenas para determinar se a lança pode alcançar o alvo. Não permitir movimentação através de obstáculos.

**Importante:** cadastrar as duas lanças e suas propriedades sem substituir o Machado de Ferro atualmente equipado por Brokk ou o Arco Curto utilizado pelo bandido.

Se a aplicação do efeito de ignorar Defesa exigir alterações significativas no combate atual, preparar os dados e uma função reutilizável, sem ativar uma mecânica incompleta.

## 3. CRÍTICOS — NÃO IMPLEMENTAR AGORA

Não implementar Crítico Padrão, Crítico Dobrado, estado Motivado ou PA extras de críticos.

Preservar o bônus especial do Machado de Ferro: +2 de dano bruto ao obter 6 natural.

Esse bônus não deve ser tratado automaticamente como um acerto crítico.

Manter os efeitos especiais das armas separados das futuras regras de crítico.

## 4. PRESERVAÇÃO DO COMBATE

Manter funcionando:

- Tabuleiro 3×6 com casas de 88 pixels.
- Iniciativa e posicionamento inicial.
- 5 PA por turno.
- Movimentação e corrida.
- Defesa dinâmica.
- Pele de Rocha.
- Escudo de Madeira e Ferro com −1 DES e Defesa condicional.
- Machado de Ferro de Brokk.
- Arco Curto do bandido.
- Mestre das Armas.
- Muralha de Ferro.
- Dados 3D e animações.
- Encerramento voluntário do turno.

Não modificar o tamanho do tabuleiro nem os sprites.

## 5. TESTES E VALIDAÇÃO

Atualizar e ampliar os testes automatizados para verificar:

1. Vantagem isolada utiliza o maior de dois dados.
2. Desvantagem isolada utiliza o menor de dois dados.
3. Vantagem e Desvantagem simultâneas utilizam somente um dado.
4. A anulação funciona mesmo quando os efeitos possuem origens diferentes.
5. Os custos de PA continuam corretos.
6. Lança de Ferro Grande alcança até duas casas, inclusive diagonais.
7. Lança de Aço Imperial alcança até duas casas, inclusive diagonais.
8. As lanças não alcançam alvos a três ou mais casas.
9. As lanças podem atacar através de obstáculos e personagens intermediários.
10. O ataque atinge apenas o alvo selecionado.
11. O efeito especial da Lança de Ferro Grande exige resultado 6 e FOR ou DES +3.
12. O efeito especial da Lança de Aço Imperial exige resultado 6 ou mais e FOR ou DES +3.
13. O Machado de Ferro continua equipado por Brokk.
14. O Arco Curto continua equipado pelo bandido.
15. As regras de críticos não foram ativadas.
16. Todos os testes anteriores continuam passando.

Execute a validação do Godot em modo headless, se disponível.

Ao concluir, informe os arquivos modificados, as regras implementadas, os testes executados e eventuais pendências.

**Prioridade:** manter o projeto estável e preservar tudo o que já funciona.