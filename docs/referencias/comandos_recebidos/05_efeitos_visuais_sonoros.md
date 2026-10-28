# SANTA MINA — EFEITOS VISUAIS E SONOROS DE COMBATE

Atualize o projeto existente em Godot 4, mantendo todas as regras, personagens, equipamentos, cenas e testes já funcionais.

Objetivo: adicionar feedback audiovisual aos ataques e bloqueios, tornando o combate mais expressivo sem alterar as mecânicas.

Antes de modificar arquivos, examine como os ataques, dados 3D, cálculos de Defesa, animações e eventos de combate estão implementados.

## 1. EFEITO DE BLOQUEIO DO ESCUDO

Quando o Escudo de Madeira e Ferro de Brokk ativar seu bônus de Defesa contra resultado natural 2 ou 3:

- Reproduzir um som curto de impacto metálico, como uma arma batendo em um escudo.
- Mostrar pequenas faíscas ou partículas no escudo.
- Aplicar uma vibração breve ao escudo, sem deslocar Brokk de sua casa.
- Exibir um texto flutuante discreto: "BLOQUEIO! −2 DEFESA DE DANO", ou preferencialmente "ESCUDO! −2 DANO".
- Sincronizar o efeito com o momento em que o ataque é resolvido.

Não ativar esse efeito apenas porque Brokk possui o escudo equipado. O bônus de Defesa condicional precisa realmente ter sido aplicado.

Não alterar a regra de Defesa ou o dano final.

## 2. ATAQUES FORTES COM RESULTADO NATURAL 5 OU 6

Para armas com dado de dano 1d6, resultados naturais 5 ou 6 devem ativar um efeito audiovisual de ataque forte.

Esses efeitos são somente visuais e sonoros:
- Não concedem dano extra.
- Não ignoram Defesa.
- Não ativam críticos.
- Não modificam PA.
- Não aplicam condições adicionais.

Preservar todos os efeitos especiais das armas que já existem.

A referência deve ser o dado natural selecionado pela mecânica de Vantagem ou Desvantagem, e não o resultado total com atributos.

Em uma rolagem de dois dados, usar apenas o dado selecionado pelas regras para determinar se o efeito forte será ativado.

Não ativar efeitos de acerto no caso de erro automático ou ataque inválido.

## 3. IDENTIDADE AUDIOVISUAL POR ARMA

**Machado de Ferro e armas cortantes**
- Resultado natural 5 ou 6: efeito de corte forte.
- Criar um arco luminoso rápido atravessando visualmente o alvo.
- Reproduzir som de lâmina cortando e atingindo.
- Pequena reação visual do alvo.

**Porrete e armas contundentes**
- Resultado natural 5 ou 6: efeito de pancada forte.
- Criar um impacto curto com partículas de poeira.
- Reproduzir som grave e seco de madeira batendo.
- Pequena vibração do alvo.
- No 6 natural, preservar a tentativa de Derrubado e a imunidade do Brokk.

**Arco Curto e outras armas à distância**
- Reproduzir um som curto de disparo de arco em ataques normais.
- Mostrar uma flecha simples viajando do atacante até o alvo.
- No resultado natural 5 ou 6, acrescentar rastro mais intenso, impacto visual e som diferenciado de flecha atingindo.
- Preservar a Desvantagem do Arco Curto quando houver inimigo adjacente ortogonalmente.

Preparar categorias reutilizáveis para outras armas futuras:
- Cortante.
- Perfurante.
- Contundente.
- Projétil.

Cada categoria deve poder ter seu próprio conjunto de sons e efeitos.

## 4. IMPLEMENTAÇÃO DE ÁUDIO

Preferir arquivos de áudio locais e livres de direitos de uso, caso já existam no projeto.

Se não houver arquivos adequados:
- Criar efeitos sonoros simples por síntese ou geração programática, quando viável no ambiente disponível.
- Não depender de URLs externas em tempo de execução.
- Evitar bibliotecas adicionais desnecessárias.
- Organizar os recursos de áudio em uma pasta específica, por exemplo `res://audio/combate/`.

Usar AudioStreamPlayer ou AudioStreamPlayer2D conforme a arquitetura existente.

Separar os sons de:
- Bloqueio de escudo.
- Corte normal e corte forte.
- Pancada normal e pancada forte.
- Disparo de arco e impacto de flecha.

Os sons devem ser curtos, claros e não excessivamente altos. Evitar reprodução duplicada do mesmo efeito.

## 5. IMPLEMENTAÇÃO VISUAL

Preferir efeitos nativos do Godot, como:
- GPUParticles2D ou CPUParticles2D.
- Line2D.
- Polygon2D.
- Tween.
- Label flutuante.
- Pequenas animações de escala, cor e posição.

Não exigir novas imagens externas.

Preservar os sprites atuais, o tabuleiro 3×6 e os dados 3D.

Evitar que efeitos visuais bloqueiem cliques ou interfiram na seleção dos inimigos.

Não alterar a posição lógica dos personagens.

## 6. SINCRONIZAÇÃO

Os efeitos devem acontecer em uma sequência compreensível:

1. Personagem realiza o ataque.
2. Dado 3D apresenta o resultado.
3. Arma executa animação e som.
4. Impacto, Defesa e efeitos especiais aparecem.
5. PV e mensagens são atualizados.

Não mostrar efeitos de impacto antes de o dado terminar sua animação.

Evitar travar os controles durante períodos longos. Respeitar o fluxo de turnos existente.

## 7. TESTES E VALIDAÇÃO

Adicionar testes para verificar:
- Escudo ativa feedback somente quando sua Defesa condicional é aplicada.
- Resultado natural 5 ou 6 ativa o efeito forte da categoria correta.
- Resultados 2, 3 e 4 não ativam efeito forte.
- Resultado natural 1 continua sendo erro automático.
- Vantagem e Desvantagem usam o resultado selecionado.
- Ataques inválidos não reproduzem efeitos de acerto.
- Efeitos audiovisuais não modificam dano, PA, Defesa ou condições.
- Machado mantém bônus de +2 no 6 natural.
- Porrete mantém Derrubado e Firmeza de Rocha permanece funcionando.
- Arco mantém seu alcance e Desvantagem de proximidade.
- Três personagens continuam funcionando corretamente.
- Vitória e derrota permanecem corretas.
- Os testes anteriores continuam passando.

Executar Godot headless e informar o número de verificações, falhas e arquivos modificados.

Ao concluir, informar quais sons foram realmente implementados e como foram produzidos. Não afirmar que há áudio se apenas os eventos ou funções de reprodução foram criados.

Fornecer também um roteiro breve para testar os efeitos com F6.

**Prioridade:** melhorar a apresentação audiovisual preservando integralmente o combate estável.