extends RefCounted
## Layout em containers. Não decide ações, posição tática, dados ou dano.
var raiz: MarginContainer
var espaco_grade: Control
var espaco_dado: Control
var rotulos_iniciativa: Dictionary = {}
var arena_visual: Node2D
var area_detalhes: Control
var texto_pa: Label

func preparar_arena(c: Node) -> void:
	arena_visual = Node2D.new()
	arena_visual.name = "ArenaAmpliada"
	c.add_child(arena_visual)
	c.move_child(arena_visual, 0)

func _linha(altura: float) -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha.custom_minimum_size.y = altura
	linha.add_theme_constant_override("separation", 12)
	return linha

func _mover(controle: Control, pai: Node, expandir: bool = false) -> void:
	controle.reparent(pai)
	controle.position = Vector2.ZERO
	controle.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expandir else Control.SIZE_FILL
	controle.custom_minimum_size = Vector2.ZERO

func criar(c: Node) -> void:
	var camada: CanvasLayer = c.botao_ficha.get_parent()
	raiz = MarginContainer.new()
	# A grade Node2D recebe _unhandled_input: containers decorativos não
	# podem consumir o clique. Botões e cartas mantêm seus próprios filtros.
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.name = "LayoutCombate"
	camada.add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		raiz.add_theme_constant_override("margin_" + lado, 24)
	for lado in ["top", "bottom"]:
		raiz.add_theme_constant_override("margin_" + lado, 12)
	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_theme_constant_override("separation", 4)
	raiz.add_child(coluna)
	var cabecalho := _linha(40)
	coluna.add_child(cabecalho)
	var nome := Label.new()
	nome.text = "SANTA MINA / COMBATE"
	nome.add_theme_font_size_override("font_size", 22)
	nome.add_theme_color_override("font_color", Color("e7bd66"))
	for filho in camada.get_children():
		if filho is Label and filho.text.contains("SANTA MINA"):
			filho.visible = false
	cabecalho.add_child(nome)
	_mover(c.texto_turno, cabecalho, true)
	c.texto_turno.add_theme_font_size_override("font_size", 16)
	texto_pa = Label.new()
	texto_pa.add_theme_font_size_override("font_size", 20)
	texto_pa.add_theme_color_override("font_color", Color("e7bd66"))
	cabecalho.add_child(texto_pa)
	_mover(c.botao_ficha, cabecalho)
	c.botao_ficha.custom_minimum_size = Vector2(112, 40)
	c.botao_ficha.add_theme_font_size_override("font_size", 18)
	# Mantém os resultados identificados numa única faixa compacta.
	var iniciativas := _linha(40)
	coluna.add_child(iniciativas)
	var ids: Array[String] = ["Brokk"]
	ids.append_array(c._inimigos_vivos())
	for id in ids:
		var rotulo := Label.new()
		rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rotulo.add_theme_font_size_override("font_size", 16)
		rotulo.add_theme_color_override("font_color", Color("9dc5ff") if id == "Brokk" else Color("f5aaa1"))
		iniciativas.add_child(rotulo)
		rotulos_iniciativa[id] = rotulo
	var arena := _linha(450)
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(arena)
	espaco_grade = Control.new()
	espaco_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	espaco_grade.custom_minimum_size = Vector2(820, 450)
	espaco_grade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.add_child(espaco_grade)
	var dados := VBoxContainer.new()
	dados.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dados.custom_minimum_size.x = 360
	dados.add_theme_constant_override("separation", 4)
	arena.add_child(dados)
	espaco_dado = Control.new()
	espaco_dado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	espaco_dado.custom_minimum_size.y = 120
	dados.add_child(espaco_dado)
	for rotulo in [c.texto_dado, c.visual_ui.texto_alvo]:
		_mover(rotulo, dados, true)
		rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rotulo.custom_minimum_size.y = 24 if rotulo == c.texto_dado else 44
		rotulo.add_theme_font_size_override("font_size", 16)
	c.texto_passivas.visible = false # Disponível na inspeção e na ficha completa.
	area_detalhes = Control.new()
	area_detalhes.name = "RegistroOuInspecao"
	area_detalhes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area_detalhes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	area_detalhes.custom_minimum_size = Vector2(360, 250)
	dados.add_child(area_detalhes)
	_mover(c.visual_ui.painel_registro, area_detalhes)
	c.visual_ui.painel_registro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.visual_ui.registro.custom_minimum_size = Vector2(0, 204)
	c.visual_ui.registro.add_theme_font_size_override("normal_font_size", 16)
	c.visual_ui.painel_registro.get_child(0).get_child(0).add_theme_font_size_override("font_size", 16)
	var controles := _linha(42)
	coluna.add_child(controles)
	var ajuda := Label.new()
	ajuda.text = "AÇÕES BÁSICAS • Selecione uma carta e confirme no tabuleiro. Esc cancela."
	ajuda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ajuda.add_theme_font_size_override("font_size", 16)
	controles.add_child(ajuda)
	_mover(c.botao_encerrar, controles)
	c.botao_encerrar.custom_minimum_size = Vector2(220, 42)
	c.botao_encerrar.add_theme_font_size_override("font_size", 18)
	var linha_antiga: Node = c.barra_cartas.get_parent()
	c.barra_cartas.set_meta("reorganizando", true)
	_mover(c.barra_cartas, coluna, true)
	c.barra_cartas.set_meta("reorganizando", false)
	c.barra_cartas.custom_minimum_size = Vector2(944, 304)
	linha_antiga.queue_free()
	# Um único transform visual amplia piso, atores e efeitos juntos. A lógica
	# continua usando casas de 88 px e os mesmos caminhos/custos.
	for item in [c.cenario, c.grade, c.sprite_brokk]:
		item.reparent(arena_visual)
	for sprite in c.encontro.sprites.values():
		sprite.reparent(arena_visual)
	arena_visual.move_child(c.cenario, 0)
	# O dado é um elemento de interface, na mesma camada dos textos e cartas.
	c.visual_dado.reparent(camada)
	c.inspecao.criar(c, camada, area_detalhes)
	c.visual_dado.z_index = 50
	espaco_grade.item_rect_changed.connect(func(): ajustar.call_deferred(c))
	espaco_dado.item_rect_changed.connect(func(): ajustar_dado.call_deferred(c))
	raiz.resized.connect(func(): ajustar(c))
	c.get_tree().process_frame.connect(func(): ajustar(c), CONNECT_ONE_SHOT)

