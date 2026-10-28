extends "res://scripts/presentation/inimigo_visual.gd"
## Configuração visual do humano; o comportamento comum fica no componente base.
const QUADROS = preload("res://assets/enemies/bandits/porrete/porrete_animacoes.tres")
const ESCALA_ACOES := 0.185
const ESCALA_ATAQUE := 0.178
const ESCALA_REACOES := 0.206

func _init() -> void:
	quadros = QUADROS
	identidade_visual = &"porrete_original"
