# Santa Mina — mapa de exploração e viagens (protótipo)

## Atualização de regras — 13/11/2026
- **Carroças:** circulam exclusivamente sobre as estradas/caminhos oficiais desenhados no mapa; a navegação utiliza a malha conectada.
- **A pé:** os personagens podem explorar livremente qualquer ponto do mapa, inclusive fora das estradas. O jogador pode indicar destinos por coordenadas e adicionar pontos de passagem.
- A rota livre inicial é em linha reta entre os pontos escolhidos. Terrenos, rios e montanhas **ainda não causam bloqueio nem penalidades** na implementação: futuros desafios/eventos serão definidos em outra etapa.
- **Referência preservada:** Santa Mina → Forja Nova = 6 dias a pé por percurso livre de referência; = 3 dias de carroça pela malha de estradas. Outras durações continuam provisórias.
- A miniatura deve percorrer visualmente a rota correspondente ao transporte selecionado.

## Decisões aprovadas — 11/11/2026
- Mapa ilustrado de Santa Mina é a referência visual oficial para exploração.
- Jogador escolhe a localidade de destino; estradas são obrigatórias somente para carroças (regra revisada em 13/11).
- Personagem deve aparecer como **miniatura se deslocando visualmente**, acompanhando o trajeto escolhido, sem teletransporte.
- O tempo do mundo deve avançar durante a jornada; deslocamento pode futuramente ser interrompido por eventos, emboscadas, descanso, clima e missões.
- **Regra oficial de calibração:** Santa Mina → Forja Nova: **6 dias a pé** ou **3 dias de carroça**, nas condições médias de viagem.
- Tempos das outras localidades são **estimativas provisórias**, calculadas pelo comprimento do trajeto a pé ou da estrada para carroça; não são ainda números canônicos.
- Trilhas estreitas, florestas e montanhas poderão futuramente impedir a passagem de carroças.

## Implementação inicial no repositório
`html5/principal/mapa-viagens.js` implementa um módulo independente com:
- 19 localidades e coordenadas do mapa original (1364 × 1119);
- conexões e pontos intermediários das estradas, sujeitos a revisão;
- menor caminho na malha de estradas (algoritmo de Dijkstra), somente para carroças;\n- trajetórias livres a pé entre coordenadas arbitrárias, com pontos intermediários opcionais;
- calibração de dias por meio de transporte;
- interpolação da posição da miniatura nos trechos;
- API `SantaMinaViagens.rota`, `.dias`, `.iniciarViagem`, `.avancar`.

Exemplo (depois de incluir o script no HTML):
```js
const viagem = SantaMinaViagens.iniciarViagem("santa", "forja_nova", "carroca");
console.assert(viagem.dias === 3);
const passo = SantaMinaViagens.avancar(viagem, 0.25);
const pe = SantaMinaViagens.iniciarViagem("santa","forja_nova","pe");
console.assert(pe.dias === 6);
const exploracao = SantaMinaViagens.iniciarViagem("santa", {x:450,y:750}, "pe", [{x:600,y:500}]);
// passo.posicao.x / .y: coordenadas onde desenhar a miniatura
```

## Integração pendente — não considerar como jogo publicado
A versão HTML independente aprovada na conversa já foi testada pelo usuário, mas **seu arquivo completo e a imagem incorporada ainda não estão incluídos nesta branch**. É necessário adicionar o mapa original autorizado como recurso do jogo ou embuti-lo, integrar o módulo na tela de exploração de `html5/principal/index.html` e conferir a compatibilidade com combate e interface da colaboradora.

Não mudar a URL pública `https://viciadoemmana.github.io/Projeto-Santa-Mina/`. O HTML principal só deve mudar com teste, revisão e merge. Não assumir que este módulo isolado altera a versão pública.

## Próximas etapas
1. Integrar a ilustração do mapa e a miniatura na tela de exploração.
2. Revisar os trajetos das carroças para acompanhar as estradas da arte e ajustar tempos entre cidades e vilas; permitir exploração a pé por clique livre no mapa.
3. Adicionar eventos de viagem, encontros, emboscadas, repouso e consumo de recursos.
4. Ligar entradas de masmorras ao combate tático; manter comércio regional e consequências das escoltas.
5. Confirmar salvamento e restauração de posição, destino, calendário e progresso ao interromper jornadas.
