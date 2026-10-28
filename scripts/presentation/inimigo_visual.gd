extends Sprite2D
## Apresentação compartilhada dos inimigos originais. Não calcula PV, PA ou RNG.
signal impacto
signal soltura
signal gesto
signal morte_finalizada

@export var quadros: SpriteFrames
@export var identidade_visual: StringName = &"inimigo_original"
@export var projetil := false
@export var escala_acoes := 0.185
@export var escala_ataque := 0.178
@export var escala_reacoes := 0.206
var animacao: AnimatedSprite2D
var vivo := true
var em_ataque := false
var em_movimento := false
var morte_em_andamento := false
var reproducoes: Dictionary = {}

func _ready() -> void:
	set_meta(identidade_visual, true)
	set_meta("inimigo_original", true)
	texture = null
	region_enabled = false
	scale = Vector2.ONE
	flip_h = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sombra := Polygon2D.new()
	sombra.name = "SombraContato"
	sombra.color = Color(0.02, 0.03, 0.04, 0.4)
	var contorno := PackedVector2Array()
	for i in range(16):
		var angulo := TAU * i / 16.0
		contorno.append(Vector2(cos(angulo) * 23, 29 + sin(angulo) * 4))
	sombra.polygon = contorno
	add_child(sombra)
	animacao = AnimatedSprite2D.new()
	animacao.name = "AnimacaoInimigo"
	animacao.sprite_frames = quadros
	animacao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(animacao)
	animacao.frame_changed.connect(_quadro_alterado)
	animacao.animation_finished.connect(_terminar_animacao)
	_tocar(&"idle")

func _tocar(nome: StringName) -> void:
	var chave := "escala_reacoes" if nome in [&"dano", &"morte"] else ("escala_ataque" if nome == &"ataque" else "escala_acoes")
	if nome == &"reacao":
		chave = "escala_reacao"
	var padrao := escala_reacoes if nome in [&"dano", &"morte"] else (escala_ataque if nome == &"ataque" else escala_acoes)
	var escala: float = quadros.get_meta(chave, padrao)
	animacao.scale = Vector2.ONE * escala
	# Tela virtual de 640 px, apoio em y = 560; mantém o mesmo chão do combate.
	animacao.position.y = 30.0 - 240.0 * escala
	animacao.speed_scale = 1.0
	reproducoes[nome] = int(reproducoes.get(nome, 0)) + 1
	animacao.play(nome)
	animacao.set_frame_and_progress(0, 0.0)

func _quadro_alterado() -> void:
	if em_ataque and animacao.animation == &"ataque" and animacao.frame == int(quadros.get_meta("quadro_impacto", 4)):
		impacto.emit()
		if projetil:
			soltura.emit()
	if em_ataque and animacao.animation == &"reacao" and animacao.frame == 2:
		gesto.emit()

func _terminar_animacao() -> void:
	if animacao.animation == &"morte":
		morte_em_andamento = false
		animacao.pause() # Conserva a pose final sem girar a raiz do personagem.
		morte_finalizada.emit()
		return
	em_ataque = false
	if vivo and not em_movimento:
		_tocar(&"idle")

func olhar_para(direcao: Vector2) -> void:
	if not is_zero_approx(direcao.x):
		animacao.flip_h = direcao.x > 0 # Fonte desenhada para a esquerda.

func animar_golpe_ate_impacto() -> void:
	if not vivo or not visible or em_ataque:
		return
	em_ataque = true
	_tocar(&"ataque")
	await impacto

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
		if em_ataque:
			em_ataque = false
			impacto.emit()
			soltura.emit()
			gesto.emit()
		morte_em_andamento = true
		_tocar(&"morte")
	else:
		morte_em_andamento = false
		_tocar(&"idle")

func animar_disparo_ate_soltura() -> void:
	await animar_golpe_ate_impacto()

func origem_disparo() -> Vector2:
	return position + Vector2(28 if animacao.flip_h else -28, -14)

func animar_reacao() -> void:
	if not vivo or not visible or em_ataque or not quadros.has_animation(&"reacao"):
		return
	em_ataque = true
	_tocar(&"reacao")
	await gesto # Areia/destaque começam no gesto, antes da recuperação.
