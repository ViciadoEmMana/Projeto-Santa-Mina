extends "res://ficha_guerreiro.gd"
## Protagonista oficial. As escolhas de atributos humanos já estão fixadas.
const ID := "zeno"
const NOME := "Zeno"
const RACA := {
	"nome": "Humano", "epiteto": "O Versátil", "atributos": {"FOR": 1, "CON": 1},
	"passiva": "Talento Universal", "talento": "Veterano de Batalha",
}
const EQUIPAMENTOS := {
	"arma": Equipamentos.ESPADA_FERRO, "escudo": Equipamentos.ESCUDO_FERRO_MADEIRA,
}

func _init() -> void:
	super(RACA, EQUIPAMENTOS)

func talento_racial() -> String:
	return RACA["talento"]