func ajustar(c: Node) -> void:
	if not is_instance_valid(c) or not is_instance_valid(espaco_grade):
		return
	var fator := minf(1.5, minf((espaco_grade.size.x - 48.0) / 528.0, (espaco_grade.size.y - 80.0) / 264.0))
	arena_visual.scale = Vector2.ONE * fator
	arena_visual.position = (espaco_grade.get_global_rect().position + Vector2((espaco_grade.size.x - 528.0 * fator) / 2.0, 48)).round()
	c.grade.position = Vector2.ZERO
	if is_instance_valid(c.cenario):
		c.cenario.enquadrar(c.grade.position, c.get_viewport_rect().size)
	ajustar_dado(c)
	c._sincronizar_sprites()

func ajustar_dado(c: Node) -> void:
	if not is_instance_valid(c) or not is_instance_valid(espaco_dado):
		return
	c.visual_dado.position = espaco_dado.get_global_rect().position.round()
	c.visual_dado.size = espaco_dado.size.round()

func atualizar(c: Node) -> void:
	if is_instance_valid(texto_pa):
		texto_pa.text = "%s • %d/%d PA" % [c.ficha_brokk.NOME, c.estado_brokk.pa_atuais, c.estado_brokk.pa_maximos]
	for id in rotulos_iniciativa:
		if not c.iniciativas.has(id):
			rotulos_iniciativa[id].text = c._nome_participante(id) + "\nRolando iniciativa…"
			continue
		var valor: Dictionary = c.iniciativas[id]
		rotulos_iniciativa[id].text = "%s\nd20 %d + DES %+d%s = %d" % [c._nome_participante(id), valor["natural"], valor["destreza"], " + café %d" % valor["alimento"] if valor["alimento"] > 0 else "", valor["total"]]

func retangulo_grade() -> Rect2:
	return Rect2(arena_visual.global_position, Vector2(528, 264) * arena_visual.global_scale)
