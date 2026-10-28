extends Button
## Somente apresentação. Textos/PA não executam regras de combate.
const Interface = preload("res://interface_combate.gd")
const Animacao = preload("res://animacao_carta.gd")
const TAMANHO := Vector2(192, 288)
@export var arte: Texture2D:
	set(valor):
		arte = valor
		if is_instance_valid(ilustracao):
			ilustracao.texture = valor
		queue_redraw()
var definicao: Dictionary = {}
var custo := 0
var selecionada := false
var sob_cursor := false
var ilustracao: TextureRect
var titulo: Label
var custo_texto: Label
var descricao: Label
var rodape: Label
var posicao_mao := Vector2.ZERO
var escala_mao := 1.0
var inclinacao_mao := 0.0
var animacao := Animacao.new()
var cor := Color("773b33")

func configurar(dados: Dictionary, custo_pa: int) -> void:
	definicao = dados.duplicate(true)
	custo = custo_pa
	set_meta("acao", dados["id"])
	set_meta("categoria", dados.get("categoria", "basica_permanente"))
	name = "Carta_" + str(dados["id"])
	size = TAMANHO
	pivot_offset = TAMANHO / 2
	Interface.preparar_botao(self, dados["id"])
	# Mantém text/icon para acessibilidade e referências anteriores, sem desenhá-los.
	expand_icon = true
	add_theme_font_size_override("font_size", 1)
	for estado in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(estado, StyleBoxEmpty.new())
		add_theme_color_override("font_" + ("color" if estado == "normal" else estado + "_color"), Color.TRANSPARENT)
		add_theme_color_override("icon_" + estado + "_color", Color.TRANSPARENT)
	cor = Color(dados.get("cor", "773b33"))
	if titulo == null:
		titulo = _texto(Vector2(43, 9), Vector2(99, 32), 18, Color("efddaf"))
		titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		custo_texto = _texto(Vector2(5, 5), Vector2(34, 30), 26, Color("ffe4a1"))
		custo_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var pa := _texto(Vector2(6, 30), Vector2(32, 12), 11, Color("d9b77a"))
		pa.text = "PA"
		pa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ilustracao = TextureRect.new()
		ilustracao.name = "Ilustracao"
		ilustracao.position = Vector2(12, 49) * (192.0 / 152.0)
		ilustracao.size = Vector2(128, 98) * (192.0 / 152.0)
		ilustracao.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ilustracao.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ilustracao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ilustracao.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(ilustracao)
		descricao = _texto(Vector2(12, 155), Vector2(128, 57), 16, Color("eadcc0"))
		descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rodape = _texto(Vector2(7, 215), Vector2(138, 12), 10, Color("bd9d69"))
		rodape.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mouse_entered.connect(_foco.bind(true))
		mouse_exited.connect(_foco.bind(false))
	titulo.text = dados["nome"]
	if dados["id"] == "vantagem":
		titulo.add_theme_font_size_override("font_size", 16)
	custo_texto.text = str(custo)
	descricao.text = dados.get("efeito", dados["descricao"])
	if dados.get("arte") is Texture2D:
		arte = dados["arte"]
	ilustracao.texture = arte
	atualizar(false, "")

func _texto(posicao: Vector2, tamanho: Vector2, fonte: int, tinta: Color) -> Label:
	var rotulo := Label.new()
	rotulo.position = (posicao * (192.0 / 152.0)).round()
	rotulo.size = (tamanho * (192.0 / 152.0)).round()
	rotulo.add_theme_font_size_override("font_size", fonte)
	rotulo.add_theme_color_override("font_color", tinta)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rotulo)
	return rotulo

func atualizar(ativa: bool, motivo: String) -> void:
	var mudou := selecionada != (ativa and motivo.is_empty()) or disabled != not motivo.is_empty()
	selecionada = ativa and motivo.is_empty()
	disabled = not motivo.is_empty()
	text = "%s • %d PA" % [definicao["nome"], custo]
	tooltip_text = "%s • %d PA\n%s" % [definicao["nome"], custo, definicao["descricao"]]
	if disabled:
		tooltip_text += "\nIndisponível: " + motivo
	elif selecionada:
		tooltip_text += "\nSELECIONADA — clique no alvo/destino. Esc ou esta carta cancela sem gastar PA."
	rodape.text = "BÁSICA • " + ("INDISPONÍVEL" if disabled else ("SELECIONADA" if selecionada else "PERMANENTE"))
	modulate = Color(0.62, 0.62, 0.65) if disabled else Color.WHITE
	custo_texto.modulate = Color(1.45, 1.45, 1.45) if disabled else Color.WHITE
	if mudou:
		_animar()
	queue_redraw()

func definir_posicao_mao(posicao: Vector2, proporcao: float, inclinacao: float) -> void:
	posicao_mao = posicao
	escala_mao = proporcao
	inclinacao_mao = inclinacao
	_animar(true)

func _foco(ativo: bool) -> void:
	sob_cursor = ativo
	_animar()
	queue_redraw()

func _animar(imediato: bool = false) -> void:
	var destaque := (sob_cursor or selecionada) and not disabled
	z_index = 20 if sob_cursor else (10 if selecionada else 0)
	var destino := posicao_mao + Vector2(0, -8 if destaque else 0)
	var fator := escala_mao * (1.025 if sob_cursor and not disabled else 1.0)
	animacao.aplicar(self, destino, fator, 0.0 if destaque else inclinacao_mao, imediato)

