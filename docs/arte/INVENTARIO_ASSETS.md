# Inventário e plano de substituição — etapa 1

> Estado de 23/10/2026: [apresentação original integrada](ENTREGA_VISUAL_01.md).
> Sete inimigos, quatro ambientes, cinco ilustrações de cartas e reações do chefe.

| Grupo | Material existente | Destino planejado | Estado |
| --- | --- | --- | --- |
| Zeno | Humano, espada/escudo, metal/tecido verde | assets/characters/zeno/ | Protagonista atual, sete animações provisórias de oito quadros; sem referência oficial anexada |
| Brokk | Sprite original integrado | `assets/characters/brokk/` | Sete animações integradas: idle, machado, caminhada, corrida, defesa, dano, morte |
| Bandido arqueiro | Humano original revisado | `assets/enemies/bandits/arqueiro/` | Idle, caminhada, disparo, dano e morte integrados |
| Bandido porrete | Humano original com porrete de uma mão | `assets/enemies/bandits/porrete/` | Cinco animações integradas |
| Goblin Porrete | Goblin original com clava | `assets/enemies/goblins/goblin_porrete/` | Cinco animações integradas |
| Goblin Sucata | Goblin original com gancho e tampa | `assets/enemies/goblins/goblin_sucata/` | Cinco animações integradas; Defesa 2 preservada |
| Goblin Tiro Certo | Goblin original encapuzado com arco | `assets/enemies/goblins/goblin_tiro/` | Cinco animações integradas |
| Goblin Faca Cega | Goblin original com duas facas | `assets/enemies/goblins/goblin_faca/` | Cinco animações integradas; Passo Ágil preservado |
| Tripa Seca | Chefe original com espada e escudo | `assets/enemies/tripa_seca/` | Cinco animações e gesto de reação integrados |
| Covil/mina | Fundo original, piso, props e luz | `assets/environments/covil/` | Camadas integradas |
| Estrada/floresta | Dois fundos originais e pisos próprios | `assets/environments/estrada/`, `floresta/` | Integrados aos capítulos I e II |
| Passagem/caverna | Fundo original e piso rochoso | `assets/environments/passagem/` | Integrado ao capítulo III |
| Cartas | Cinco ilustrações originais e molduras existentes | `assets/cards/` | Integradas; geometria e custos preservados |
| VFX | Nós e tweens nativos próprios | `efeitos_combate.gd` | Impactos preservados, areia e protetor integrados ao gesto |
| Dados | Seis sólidos procedurais reais | Componentes atuais | Preservar; não precisam de sprites substitutos |
| Áudio | Oito impactos e seis sons adicionais próprios | `audio/combate/`, `audio/ambiente/` | Passos, carta, dados e ambientes integrados |

O material externo não será usado como referência ou entrada de geração.
Pastas futuras acima são um plano, não indicação de assets já entregues.
As versões 0.4.0/0.5.0 do pacote legado não devem ser apagadas enquanto a cena
funcional ainda depender delas. Substituição deverá trocar as referências de
forma verificável antes de qualquer decisão de limpeza.

## Registro de produção

Para cada asset novo, registrar: identificador, caminho, versão, autoria/método,
origem, transparência, dimensões, pivô, quadros/animações, estado de aprovação e
cena consumidora. Conceito não recebe estado de sprite pronto.

Brokk com sete animações foi integrado na entrega anterior:
[BROKK_ANIMADO_V02.md](BROKK_ANIMADO_V02.md). A entrega atual acrescenta quatro
ambientes com fundos e pisos próprios, props, cartas e o elenco inimigo completo.

Primeiro inimigo original: [Bandido Arqueiro](ARQUEIRO_ANIMADO_V01.md), com
proporções humanas revistas a pedido do usuário. A entrega de 23/10 conclui a
substituição dos sete inimigos no combate e na campanha. Fontes e rascunhos
antigos permanecem no disco, mas `Combate.tscn` não carrega mais 32rogues.
