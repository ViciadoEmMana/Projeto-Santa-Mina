extends RefCounted
signal alterado
## Ficha e estado independentes para cada inimigo deste protótipo.

const Condicoes = preload("res://condicoes_combate.gd")
const Regras = preload("res://regras_combate.gd")

var nome: String
var pv_maximos: int
var pv_atuais: int:
	set(valor):
		pv_atuais = clampi(valor, 0, pv_maximos)
		alterado.emit()
var forca: int
var destreza: int
var defesa := 0
var pa_maximos := 3
var bonus_ataque := 0
var tipo := "Humanoide"
var nivel := 1
var categoria := "comum"
var ficha_id := ""
var pendencias: Array[String] = []
var habilidades: Dictionary = {}
var passo_agil_rodada := -1
var golpe_sujo_usado := false
var fileira_preferida := 2
var arma: Dictionary
var pa_atuais := 0:
	set(valor):
		pa_atuais = valor
		alterado.emit()
var pa_debito_pendente := 0
var iniciativa_natural := 0
var iniciativa_total := 0
var condicoes := Condicoes.new()
var fontes_vantagem: Array[String] = []
var fontes_desvantagem: Array[String] = []


func _init(titulo: String, pv: int, for_total: int, des_total: int, equipamento: Dictionary, maximo_pa: int = 3) -> void:
	nome = titulo
	pv_maximos = pv
	pv_atuais = pv
	forca = for_total
	destreza = des_total
	arma = equipamento
	pa_maximos = maximo_pa
	bonus_ataque = des_total if equipamento.get("atributo", "FOR") == "DES" else for_total


func iniciar_turno() -> void:
	pa_atuais = maxi(0, pa_maximos - pa_debito_pendente - condicoes.iniciar_turno())
	pa_debito_pendente = 0


func gastar_pa(custo: int) -> bool:
	if custo < 0 or pa_atuais < custo or pv_atuais <= 0:
		return false
	pa_atuais -= custo
	return true


func pode_usar_golpe_sujo(arma_atacante: Dictionary) -> bool:
	return pv_atuais > 0 and not golpe_sujo_usado and habilidades.get("golpe_sujo", {}).get("ativo", false) and arma_atacante.get("tipo", "") == "corpo_a_corpo"


func consumir_golpe_sujo() -> void:
	golpe_sujo_usado = true
	alterado.emit()
