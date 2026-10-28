extends Sprite2D
## Somente apresentação. Mantém o nó Sprite2D usado pelo combate e pelos efeitos.
signal impacto
signal morte_finalizada

const QUADROS = preload("res://assets/characters/brokk/brokk_animacoes.tres")
const COMPLEMENTOS = preload("res://assets/characters/brokk/brokk_complementos.tres")
const ESCALA_ATLAS := 0.1875 # Tela lógica de 72 px; corpo de aproximadamente 51 px.
const ESCALAS := {&"caminhar": 1.06, &"correr": 1.06, &"defesa": 0.96, &"dano": 0.96, &"morte": 0.96}
@export var quadros_principais: SpriteFrames = QUADROS
@export var quadros_complementares: SpriteFrames = COMPLEMENTOS
var escala_visual := ESCALA_ATLAS
var animacao: AnimatedSprite2D
var em_ataque := false
var vivo := true
var ataques_apresentados := 0
var em_movimento := false
var morte_em_andamento := false
var ocultar_apos_morte := true
var reproducoes: Dictionary = {}

func _ready() -> void:
	texture = null
	region_enabled = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sombra := Polygon2D.new()
	sombra.name = "SombraContato"
	sombra.color = Color(0.02, 0.03, 0.04, 0.4)
	var contorno := PackedVector2Array()
	for i in range(16):
		var angulo := TAU * i / 16.0
		contorno.append(Vector2(cos(angulo) * 22, 29 + sin(angulo) * 4))
	sombra.polygon = contorno
	add_child(sombra)
	animacao = AnimatedSprite2D.new()
	animacao.name = "AnimacaoBrokk"
	var quadros: SpriteFrames = quadros_principais.duplicate()
	escala_visual = float(quadros.get_meta("escala_atlas", ESCALA_ATLAS))
	for nome in (quadros_complementares.get_animation_names() if quadros_complementares != null else PackedStringArray()):
		quadros.add_animation(nome)
		quadros.set_animation_loop(nome, quadros_complementares.get_animation_loop(nome))
		quadros.set_animation_speed(nome, quadros_complementares.get_animation_speed(nome))
		for i in range(quadros_complementares.get_frame_count(nome)):
			quadros.add_frame(nome, quadros_complementares.get_frame_texture(nome, i))
	animacao.sprite_frames = quadros
	animacao.scale = Vector2.ONE * ESCALA_ATLAS
	animacao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(animacao)
	animacao.frame_changed.connect(_quadro_alterado)
	animacao.animation_finished.connect(_terminar_ataque)
	_tocar(&"idle")

func _tocar(nome: StringName) -> void:
	var escala: float = escala_visual * float(ESCALAS.get(nome, 1.0))
	animacao.scale = Vector2.ONE * escala
	# Compensa a diferença entre fontes mantendo o chão a 30 px da raiz.
	animacao.position.y = 30.0 - 160.0 * escala
	reproducoes[nome] = int(reproducoes.get(nome, 0)) + 1
	animacao.play(nome)
	animacao.set_frame_and_progress(0, 0.0)

func _quadro_alterado() -> void:
	if em_ataque and animacao.animation == &"ataque" and animacao.frame == 4:
		impacto.emit()

func _terminar_ataque() -> void:
	if animacao.animation == &"morte":
		morte_em_andamento = false
		animacao.pause() # Conserva o último quadro, inclusive no mostruário.
		visible = not ocultar_apos_morte
		morte_finalizada.emit()
		return
	em_ataque = false
	if vivo and not em_movimento:
		_tocar(&"idle")

func animar_ataque_ate_impacto() -> void:
	if not vivo or not visible or em_ataque:
		return
	em_ataque = true
	ataques_apresentados += 1
	_tocar(&"ataque")
	# O controlador continua no quadro de contato, não após toda a recuperação.
	await impacto

func definir_vivo(valor: bool) -> void:
	if vivo == valor:
		return
	vivo = valor
	if not vivo:
		em_movimento = false
		if em_ataque:
			em_ataque = false
			impacto.emit()
		morte_em_andamento = true
		_tocar(&"morte")
	else:
		morte_em_andamento = false
		visible = true
		_tocar(&"idle")

func olhar_para(direcao: Vector2) -> void:
	if not is_zero_approx(direcao.x):
		animacao.flip_h = direcao.x < 0

func iniciar_deslocamento(correr: bool, direcao: Vector2 = Vector2.RIGHT) -> void:
	if not vivo:
		return
	em_movimento = true
	olhar_para(direcao)
	_tocar(&"correr" if correr else &"caminhar")

func parar_deslocamento() -> void:
	em_movimento = false
	if vivo:
		_tocar(&"idle")

func defender() -> void:
	if vivo and not em_ataque and not em_movimento:
		_tocar(&"defesa")

func reagir_impacto(bloqueado: bool, dano: int) -> void:
	if not vivo:
		return
	if bloqueado:
		defender()
	elif dano > 0:
		_tocar(&"dano")
