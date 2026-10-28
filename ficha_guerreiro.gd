extends RefCounted
## Regras compartilhadas do Guerreiro; identidade, raça e equipamento vêm da ficha.
const Regras = preload("res://regras_combate.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const NIVEL := 1
const CLASSE := {
	"nome": "Guerreiro", "pv_base": 11,
	"atributos": {"FOR": 2, "DES": 2, "CON": 2, "INT": 0, "SAB": 1, "CAR": 1},
}
const MURALHA_CUSTO_PA := 1
var escudo_equipado := true
var arma_equipada: Dictionary = {}
var modificadores_temporarios: Dictionary = {}
var _raca: Dictionary
var _equipamentos: Dictionary

func _init(raca: Dictionary, equipamentos: Dictionary) -> void:
	_raca = raca
	_equipamentos = equipamentos

func atributo(nome: String) -> int:
	return int(CLASSE["atributos"].get(nome, 0)) + int(_raca["atributos"].get(nome, 0))

func atributo_efetivo(nome: String) -> int:
	var equipamento := int(_equipamentos["escudo"]["modificadores"].get(nome, 0)) if escudo_equipado else 0
	return atributo(nome) + equipamento + int(modificadores_temporarios.get(nome, 0))

func bonus_arma(natural: int) -> int:
	return Equipamentos.bonus_dano(arma_atual(), natural, {"FOR": atributo_efetivo("FOR"), "DES": atributo_efetivo("DES")})

func arma_atual() -> Dictionary:
	return _equipamentos["arma"] if arma_equipada.is_empty() else arma_equipada

func atributo_ataque() -> int:
	return atributo_efetivo(arma_atual().get("atributo", "FOR"))

func pv_maximos() -> int:
	return int(CLASSE["pv_base"]) + atributo("CON")

func dado_ataque() -> int:
	return int(arma_atual()["dado"])

func dano_ataque(natural: int, defesa_alvo: int = 0) -> int:
	if natural <= 1 or natural > dado_ataque():
		return 0
	return int(Regras.ataque_fisico(natural, atributo_ataque(), {"alvo": defesa_alvo}, bonus_arma(natural))["dano"])

func bonus_escudo(natural_inimigo: int) -> int:
	if escudo_equipado and natural_inimigo in _equipamentos["escudo"]["naturais"]:
		return int(_equipamentos["escudo"]["defesa"])
	return 0

func bonus_pele_rocha(_pv_atuais: int) -> int:
	return 0

func regra_derrubado_por_proeza(_dado_arma: int) -> String:
	return "sem_regra_especial"

func talento_racial() -> String:
	return ""

func vantagem_desafio_forca(puramente_baseado_em_forca: bool) -> bool:
	return puramente_baseado_em_forca

func vantagem_resistencia_doenca() -> bool:
	return true

func recuperacao_permitida(descanso: String, comida: bool, fim_turno: bool) -> bool:
	return descanso in ["curto", "longo"] and comida and fim_turno
