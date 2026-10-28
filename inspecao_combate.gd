extends Node
## Inspeção e PV sobre os atores. Não calcula ataques, dano, iniciativa ou PA.
var combate: Node
var painel: VBoxContainer
var lista: VBoxContainer
var rolagem: ScrollContainer
var botao_fechar: Button
var atributos: Dictionary = {}
var habilidades: Dictionary = {}
var indicadores: Dictionary = {}
var barras: Dictionary = {}
var numeros: Dictionary = {}
var fixado := ""
var exibido := ""
var ignorar_ate_sair := ""
var posicao_mouse := Vector2(-10000, -10000)

func criar(c: Node, camada: CanvasLayer, area: Control) -> void:
	combate = c
	painel = VBoxContainer.new()
	painel.name = "InspecaoDePersonagem"
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cabecalho := HBoxContainer.new()
	cabecalho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(cabecalho)
	var dica := Label.new()
	dica.text = "INSPEÇÃO • clique e role para detalhes"
	dica.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dica.add_theme_font_size_override("font_size", 14)
	dica.add_theme_color_override("font_color", Color("e7bd66"))
	cabecalho.add_child(dica)
	var fechar := Button.new()
	botao_fechar = fechar
	fechar.text = "Fechar"
	fechar.tooltip_text = "Voltar ao registro de combate. Esc também fecha a inspeção."
	fechar.pressed.connect(_fechar)
	c.InterfaceCombate.preparar_botao(fechar, "inspecao")
	cabecalho.add_child(fechar)
	rolagem = ScrollContainer.new()
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	painel.add_child(rolagem)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(lista)
	for id in c.visual_ui.paineis:
		var cartao: PanelContainer = c.visual_ui.paineis[id]
		cartao.reparent(lista)
		cartao.position = Vector2.ZERO
		cartao.custom_minimum_size = Vector2.ZERO
		cartao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cartao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var conteudo: VBoxContainer = cartao.get_child(0)
		conteudo.add_theme_constant_override("separation", 4)
		for filho in conteudo.get_children():
			filho.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if filho is Label:
				filho.clip_text = false
				filho.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				filho.add_theme_font_size_override("font_size", 18 if filho == conteudo.get_child(0) else 16)
		c.encontro.iniciativas[id].visible = false
		var vida: ProgressBar = c.barra_vida_brokk if id == "Brokk" else c.encontro.barras[id]
		var preenchimento := StyleBoxFlat.new()
		preenchimento.bg_color = Color("639bcd") if id == "Brokk" else Color("c85349")
		vida.add_theme_stylebox_override("fill", preenchimento)
		atributos[id] = c._adicionar_label(conteudo, "", 16, Color("d5c3a1"))
		habilidades[id] = c._adicionar_label(conteudo, "", 16, Color("eadfc9"))
		for rotulo in [atributos[id], habilidades[id]]:
			rotulo.clip_text = false
			rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cartao.visible = false
		_criar_pv(id, camada)
	painel.visible = false

func _criar_pv(id: String, camada: CanvasLayer) -> void:
	var indicador := Button.new()
	indicador.name = "PV_" + id
	indicador.size = Vector2(86, 26)
	indicador.focus_mode = Control.FOCUS_NONE
	for estilo in ["normal", "hover", "pressed", "focus"]:
		indicador.add_theme_stylebox_override(estilo, StyleBoxEmpty.new())
	indicador.pressed.connect(_clicar_indicador.bind(id))
	camada.add_child(indicador)
	var barra: ProgressBar = combate.InterfaceCombate.barra(Color("639bcd") if id == "Brokk" else Color("c85349"), 6)
	barra.position = Vector2(3, 20)
	barra.size = Vector2(80, 6)
	indicador.add_child(barra)
	var numero := Label.new()
	numero.size = Vector2(86, 20)
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	numero.add_theme_font_size_override("font_size", 17)
	numero.add_theme_color_override("font_color", Color("f8edda"))
	numero.add_theme_color_override("font_outline_color", Color("101012"))
	numero.add_theme_constant_override("outline_size", 6)
	indicador.add_child(numero)
	indicadores[id] = indicador
	barras[id] = barra
	numeros[id] = numero
	var estado: RefCounted = combate.estado_brokk if id == "Brokk" else combate.inimigos[id]
	estado.alterado.connect(_atualizar_pv)

func _process(_delta: float) -> void:
	if not is_instance_valid(combate) or painel == null:
		return
	_atualizar_pv()
	var sob_mouse := _sob_mouse()
	if combate.rolagem_em_andamento or combate.movimento_em_andamento:
		fixado = ""
		ignorar_ate_sair = sob_mouse
		sob_mouse = ""
	elif sob_mouse != ignorar_ate_sair:
		ignorar_ate_sair = ""
	var id := sob_mouse if not sob_mouse.is_empty() and sob_mouse != ignorar_ate_sair else fixado
	if combate.dialogo_ficha.visible or combate.dialogo_habilidade.visible:
		id = ""
	_mostrar(id)

