extends RefCounted
## Só apresentação. Custos e execução continuam em regras_combate/combate.
const ARTES = {
	"atacar": preload("res://assets/cards/atacar.tres"),
	"defender": preload("res://assets/cards/defender.tres"),
	"mover": preload("res://assets/cards/mover.tres"),
	"correr": preload("res://assets/cards/correr.tres"),
	"vantagem": preload("res://assets/cards/vantagem.tres"),
}
const CARTAS := [
	{"id": "atacar", "cor": "7f3d36", "efeito": "Arma equipada.\nDado + atributo.\nRespeita Defesa.", "nome": "Ataque", "descricao": "Selecione um inimigo em alcance e confirme clicando nele. Usa a arma equipada, atributos, Defesa e condições."},
	{"id": "defender", "cor": "526774", "efeito": "+2 Defesa até o\ninício do seu\npróximo turno.", "nome": "Defender", "descricao": "+2 Defesa até o início do próximo turno. Usa a defesa existente, sem alterar escudo ou Defesa natural."},
	{"id": "mover", "cor": "556443", "efeito": "Mova 1 casa.\nCaminho ortogonal\nlivre.", "nome": "Mover", "descricao": "Selecione uma casa ortogonal livre. Respeita obstáculos, ocupação e efeitos de movimento existentes. Esc cancela sem custo."},
	{"id": "correr", "cor": "936b3a", "efeito": "Mova até 2 casas.\nCaminho ortogonal\nlivre.", "nome": "Correr", "descricao": "Selecione um destino a até duas casas por caminho ortogonal livre. Preserva efeitos de movimento existentes. Esc cancela sem custo."},
	{"id": "vantagem", "cor": "99733d", "efeito": "Maior de 2 dados.\nFontes opostas\nse anulam.", "nome": "Ataque com Vantagem", "descricao": "Selecione um inimigo em alcance. Vantagem efetiva usa o maior de dois dados; fontes opostas se anulam. Custa 5 PA mesmo quando a Vantagem é anulada. Sem dano extra ou críticos."},
]
