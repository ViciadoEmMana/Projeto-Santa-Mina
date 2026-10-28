extends Sprite2D
## Apresentação exclusiva do Bandido Arqueiro. Não conhece PV, PA ou RNG.
signal soltura
signal morte_finalizada
const QUADROS = preload("res://assets/enemies/bandits/arqueiro/arqueiro_animacoes.tres")
var animacao: AnimatedSprite2D
var vivo := true
var em_disparo := false
var em_movimento := false
var morte_em_andamento := false
var reproducoes: Dictionary = {}

func _ready() -> void:
	set_meta("arqueiro_original", true)
	texture = null
	region_enabled = false
	scale = Vector2.ONE
	flip_h = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sombra := Polygon2D.new()
	sombra.color = Color(0.02, 0.03, 0.04, 0.4)
	var contorno := PackedVector2Array()
	for i in range(16):
		var angulo := TAU * i / 16.0
		contorno.append(Vector2(cos(angulo) * 21, 29 + sin(angulo) * 4))
	sombra.polygon = contorno
	add_child(sombra)
	animacao = AnimatedSprite2D.new()
	animacao.name = "AnimacaoArqueiro"
	animacao.sprite_frames = QUADROS
	animacao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(animacao)
	animacao.frame_changed.connect(_quadro_alterado)
	animacao.animation_finished.connect(_terminar_animacao)
	_tocar(&"idle")

func _tocar(nome: StringName) -> void:
	animacao.speed_scale = 1.0
	reproducoes[nome] = int(reproducoes.get(nome, 0)) + 1
	animacao.play(nome)
	animacao.set_frame_and_progress(0, 0.0)
	_alinhar_quadro()

func _alinhar_quadro() -> void:
	var reacao := animacao.animation in [&"dano", &"morte"]
	var disparando := animacao.animation == &"disparo"
	var escala := 0.216 if reacao else (0.25 if disparando and animacao.frame >= 4 else 0.27)
	animacao.scale = Vector2.ONE * escala
	animacao.position.y = 30.0 - (174.0 if reacao or disparando else 112.0) * escala

func _quadro_alterado() -> void:
	_alinhar_quadro()
	if em_disparo and animacao.animation == &"disparo" and animacao.frame == 5:
		soltura.emit()

func _terminar_animacao() -> void:
	if animacao.animation == &"morte":
		morte_em_andamento = false
		animacao.pause() # Mantém o corpo no último quadro, como os inimigos anteriores.
		morte_finalizada.emit()
		return
	em_disparo = false
	if vivo and not em_movimento:
		_tocar(&"idle")

func olhar_para(direcao: Vector2) -> void:
	if not is_zero_approx(direcao.x):
		animacao.flip_h = direcao.x > 0 # Fonte desenhada para a esquerda.

func animar_disparo_ate_soltura() -> void:
	if not vivo or not visible or em_disparo:
		return
	em_disparo = true
	_tocar(&"disparo")
	await soltura

func origem_disparo() -> Vector2:
	return position + Vector2(35 if animacao.flip_h else -35, -24)

func iniciar_deslocamento(correr: bool, direcao: Vector2) -> void:
	if not vivo:
		return
	em_movimento = true
	olhar_para(direcao)
	_tocar(&"caminhar")
	animacao.speed_scale = 1.35 if correr else 1.0

func parar_deslocamento() -> void:
	em_movimento = false
	if vivo:
		_tocar(&"idle")

func reagir_impacto(_bloqueado: bool, dano: int) -> void:
	if vivo and dano > 0:
		_tocar(&"dano")

func definir_vivo(valor: bool) -> void:
	if vivo == valor:
		return
	vivo = valor
	em_movimento = false
	if not vivo:
		if em_disparo:
			em_disparo = false
			soltura.emit()
		morte_em_andamento = true
		_tocar(&"morte")
	else:
		morte_em_andamento = false
		_tocar(&"idle")
