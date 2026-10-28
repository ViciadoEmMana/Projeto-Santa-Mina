extends RefCounted
## Componentes de apresentação. Não calcula dano, iniciativa ou custos de ações.

const LIMITE_REGISTRO := 80
var pa_barras: Dictionary = {}
var condicoes: Dictionary = {}
var rotulos_armas: Dictionary = {}
var paineis: Dictionary = {}
var mensagens: Array[String] = []
var registro: RichTextLabel
var painel_registro: PanelContainer
var texto_alvo: Label
var ordem_visivel: Array[String] = []
var proximo := ""


static func estilo(ativo: bool = false, derrotado: bool = false) -> StyleBoxFlat:
	var fundo := StyleBoxFlat.new()
	fundo.bg_color = Color("201c1b") if derrotado else Color("30241e")
	fundo.border_color = Color("e6be69") if ativo else Color("796044")
	fundo.set_border_width_all(2 if ativo else 1)
	fundo.set_corner_radius_all(6)
	fundo.content_margin_left = 12
	fundo.content_margin_right = 12
	fundo.content_margin_top = 7
	fundo.content_margin_bottom = 7
	fundo.shadow_color = Color(0, 0, 0, 0.28)
	fundo.shadow_size = 3
	return fundo


static func barra(cor: Color, altura: float) -> ProgressBar:
	var resultado := ProgressBar.new()
	resultado.custom_minimum_size = Vector2(0, altura)
	resultado.show_percentage = false
	resultado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for tipo in ["background", "fill"]:
		var faixa := StyleBoxFlat.new()
		faixa.bg_color = cor if tipo == "fill" else Color("171414")
		faixa.set_corner_radius_all(2)
		resultado.add_theme_stylebox_override(tipo, faixa)
	return resultado


func completar_cartao(id: String, painel: PanelContainer, coluna: VBoxContainer) -> void:
	paineis[id] = painel
	coluna.add_theme_constant_override("separation", 0)
	var pa := barra(Color("dba74e"), 4)
	coluna.add_child(pa)
	coluna.move_child(pa, 3 if id != "Brokk" else 4)
	pa_barras[id] = pa
	var status := Label.new()
	status.add_theme_font_size_override("font_size", 10)
	status.add_theme_color_override("font_color", Color("d5c3a1"))
	coluna.add_child(status)
	condicoes[id] = status


func atualizar_cartao(id: String, pa: int, maximo_pa: int, vivo: bool, ativo: bool, estados: Array[String]) -> void:
	pa_barras[id].max_value = maximo_pa
	pa_barras[id].value = pa
	pa_barras[id].tooltip_text = "%d/%d PA disponíveis" % [pa, maximo_pa]
	condicoes[id].text = "DERROTADO" if not vivo else (" • ".join(estados) if not estados.is_empty() else "Sem condições")
	condicoes[id].tooltip_text = condicoes[id].text
	var painel: PanelContainer = paineis[id]
	painel.modulate = Color.WHITE if vivo else Color("8c8580")
	# Estilos só são substituídos quando o destaque realmente muda.
	var estado := str(ativo) + str(vivo)
	if painel.get_meta("aparencia", "") != estado:
		painel.add_theme_stylebox_override("panel", estilo(ativo, not vivo))
		painel.set_meta("aparencia", estado)


func criar_lateral(pai: CanvasLayer) -> void:
	texto_alvo = Label.new()
	texto_alvo.position = Vector2(610, 316)
	texto_alvo.size = Vector2(326, 28)
	texto_alvo.add_theme_font_size_override("font_size", 11)
	texto_alvo.add_theme_color_override("font_color", Color("e6be69"))
	pai.add_child(texto_alvo)
	painel_registro = PanelContainer.new()
	painel_registro.position = Vector2(610, 382)
	painel_registro.size = Vector2(326, 72)
	painel_registro.add_theme_stylebox_override("panel", estilo())
	pai.add_child(painel_registro)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	painel_registro.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "REGISTRO DE COMBATE"
	titulo.add_theme_font_size_override("font_size", 10)
	titulo.add_theme_color_override("font_color", Color("d9ae70"))
	coluna.add_child(titulo)
	registro = RichTextLabel.new()
	registro.custom_minimum_size = Vector2(0, 40)
	registro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	registro.add_theme_font_size_override("normal_font_size", 11)
	registro.add_theme_color_override("default_color", Color("eadfc9"))
	registro.scroll_following = true
	registro.selection_enabled = true
	coluna.add_child(registro)


func registrar(texto: String) -> void:
	if texto.is_empty() or (not mensagens.is_empty() and mensagens.back() == texto):
		return
	mensagens.append(texto)
	if mensagens.size() > LIMITE_REGISTRO:
		mensagens.pop_front()
	if is_instance_valid(registro):
		registro.text = "\n\n".join(mensagens)
		registro.tooltip_text = texto


static func preparar_botao(botao: Button, acao: String) -> void:
	botao.set_meta("acao", acao)
	botao.add_theme_font_size_override("font_size", 12)
	botao.add_theme_color_override("font_color", Color("f3e5c8"))
	botao.add_theme_color_override("font_disabled_color", Color("857b70"))
	for tipo in ["normal", "hover", "pressed", "disabled", "focus"]:
		var fundo := estilo(tipo in ["hover", "focus"])
		fundo.bg_color = Color("483421") if tipo == "hover" else (Color("211e1b") if tipo == "disabled" else Color("35291f"))
		fundo.content_margin_left = 8
		fundo.content_margin_right = 8
		botao.add_theme_stylebox_override(tipo, fundo)
	# Ícones mínimos, desenhados localmente uma vez, sem texturas externas.
	var imagem := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	for y in range(12):
		for x in range(12):
			var marcado := false
			match acao:
				"atacar", "vantagem": marcado = x == y or (acao == "vantagem" and x + y == 11)
				"defender": marcado = (x == 2 or x == 9) and y < 8 or y == 1 and x > 2 and x < 9 or y >= 8 and absi(x - 6) == 11 - y
				"mover", "correr": marcado = y == 6 or x > 5 and absi(y - 6) == 11 - x or acao == "correr" and x == 2
				_: marcado = y == 2 or x == 9 or y == 9
			if marcado:
				imagem.set_pixel(x, y, Color("e0b765"))
	botao.icon = ImageTexture.create_from_image(imagem)
