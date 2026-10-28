extends RefCounted
const TITULO := "SANTA MINA: O COVIL DE TRIPA SECA"
const CAPITULOS := [
	{"titulo": "I — O CARREGAMENTO DESAPARECIDO", "local": "Estrada", "preparacao": "Estrada", "inimigos": ["bandido_arqueiro", "bandido_porrete"],
	 "intro": "A carroça de mantimentos de Santa Mina sumiu na estrada. Zeno encontra dois bandidos saqueando a carga.\n\nZeno: ‘Larguem as provisões. A fome já deixou o povo mal-humorado; eu cheguei assim mesmo.’",
	 "vitoria": "Nos bolsos dos saqueadores, Zeno encontra ordens assinadas por Tripa Seca. O caminho segue pela mata. Há um Acampamento Protegido onde organizar as provisões antes da viagem."},
	{"titulo": "II — RASTROS NA MATA", "local": "Floresta", "preparacao": "Acampamento Protegido", "inimigos": ["goblin_porrete", "goblin_sucata"],
	 "intro": "Pegadas e marcas de roda levam a um acampamento improvisado. Dois goblins desmontam os suprimentos roubados. Um deles parece considerar uma tampa de panela uma armadura de gala.",
	 "vitoria": "Entre a sucata aparece um mapa rudimentar. Uma seta torta aponta para uma entrada escondida nas rochas. Zeno segue as marcas; o desenho do goblin não ajuda muito."},
	{"titulo": "III — A PASSAGEM DOS COVARDES", "local": "Entrada da Caverna", "preparacao": "Entrada da Caverna", "inimigos": ["goblin_tiro", "goblin_faca"],
	 "intro": "Na entrada da caverna, um goblin arma seu arco podre. Outro empunha duas facas cegas e pula de uma pedra para outra.\n\nPasso Ágil permite ao segundo mover uma casa sem PA uma vez por rodada; seu ataque continua custando 3 PA.",
	 "vitoria": "Os vigias caíram. Uma passagem estreita conduz ao interior da dungeon. Lá dentro, não há lugar seguro para um Descanso Longo."},
	{"titulo": "IV — O COVIL DE TRIPA SECA", "local": "Covil de Tripa Seca", "preparacao": "Interior da Dungeon", "inimigos": ["tripa_seca", "goblin_porrete", "goblin_sucata"],
	 "intro": "Tripa Seca reina sobre caixas roubadas, cercado de capangas.\n\nTripa Seca: ‘Quem deixou esse guerreiro entrar aqui? Eu mandei vigiar a entrada!’\nZeno: ‘Vim buscar os mantimentos de Santa Mina. E acho que vou levar sua espada também.’\nTripa Seca: ‘Me protejam, seus imprestáveis!’\n\nTripa Seca luta sujo e usa seus capangas como proteção.",
	 "vitoria": "Tripa Seca e seus capangas foram derrotados. Zeno recupera os mantimentos e volta a Santa Mina. A taverna prepara a mesa; desta vez, ninguém vai servir o jantar em uma tampa de ferro."},
]
