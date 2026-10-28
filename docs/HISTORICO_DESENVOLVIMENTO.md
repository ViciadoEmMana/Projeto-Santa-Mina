# Santa Mina — histórico consolidado do desenvolvimento

Registro preparado em 28/10/2026 a partir deste chat, dos arquivos do projeto e
dos relatórios existentes. É um resumo das decisões e entregas, não uma
transcrição integral da conversa nem uma reconstrução de commits que não existiam.

## Evolução

1. **Projeto inicial Godot 2D:** cena principal simples e tabuleiro 3×6.
2. **Combate separado:** cena Combate.tscn, herói à esquerda, inimigo à direita,
   ataque, PV, dano e registro de resultados. O tabuleiro original foi preservado.
3. **Dados e iniciativa:** animação 3D, visibilidade apenas durante as rolagens,
   dados azuis/vermelhos, d20 de iniciativa, desempates e turnos alternados.
4. **Ficha e estado:** atributos de classe/raça, equipamento, escudo e usos de
   habilidades separados; Mestre das Armas, Muralha de Ferro e passivas preparadas.
5. **Combate tático:** PA individuais, movimento/corrida, alcance, Vantagem e
   Desvantagem, armas, segundo inimigo, Derrubado e efeitos audiovisuais.
6. **Minicampanha:** quatro capítulos de O Covil de Tripa Seca; inventário,
   alimentos, descansos, recompensas e progressão.
7. **IA e chefe:** ataque priorizado quando válido, Defesa 2 de Goblin Sucata,
   Passo Ágil de Faca Cega, Golpe Sujo e Me Protejam! de Tripa Seca.
8. **Cartas e interação:** cinco ações básicas permanentes em cartas verticais;
   seleção/cancelamento, posicionamento por iniciativa, fogo amigo e seis
   sólidos 3D. Corrigido o bloqueio de cliques após a iniciativa.
9. **Direção artística própria:** Brokk e sete inimigos animados, quatro
   ambientes, cartas, áudio e efeitos; os assets atuais não usam 32rogues.
10. **Salvamento:** slot local manual, backup, validação e retomada entre
    confrontos, sem renovar arbitrariamente recursos ou habilidades.
11. **Interface ampliada:** removidos os quadros superiores permanentes;
    inspeção por hover/seleção, PV sobre os personagens e tabuleiro visual 50%
    maior, conservando suas 18 casas e sua geometria lógica.
12. **Faca Cega:** dois golpes de d4 em uma ação de 3 PA; cada 1 erra somente seu
    golpe; naturais 2/3 ativam um único +2 de escudo, sem acumular.
13. **Zeno — 24/10/2026:** protagonista principal passa a Humano Guerreiro,
    espada/escudo, 14 PV e 5 PA. Veterano de Batalha, nova arte provisória,
    preservação de Brokk como legado e migração dos saves v1 para v2.
14. **GitHub — 28/10/2026:** consolidação do projeto Godot, materiais do chat e
    documentação com o protótipo web que já existia no repositório privado.

## Decisões que continuam valendo

- Godot 4 e GDScript; não recriar nem substituir o projeto funcional.
- Preservar o tabuleiro original e o combate independente.
- Apenas Zeno, Humano Guerreiro, como protagonista atual; sem seletores fictícios.
- Não inventar críticos, custos, cartas especiais ou regras de progressão.
- Atributos de Zeno: FOR 3, DES 2, CON 3, INT 0, SAB 1, CAR 1.
- Escudo inicial impõe −1 DES: iniciativa usa DES efetiva 1.
- Veterano ofensivo vale já no ataque cujo natural final >= 5 ativa o talento.
- Mestre com Vantagem repete somente o maior resultado; a substituição é obrigatória.
- Preservar usos de classe e recuperação por descanso conforme sistema existente.
- Direção visual própria, inspirada em qualidades gerais de Songs of Conquest;
  não copiar assets comerciais. A referência complementar de criaturas não
  representa licença ou incorporação de um pacote externo.

## Validações históricas

Os números abaixo pertencem às entregas registradas; não são novas execuções
realizadas para a publicação no GitHub.

- Interface ampliada: 5.049 verificações automatizadas + 53 de captura, zero falhas.
- Ajuste Faca Cega: 5.872 automatizadas + 10 de captura, zero falhas.
- Transição para Zeno: **6.452 automatizadas + 20 renderizadas, zero falhas finais**.

Para comandos, arquivos e limites de cada etapa, consulte os relatórios na raiz,
docs/ATUALIZACAO_ZENO.md e docs/arte/.

## Pendências registradas

Imagem oficial de Zeno; elegibilidade do escudo automático para Veterano;
esquiva completa; cartas especiais; exploração livre e história principal final.
Ver os limites atuais no README e no relatório de Zeno.

## Sobre o histórico Git

O material local anterior não tinha commits Git. Ele será registrado como uma
importação consolidada sobre o histórico já existente no GitHub. Os comandos e
relatórios preservam a evolução documentada sem inventar uma sequência de commits
retroativos.
