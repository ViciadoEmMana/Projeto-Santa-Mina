extends RefCounted
## Uma instância representa um combate. Não restaura habilidades durante turnos.

signal alterado

const Regras = preload("res://regras_combate.gd")
const Condicoes = preload("res://condicoes_combate.gd")

var condicoes := Condicoes.new()

var pv_maximos: int
var pv_atuais: int:
	set(valor):
		pv_atuais = clampi(valor, 0, pv_maximos)
		alterado.emit()

var muralha_usada := false
var mestre_armas_usado := false
# Integração para efeitos futuros. Quem aplicar uma fonte deve removê-la ao
# expirar; a resolução da rolagem não gasta PA nem consome habilidades.
var fontes_vantagem: Array[String] = []
var fontes_desvantagem: Array[String] = []
var ultimo_dado_inimigo := 0
var bonus_defesa_escudo := 0
var bonus_defesa_natural := 0
var bonus_defesa_temporaria := 0
var pa_maximos := Regras.PA_POR_TURNO
var pa_atuais := 0
var pa_penalidade_pendente := 0
var pa_debito_pendente := 0
var pa_debito_registrado := 0
var pa_debitado_neste_turno := 0


func _init(maximo: int) -> void:
	pv_maximos = maximo
	pv_atuais = maximo


func confirmar_mestre_armas() -> bool:
	if mestre_armas_usado:
		return false
	mestre_armas_usado = true
	alterado.emit()
	return true


func confirmar_muralha(dano_fisico: int, custo_pa: int) -> int:
	if muralha_usada or dano_fisico <= 0:
		return dano_fisico
	muralha_usada = true
	pa_debito_pendente += custo_pa
	alterado.emit()
	return floori(dano_fisico / 2.0)


func iniciar_turno() -> int:
	bonus_defesa_temporaria = 0
	pa_debitado_neste_turno = pa_debito_pendente
	pa_debito_registrado += pa_debito_pendente
	pa_atuais = maxi(0, pa_maximos - pa_debito_pendente - pa_penalidade_pendente - condicoes.iniciar_turno())
	pa_debito_pendente = 0
	pa_penalidade_pendente = 0
	alterado.emit()
	return pa_debitado_neste_turno


func gastar_pa(custo: int) -> bool:
	if custo < 0 or pa_atuais < custo:
		return false
	pa_atuais -= custo
	alterado.emit()
	return true


func defender() -> bool:
	if bonus_defesa_temporaria > 0 or not gastar_pa(Regras.CUSTOS["defender"]):
		return false
	bonus_defesa_temporaria = 2
	alterado.emit()
	return true


func registrar_dado_inimigo(natural: int) -> void:
	ultimo_dado_inimigo = natural
	alterado.emit()
