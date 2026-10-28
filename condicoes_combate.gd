extends RefCounted
signal alterado
## Condições temporárias, sem regras de crítico ou testes de resistência inventados.

var derrubado := false
var penalidade_pendente := 0


func aplicar_derrubado(regra_resistencia: String = "sem_regra_especial") -> String:
	if regra_resistencia == "imune":
		return "imune"
	if regra_resistencia == "resistencia_com_vantagem":
		return "resistencia_pendente"
	derrubado = true
	penalidade_pendente += 1
	alterado.emit()
	return "aplicado"


func iniciar_turno() -> int:
	var penalidade := penalidade_pendente
	penalidade_pendente = 0
	# Provisório: após cobrar cada aplicação uma vez, a condição termina.
	derrubado = false
	if penalidade > 0:
		alterado.emit()
	return penalidade
