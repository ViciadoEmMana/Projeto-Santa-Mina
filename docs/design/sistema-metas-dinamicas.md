# Santa Mina — Sistema de Metas Dinâmicas

Status: regras conceituais aprovadas; números e balanceamento pendentes.
Atualizado em 2026-11-16.

## Objetivo
Oferecer objetivos ocasionais e progressivos que incentivem o desenvolvimento da companhia sem substituir a história principal opcional, as campanhas independentes ou a exploração livre.

## Regras aprovadas
1. Apenas **uma meta ativa por vez**.
2. Metas **surgem ocasionalmente**, não necessariamente assim que a anterior termina.
3. Metas iniciais são simples e têm recompensas menores. Com o avanço da companhia, **dificuldade e recompensas aumentam**.
4. O gerador adapta as metas ao contexto, atividades e intenção do jogador: exploração de minas, conquista de fortes/cidades/vilas, saques marítimos e outros estilos.
5. O sistema busca **variedade** entre jogatinas e evita repetir sempre a mesma sequência.
6. O objetivo pode ser alcançado por **compra, fabricação, roubo, descoberta, recompensa recebida** ou outro meio válido, conforme o requisito. O sistema verifica o resultado, não impõe uma única solução.
7. Cada meta possui **prazo**. Durante o prazo, não pode ser livremente descartada para trocar por outra.
8. Se o prazo acabar sem sucesso, fica disponível a **opção de cancelar** a meta.
9. **Penalidade de cancelamento:** apenas uma **pequena espera** até que uma nova meta possa aparecer. Sem perda de ouro ou XP definida.
10. Ao iniciar uma **nova jogatina/companhia do zero**, a progressão das metas **reinicia**. Isso não apaga as crônicas e consequências do mundo persistente.
11. As metas são **paralelas à campanha principal** e não obrigam o jogador a segui-la.

## Exemplos ilustrativos (não fixados)
- Recrutar dois aventureiros e formar uma guilda.
- Conseguir equipamentos de qualidade excelente por qualquer meio válido.
- Explorar uma mina e encontrar recursos, caso o jogador esteja buscando mineração.
- Reunir recursos para um cerco quando o jogador estiver planejando conquistar uma fortaleza.
- Obter informações ou equipamentos úteis a uma incursão marítima.

## Fluxo proposto
Sem meta ativa → aguardar oportunidade contextual → apresentar meta com prazo e recompensa → acompanhar progresso.
- Sucesso dentro do prazo: entregar recompensa, registrar conclusão e voltar à espera por oportunidade futura.
- Prazo expirado sem conclusão: habilitar cancelamento; se cancelada, iniciar curta espera de penalidade; após espera, voltar à elegibilidade para nova meta.

## Pendências de design
- Duração dos prazos e da pequena espera de cancelamento.
- Fórmulas de progressão, categorias de recompensas e critérios de elegibilidade.
- Frequência de oferta e mecanismos antirrepetição.
- Interface e mensagens de prazo expirado.
- Tratamento de objetivos impossibilitados por mudanças no mundo.

Este documento registra **design aprovado**, não afirma que o sistema já foi implementado no código do jogo.
