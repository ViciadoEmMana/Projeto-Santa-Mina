extends Node
## Mostruário F6 independente: não carrega nem altera estado de campanha.
const Dados = preload("res://dado_poliedrico.gd")
var dados: Array[Node3D] = []
var rotulos: Array[Label] = []
var rng := RandomNumberGenerator.new()
var em_rolagem := false

func _ready() -> void:
	rng.randomize()
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var fundo := ColorRect.new()
	fundo.color = Color("15171d")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	var container := SubViewportContainer.new()
	container.position = Vector2(24, 70)
	container.size = Vector2(1232, 620)
	container.stretch = true
	add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1232, 620)
	viewport.transparent_bg = true
	container.add_child(viewport)
	var mundo := Node3D.new()
	viewport.add_child(mundo)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 6.4
	camera.position.z = 10
	mundo.add_child(camera)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-25, -35, 0)
	luz.light_energy = 1.8
	mundo.add_child(luz)
	var titulo := Label.new()
	titulo.text = "SANTA MINA • DADOS POLIÉDRICOS"
	titulo.position = Vector2(30, 15)
	titulo.add_theme_font_size_override("font_size", 26)
	add_child(titulo)
	var legenda := Label.new()
	legenda.text = "Azul: heróis • Vermelho: inimigos • A face frontal mostra o valor utilizado."
	legenda.position = Vector2(30, 47)
	legenda.add_theme_font_size_override("font_size", 16)
	add_child(legenda)
	var botao := Button.new()
	botao.text = "Lançar todos os dados"
	botao.position = Vector2(985, 14)
	botao.size = Vector2(270, 44)
	botao.pressed.connect(lancar)
	add_child(botao)
	for i in range(6):
		var tipo: int = Dados.Geometria.TIPOS[i]
		var dado := Node3D.new()
		dado.position = Vector3((i % 3 - 1) * 3.9, 1.65 if i < 3 else -1.45, 0)
		mundo.add_child(dado)
		Dados.configurar(dado, tipo, Color("274f9c") if i % 2 == 0 else Color("973b3c"))
		dado.rotation = Dados.orientacao(dado, tipo)
		dados.append(dado)
		var rotulo := Label.new()
		rotulo.position = Vector2(130 + (i % 3) * 380, 330 if i < 3 else 630)
		rotulo.text = "d%d • resultado %d" % [tipo, tipo]
		rotulo.add_theme_font_size_override("font_size", 22)
		add_child(rotulo)
		rotulos.append(rotulo)

func lancar() -> void:
	if em_rolagem:
		return
	em_rolagem = true
	var animacao: Tween
	for i in range(dados.size()):
		var tipo: int = dados[i].get_meta("tipo_dado")
		var resultado := rng.randi_range(1, tipo)
		rotulos[i].text = "d%d • resultado %d" % [tipo, resultado]
		animacao = Dados.animar(dados[i], resultado)
	await animacao.finished
	em_rolagem = false
