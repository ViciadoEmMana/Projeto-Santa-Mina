# SANTA MINA — ATUALIZAÇÃO OFICIAL DO PROTAGONISTA PARA ZENO

## OBJETIVO

Atualizar o projeto existente do Santa Mina, em Godot 4, preservando todas as funcionalidades já implementadas e testadas, mas substituindo **Brokk Pedraférrea** como protagonista jogável principal por **Zeno**, um **Humano Guerreiro**.

**IMPORTANTE:**
- Não recriar o projeto do zero.
- Não apagar sistemas já prontos.
- Preservar combate, campanha, salvamento, interface, dados 3D, cartas básicas, IA, efeitos, regras e documentação.
- Inspecionar primeiro o estado atual do projeto e usar o documento mestre existente como referência.
- Tratar esta atualização como uma evolução do projeto existente.

---

## 1. NOVO PROTAGONISTA OFICIAL

O protagonista jogável principal passa a ser:

### Zeno
- **Raça:** Humano
- **Classe:** Guerreiro
- **Papel:** guerreiro humano de linha de frente
- **Visual oficial:** humano guerreiro com espada e escudo, armadura metálica, tecido verde e perfil de protagonista sério
- **Equipamento inicial:** Espada de Ferro (1H) + Escudo de Ferro e Madeira

Brokk não precisa ser apagado do projeto imediatamente se estiver fortemente acoplado a testes ou referências antigas, mas o personagem jogável principal, a interface, a campanha atual e a documentação devem passar a refletir **Zeno** como protagonista.

Se houver necessidade técnica, manter Brokk apenas como referência interna legada, sem aparecer como protagonista do fluxo principal.

---

## 2. ATRIBUTOS E CLASSE DE ZENO

A classe **Guerreiro** continua com os mesmos bônus já aprovados no projeto:

- FOR +2
- DES +2
- CON +2
- INT 0
- SAB +1
- CAR +1

A raça **Humano** permite escolher dois atributos para receber +1:

- +1 FOR
- +1 CON

### TOTAL DE ZENO ANTES DOS EQUIPAMENTOS:
- FOR +3
- DES +2
- CON +3
- INT 0
- SAB +1
- CAR +1

### PV E PA
- PV máximos: **14**
- PA por turno: **5**

Esses valores devem substituir os equivalentes do protagonista atual, mantendo compatibilidade com os sistemas existentes.

---

## 3. RAÇA HUMANO

### Humano (O Versátil)
- Ajuste de Atributo: escolha dois atributos e aplique +1
- Habilidade Passiva: **Talento Universal**
- O talento escolhido para Zeno será: **Veterano de Batalha**

Não criar sistema completo de escolha de raça para o jogador agora. Nesta fase, apenas aplicar corretamente a raça Humano ao protagonista Zeno.

---

## 4. TALENTO RACIAL DE ZENO — VETERANO DE BATALHA

Implementar este talento como passiva racial de Zeno.

### 4.1. Bônus defensivo
Se Zeno:
- **defender** ou
- **esquivar de um ataque**
e **não receber dano** nessa resolução,

então ele ganha:

- **+1 de Defesa até o final do combate**

Regras:
- ativa no máximo **uma vez por combate**
- não acumula com novas ativações do mesmo bônus
- deve ficar claramente indicado na interface enquanto estiver ativo
- deve desaparecer ao fim do combate

### 4.2. Bônus ofensivo
Se Zeno obtiver:
- resultado natural **5 ou mais**
no **dado natural da arma**,

então ele ganha:

- **+1 de dano causado até o final do combate**

Regras:
- vale para d6, d8, d10, d12 ou outro dado de arma capaz de rolar 5 ou mais
- ativa no máximo **uma vez por combate**
- não acumula
- deve aparecer na interface enquanto estiver ativo
- deve desaparecer ao fim do combate

### 4.3. Efeitos visuais e sonoros
Quando cada parte do talento ativar:

#### Defesa +1
- criar um efeito visual defensivo (ex.: brilho azulado, sinal de escudo ou runa discreta)
- tocar um som de reforço defensivo / metal / proteção

#### Dano +1
- criar um efeito visual ofensivo (ex.: brilho avermelhado ou dourado na arma)
- tocar um som de fortalecimento / ímpeto ofensivo

Esses efeitos devem ser claros, mas não exagerados.

### 4.4. Aplicação mecânica
- Defesa +1 entra no cálculo de Defesa como bônus temporário até o fim do combate
- Dano +1 entra no dano causado por Zeno até o fim do combate
- preservar as regras existentes de Defesa, Vantagem, Desvantagem, dados, armas e habilidades

---

## 5. EQUIPAMENTOS INICIAIS DE ZENO

### Espada de Ferro — 1H
Usar as regras já aprovadas para a Espada de Ferro:
- dano 1d6 físico
- uma vez por luta, pode repetir um ataque errado se tiver pelo menos 2 em Força ou Destreza

