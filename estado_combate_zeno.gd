extends "res://estado_combate_brokk.gd"
## Habilidades de classe herdadas; talento e arma têm seus próprios limites.
var combate_ativo := false
var veterano_defesa_ativado := false
var veterano_dano_ativado := false
var espada_repeticao_usada := false
var bonus_veterano_defesa: int:
	get: return 1 if combate_ativo and veterano_defesa_ativado else 0
var bonus_veterano_dano: int:
	get: return 1 if combate_ativo and veterano_dano_ativado else 0

func _init(maximo: int = 14) -> void:
	super(maximo)

func iniciar_combate() -> void:
	combate_ativo = true
	veterano_defesa_ativado = false
	veterano_dano_ativado = false
	espada_repeticao_usada = false
	alterado.emit()

func encerrar_combate() -> void:
	combate_ativo = false
	alterado.emit()

func registrar_ataque(natural: int, faces: int) -> bool:
	if not combate_ativo or veterano_dano_ativado or natural < 5 or natural > faces:
		return false
	veterano_dano_ativado = true
	alterado.emit()
	return true

func registrar_defesa(dano_resolvido: int, defendeu: bool, esquivou: bool = false) -> bool:
	if not combate_ativo or veterano_defesa_ativado or dano_resolvido != 0 or not (defendeu or esquivou):
		return false
	veterano_defesa_ativado = true
	alterado.emit()
	return true

func confirmar_repeticao_espada() -> bool:
	if not combate_ativo or espada_repeticao_usada:
		return false
	espada_repeticao_usada = true
	alterado.emit()
	return true
