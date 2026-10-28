extends "res://ficha_guerreiro.gd"
## Protótipo anterior, preservado para testes e cenas legadas.
const ID := "brokk"
const NOME := "Brokk Pedraférrea"
const RACA := {"nome": "Anão", "atributos": {"FOR": 1, "CON": 1}}
const EQUIPAMENTOS := {"arma": Equipamentos.MACHADO_FERRO, "escudo": Equipamentos.ESCUDO_MADEIRA_FERRO}

func _init() -> void:
	super(RACA, EQUIPAMENTOS)

func bonus_pele_rocha(pv_atuais: int) -> int:
	return 1 if pv_atuais * 2 > pv_maximos() else 0

func regra_derrubado_por_proeza(dado_arma: int) -> String:
	match dado_arma:
		6, 8:
			return "imune"
		10, 12:
			return "resistencia_com_vantagem"
		_:
			return "sem_regra_especial"