Integrar corretamente com:
- Mestre das Armas
- Vantagem e Desvantagem
- efeitos de dano e Defesa
- talento Veterano de Batalha

### Escudo de Ferro e Madeira
Usar a regra já aprovada:
- +2 de Defesa quando o inimigo rola 2 ou 3 no dado natural de ataque
- aplicar **−1 DES**

Portanto:
- Zeno possui DES base +2
- DES efetiva com escudo equipado = **+1**

Preservar a lógica de escudo já existente, adaptando o protagonista ao novo equipamento.

---

## 6. HABILIDADES DE CLASSE DE ZENO

Zeno continua sendo um **Guerreiro**, portanto mantém as mesmas habilidades de classe já implementadas:

- Físico Atlético
- Mestre das Armas
- Muralha de Ferro

Regras:
- não alterar a lógica atual dessas habilidades
- apenas garantir compatibilidade com Zeno, espada, escudo e talento racial humano

---

## 7. ATUALIZAÇÃO VISUAL E DE IDENTIDADE

### 7.1. Protagonista
Substituir as referências principais visuais, nominais e descritivas do protagonista por **Zeno**.

Onde aplicável:
- nome exibido na interface
- ficha
- registro de combate
- salvamento
- campanha
- textos de documentação
- retrato do personagem
- cards/fichas visuais do protagonista

### 7.2. Direção dos assets
A direção de arte do jogo deve seguir este princípio:

- **Ilustração oficial do protagonista:** estilo da imagem fornecida pelo usuário para Zeno
- **Sprites, criaturas, animações e assets in-game:** inspirados na qualidade geral de **Songs of Conquest** e também no tipo de monstros/creatures e design de assets do pacote:
  - Luiz Melo — Monsters & Creatures Fantasy
- Não copiar diretamente assets desses jogos/pacotes.
- Criar identidade visual própria para Santa Mina.

### 7.3. Escopo desta atualização
Não tentar refazer todas as artes finais do projeto de uma vez, a menos que isso já esteja no fluxo atual.

Nesta atualização:
- priorizar a troca do protagonista para Zeno
- atualizar suas referências visuais
- preparar a estrutura para futura substituição/refino de sprites e retratos

Se já existir sistema de assets integrados:
- adaptar ou atualizar o personagem jogável principal para o novo protagonista
- manter o jogo funcional

---

## 8. DOCUMENTAÇÃO

Atualizar a documentação principal e correlata para refletir que:

- o protagonista oficial atual é **Zeno**
- sua raça é **Humano**
- sua classe é **Guerreiro**
- seu talento racial é **Veterano de Batalha**
- seu equipamento inicial é **Espada de Ferro + Escudo de Ferro e Madeira**

Se o documento mestre anterior descrevia foco exclusivo em Brokk Anão Guerreiro, atualizar o texto para refletir o novo direcionamento atual do projeto.

Brokk pode permanecer citado como personagem/protótipo anterior, se isso ajudar a não perder histórico, mas o foco atual deve ser Zeno.

---

## 9. CAMPANHA E FLUXO PRINCIPAL

Preservar:
- a minicampanha atual
- salvamento
- recompensas
- IA
- combate
- dados
- interface
- cartas básicas permanentes
- habilidades dos inimigos
- Tripa Seca
- fogo amigo
- posicionamento inicial
- sons e efeitos existentes

A campanha continua funcionando, mas o personagem jogável principal agora deve ser Zeno.

---

## 10. TESTES

Executar todos os testes existentes e adicionar testes para:

1. Zeno aparece como protagonista principal
2. atributos de Zeno estão corretos
3. DES efetiva com escudo = +1
4. Espada de Ferro equipada corretamente
5. Veterano de Batalha — Defesa ativa apenas uma vez por combate
6. Veterano de Batalha — Dano ativa apenas uma vez por combate
7. bônus desaparecem ao final do combate
8. bônus aparecem na interface enquanto ativos
9. sons/efeitos de ativação funcionam
10. Mestre das Armas continua funcionando com Espada de Ferro
11. Muralha de Ferro continua funcionando
12. salvamento e carregamento preservam o estado correto de Zeno
13. campanha continua jogável do início ao fim
14. combate independente continua funcional
15. nenhuma regressão no sistema de cartas básicas
16. nenhuma regressão nos dados 3D
17. nenhuma regressão na IA e nos inimigos
18. nenhuma regressão nas habilidades de Tripa Seca

Executar também verificações com renderização real e interação real de mouse/teclado, não apenas testes lógicos.

---

## 11. ENTREGA

Ao concluir:
1. apresentar resumo das mudanças
2. listar arquivos criados e modificados
3. informar quantidade de testes e falhas
4. explicar como o talento Veterano de Batalha foi implementado
5. explicar como a substituição de Brokk por Zeno foi feita
6. apontar eventuais limitações ou itens visuais ainda provisórios
7. informar como testar no F6/F5

**IMPORTANTE:**
Não iniciar uma refatoração gigante desnecessária.
Preservar tudo o que já está estável e fazer uma transição segura para o novo protagonista oficial.