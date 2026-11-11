# Santa Mina — mapa de exploração e viagens (protótipo)

## Decisões aprovadas — 11/11/2026
- Mapa ilustrado de Santa Mina é a referência visual oficial para exploração.
- Jogador escolhe a localidade de destino e a rota pelas estradas.
- Personagem deve aparecer como **miniatura caminhando visualmente**, avançando ponto a ponto pela estrada, sem teletransporte.
- O tempo do mundo deve avançar durante a jornada; deslocamento pode futuramente ser interrompido por eventos, emboscadas, descanso, clima e missões.
- **Regra oficial de calibração:** Santa Mina → Forja Nova: **6 dias a pé** ou **3 dias de carroça**, nas condições médias de viagem.
- Tempos das outras localidades são **estimativas provisórias**, proporcionais ao comprimento de cada trajeto desenhado; não são ainda números canônicos.
- Trilhas estreitas, florestas e montanhas poderão futuramente impedir a passagem de carroças.

## Implementação inicial no repositório
`html5/principal/mapa-viagens.js` implementa um módulo independente com:
- 19 localidades e coordenadas do mapa original (1364 × 1119);
- conexões e pontos intermediários das estradas, sujeitos a revisão;
- menor caminho na malha de estradas (algoritmo de Dijkstra);
- calibração de dias por meio de transporte;
- interpolação da posição da miniatura nos trechos;
- API `SantaMinaViagens.rota`, `.dias`, `.iniciarViagem`, `.avancar`.

Exemplo (depois de incluir o script no HTML):
```js
const viagem = SantaMinaViagens.iniciarViagem("santa", "forja_nova", "carroca");
console.assert(viagem.dias === 3);
const passo = SantaMinaViagens.avancar(viagem, 0.25);
// passo.posicao.x / .y: coordenadas onde desenhar a miniatura
```

## Integração pendente — não considerar como jogo publicado
A versão HTML independente aprovada na conversa já foi testada pelo usuário, mas **seu arquivo completo e a imagem incorporada ainda não estão incluídos nesta branch**. É necessário adicionar o mapa original autorizado como recurso do jogo ou embuti-lo, integrar o módulo na tela de exploração de `html5/principal/index.html` e conferir a compatibilidade com combate e interface da colaboradora.

Não mudar a URL pública `https://viciadoemmana.github.io/Projeto-Santa-Mina/`. O HTML principal só deve mudar com teste, revisão e merge. Não assumir que este módulo isolado altera a versão pública.

## Próximas etapas
1. Integrar a ilustração do mapa e a miniatura na tela de exploração.
2. Revisar os trajetos visuais para acompanhar as estradas da arte e ajustar tempos entre cidades e vilas.
3. Adicionar eventos de viagem, encontros, emboscadas, repouso e consumo de recursos.
4. Ligar entradas de masmorras ao combate tático; manter comércio regional e consequências das escoltas.
5. Confirmar salvamento e restauração de posição, destino, calendário e progresso ao interromper jornadas.