func _atualizar_pv() -> void:
	for id in indicadores:
		var sprite: Sprite2D = combate.sprite_brokk if id == "Brokk" else combate.encontro.sprites[id]
		var estado: RefCounted = combate.estado_brokk if id == "Brokk" else combate.inimigos[id]
		var indicador: Button = indicadores[id]
		indicador.visible = sprite.visible and (estado.pv_atuais > 0 or sprite.get("morte_em_andamento") == true)
		var altura := -45 if id == "Brokk" and combate.ficha_brokk.ID == "zeno" else -40
		indicador.position = (sprite.to_global(Vector2(0, altura)) - Vector2(43, 30)).round()
		barras[id].max_value = estado.pv_maximos
		barras[id].value = estado.pv_atuais
		numeros[id].text = "%d/%d" % [estado.pv_atuais, estado.pv_maximos]

func _sob_mouse() -> String:
	var mouse := posicao_mouse
	for id in indicadores:
		if indicadores[id].visible and indicadores[id].get_global_rect().has_point(mouse):
			return id
	var local: Vector2 = combate.grade.to_local(mouse)
	var casa := Vector2i(floori(local.x / combate.grade.TAMANHO_CASA), floori(local.y / combate.grade.TAMANHO_CASA))
	if not combate.grade.dentro(casa):
		return ""
	# Um corpo morto não oculta quem passou a ocupar a mesma casa.
	for id in indicadores:
		var vivo: bool = combate.vida_brokk > 0 if id == "Brokk" else combate.inimigos[id].pv_atuais > 0
		if vivo and id not in combate.grade.nao_posicionados and combate.grade.posicoes.get(id) == casa:
			return id
	return ""

func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion or evento is InputEventMouseButton:
		posicao_mouse = evento.position
	if painel == null or combate.dialogo_ficha.visible or combate.dialogo_habilidade.visible:
		return
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		var local: Vector2 = combate.grade.to_local(posicao_mouse)
		if Rect2(Vector2.ZERO, Vector2(528, 264)).has_point(local):
			fixado = _sob_mouse()
			ignorar_ate_sair = ""
	# Não consome o evento: a grade conserva a rota de seleção/ataque/movimento.

func _unhandled_key_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and evento.keycode == KEY_ESCAPE:
		_fechar()

func _clicar_indicador(id: String) -> void:
	if combate.dialogo_ficha.visible or combate.dialogo_habilidade.visible:
		return
	fixado = id
	ignorar_ate_sair = ""
	combate.grade.casa_clicada.emit(combate.grade.posicoes[id])

func _fechar() -> void:
	fixado = ""
	ignorar_ate_sair = _sob_mouse()
	_mostrar("")

func _mostrar(id: String) -> void:
	if exibido != id:
		for chave in combate.visual_ui.paineis:
			combate.visual_ui.paineis[chave].visible = chave == id
		rolagem.scroll_vertical = 0
	exibido = id
	painel.visible = not id.is_empty()
	combate.visual_ui.painel_registro.visible = id.is_empty()
	if id.is_empty():
		return
	if id == "Brokk":
		var ficha: RefCounted = combate.ficha_brokk
		var valores: Array[String] = []
		for atributo in ["FOR", "DES", "CON", "INT", "SAB", "CAR"]:
			valores.append("%s %+d" % [atributo, ficha.atributo_efetivo(atributo)])
		atributos[id].text = " • ".join(valores.slice(0, 3)) + "\n" + " • ".join(valores.slice(3, 6))
		habilidades[id].text = combate.texto_passivas.text + "\nFísico Atlético • " + (ficha.talento_racial() if ficha.talento_racial() != "" else "Firmeza de Rocha") + "\nFicha completa no botão Ficha."
	else:
		var inimigo: RefCounted = combate.inimigos[id]
		atributos[id].text = "%s • nível %d\nFOR %+d • DES %+d • Defesa %d" % [inimigo.tipo, inimigo.nivel, inimigo.forca, inimigo.destreza, inimigo.defesa]
		var descricoes: Array[String] = []
		if inimigo.habilidades.get("passo_agil", {}).get("ativo", false):
			descricoes.append("Passo Ágil: uma casa grátis por rodada.")
		if inimigo.habilidades.get("golpe_sujo", {}).get("ativo", false):
			descricoes.append("Golpe Sujo: " + ("usado" if inimigo.golpe_sujo_usado else "disponível") + ". Teste DES/SAB, CD 12.")
		if inimigo.habilidades.get("me_protejam", {}).get("ativo", false):
			descricoes.append("Me Protejam!: transfere dano 5+ ou fatal a um goblin adjacente.")
		habilidades[id].text = "\n".join(descricoes)