func _draw() -> void:
	if definicao.is_empty():
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * (192.0 / 152.0))
	var ouro := Color("f5cf7c") if selecionada or sob_cursor and not disabled else Color("a6804b")
	var moldura := Interface.estilo(selecionada or sob_cursor and not disabled)
	moldura.bg_color = Color("241c19")
	moldura.border_color = ouro
	moldura.set_border_width_all(2)
	moldura.set_corner_radius_all(7)
	moldura.shadow_size = 5
	moldura.shadow_offset = Vector2(1, 3)
	draw_style_box(moldura, Rect2(Vector2.ZERO, Vector2(152, 228)))
	draw_rect(Rect2(5, 5, 142, 146), cor.darkened(0.60))
	for y in range(9, 150, 7):
		draw_line(Vector2(7, y), Vector2(145, y + 2), Color(0.8, 0.6, 0.3, 0.04), 1)
	draw_rect(Rect2(8, 46, 136, 104), Color("0f1416"))
	draw_rect(Rect2(9, 47, 134, 102), ouro.darkened(0.3), false, 1)
	_paisagem()
	if arte == null:
		_simbolo()
	# Pergaminho inferior, entalhes e rebites de metal envelhecido.
	draw_rect(Rect2(7, 153, 138, 61), Color("3a3027"))
	for y in [153, 212]:
		draw_line(Vector2(10, y), Vector2(142, y), Color("766044"), 1)
	for x in [5.0, 147.0]:
		for y in [5.0, 150.0, 222.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(x, y - 3), Vector2(x + 3, y), Vector2(x, y + 3), Vector2(x - 3, y)]), ouro)
	draw_line(Vector2(44, 43), Vector2(139, 43), ouro.darkened(0.35), 1)
	draw_circle(Vector2(22, 24), 19, Color("16171a"))
	draw_circle(Vector2(22, 24), 18, ouro, false, 2, true)
	draw_circle(Vector2(22, 24), 15, cor.darkened(0.30))
	draw_circle(Vector2(22, 24), 14, Color("ad8b53"), false, 1, true)

func _paisagem() -> void:
	draw_rect(Rect2(12, 49, 128, 98), cor.darkened(0.75))
	draw_circle(Vector2(104, 75), 18, cor.lightened(0.1).darkened(0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(12, 126), Vector2(36, 86), Vector2(65, 120), Vector2(93, 91), Vector2(140, 135), Vector2(140, 147), Vector2(12, 147)]), Color("20282a"))
	for i in range(10):
		var x := 19.0 + fmod(i * 31.0, 116.0)
		var y := 57.0 + fmod(i * 17.0, 82.0)
		draw_circle(Vector2(x, y), 0.7, Color(0.94, 0.78, 0.45, 0.36))

func _espada(origem: Vector2, angulo: float) -> void:
	draw_set_transform(origem * (192.0 / 152.0), angulo, Vector2.ONE * (192.0 / 152.0))
	draw_colored_polygon(PackedVector2Array([Vector2(-5, 13), Vector2(-5, -25), Vector2(0, -37), Vector2(6, -25), Vector2(6, 13)]), Color("c5cdd0"))
	draw_line(Vector2(0, -29), Vector2(0, 12), Color("f3e7c5"), 2)
	draw_line(Vector2(-13, 16), Vector2(13, 16), Color("c49a51"), 5, true)
	draw_line(Vector2(0, 18), Vector2(0, 33), Color("725147"), 7, true)
	draw_circle(Vector2(0, 34), 4, Color("bba16c"))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * (192.0 / 152.0))

func _simbolo() -> void:
	match definicao["id"]:
		"atacar":
			_espada(Vector2(75, 98), 0.48)
		"vantagem":
			_espada(Vector2(65, 99), -0.48)
			_espada(Vector2(89, 99), 0.48)
		"defender":
			draw_colored_polygon(PackedVector2Array([Vector2(46, 67), Vector2(76, 60), Vector2(106, 67), Vector2(103, 110), Vector2(76, 135), Vector2(49, 110)]), Color("a3adb0"))
			draw_colored_polygon(PackedVector2Array([Vector2(52, 73), Vector2(76, 67), Vector2(100, 73), Vector2(97, 107), Vector2(76, 126), Vector2(55, 107)]), cor)
			draw_line(Vector2(76, 70), Vector2(76, 119), Color("d8c99b"), 4)
			draw_line(Vector2(57, 91), Vector2(96, 91), Color("d8c99b"), 4)
			draw_circle(Vector2(76, 91), 6, Color("bd9d61"))
		"mover", "correr":
			for i in range(2 if definicao["id"] == "correr" else 1):
				var deslocamento := Vector2(i * 23 - 8, -i * 12)
				var pontos := PackedVector2Array([Vector2(59, 75), Vector2(82, 77), Vector2(76, 107), Vector2(105, 117), Vector2(104, 128), Vector2(51, 128), Vector2(48, 116)])
				for j in range(pontos.size()):
					pontos[j] += deslocamento
				draw_colored_polygon(pontos, Color("a17b4f") if i == 0 else Color("ceab70"))
				draw_line(Vector2(56, 93) + deslocamento, Vector2(78, 96) + deslocamento, Color("44372b"), 4)
			if definicao["id"] == "correr":
				for i in range(3):
					draw_line(Vector2(22, 85 + i * 12), Vector2(43, 81 + i * 12), Color("d4a35d"), 2, true)
