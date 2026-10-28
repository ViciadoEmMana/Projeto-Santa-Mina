extends Node2D

signal decisao_habilidade(confirmada: bool)
signal combate_finalizado(vitoria: bool)

const FichaBrokk = preload("res://ficha_zeno.gd")
const EstadoBrokk = preload("res://estado_combate_zeno.gd")
const Regras = preload("res://regras_combate.gd")
const GradeCombate = preload("res://grade_combate.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const EstadoInimigo = preload("res://estado_inimigo.gd")
const EfeitosCombate = preload("res://efeitos_combate.gd")
const InterfaceCombate = preload("res://interface_combate.gd")
const Adaptador = preload("res://adaptador_encontro.gd")
const RolagemArma = preload("res://rolagem_arma.gd")
const Dados3D = preload("res://dado_poliedrico.gd")
const Formacao = preload("res://formacao_inicial.gd")
const Trajetoria = preload("res://trajetoria_arco.gd")
const BrokkVisual = preload("res://scripts/presentation/brokk_visual.gd")
const CenarioCombate = preload("res://scripts/presentation/cenario_combate.gd")
const AudioAmbiente = preload("res://scripts/presentation/audio_ambiente.gd")
var sonoridade := AudioAmbiente.new()
var ambiente := "Covil de Tripa Seca"
var cenario: Node2D
var formacao := Formacao.new()
const Layout = preload("res://layout_combate.gd")
var apresentacao := Layout.new()
const Inspecao = preload("res://inspecao_combate.gd")
var inspecao := Inspecao.new()
const BarraCartas = preload("res://barra_cartas_basicas.gd")
var barra_cartas: Control
var ataque_carta := ""
var encontro := Adaptador.new()
var alimentos: RefCounted
var finalizacao_emitida := false
# -1 mantém a aleatoriedade normal; valor explícito permite reproduzir testes.
var semente_inicial := -1
var visual_ui := InterfaceCombate.new()
var numero_rodada := 0
var participantes_rodada: Array[String] = []

var efeitos := EfeitosCombate.new()
const ARMA_BANDIDO = Equipamentos.ARCO_CURTO

@onready var sprite_bandido: Sprite2D = $BandidoSprite
@onready var sprite_brokk: BrokkVisual = $BrokkSprite
@onready var dado_3d: Node3D = $DadoViewportContainer/DadoViewport/MundoDado/Dado3D
@onready var dado_bandido_3d: Node3D = $DadoViewportContainer/DadoViewport/MundoDado/DadoBandido3D
@onready var dado_iniciativa_brokk: Node3D = $DadoViewportContainer/DadoViewport/MundoDado/DadoIniciativaBrokk
@onready var dado_iniciativa_bandido: Node3D = $DadoViewportContainer/DadoViewport/MundoDado/DadoIniciativaBandido
@onready var visual_dado: SubViewportContainer = $DadoViewportContainer

const BANDIDO_VIDA_MAXIMA := 6
const BANDIDO_DEFESA := 0
const BANDIDO_DESTREZA := 1
const BANDIDO_BONUS_ATAQUE := 1

# Os IDs/nós "Brokk" são legados: o protagonista exibido vem da ficha.
var ficha_brokk: RefCounted = FichaBrokk.new()
var estado_brokk: RefCounted = EstadoBrokk.new(ficha_brokk.pv_maximos())
var vida_brokk: int:
	get:
		return estado_brokk.pv_atuais
	set(valor):
		estado_brokk.pv_atuais = valor

var inimigos := {
	"Bandido": EstadoInimigo.new("Bandido Arqueiro", BANDIDO_VIDA_MAXIMA, 0, BANDIDO_DESTREZA, ARMA_BANDIDO),
	"Porrete": EstadoInimigo.new("Bandido do Porrete", 8, 2, 0, Equipamentos.PORRETE),
}
# Mantém os acessos existentes ao arqueiro, com uma única fonte de estado.
var vida_bandido: int:
	get: return inimigos["Bandido"].pv_atuais
	set(valor): inimigos["Bandido"].pv_atuais = valor
var pa_bandido: int:
	get: return inimigos["Bandido"].pa_atuais
	set(valor): inimigos["Bandido"].pa_atuais = valor
var pa_debito_bandido: int:
	get: return inimigos["Bandido"].pa_debito_pendente
	set(valor): inimigos["Bandido"].pa_debito_pendente = valor
var alvo_selecionado := "Bandido"
var ordem_turnos: Array[String] = []
var iniciativas: Dictionary = {}
var historico_turnos: Array[String] = []
var sprite_porrete: Sprite2D
var escudo_visual: Polygon2D
var porrete_visual: Polygon2D
var painel_porrete: PanelContainer
var texto_vida_porrete: Label
var barra_vida_porrete: ProgressBar
var texto_iniciativa_porrete: Label
var dado_iniciativa_porrete: Node3D
var numeros_iniciativa_porrete: Array[Label3D]
var gerador := RandomNumberGenerator.new()
var grade := GradeCombate.new()
var total_iniciativa_brokk := 0
var primeiro_a_agir := ""
var selecionando_posicao := false
var posicionamento_concluido := false
var modo_movimento := ""
var movimento_em_andamento := false
var ultimo_ataque: Dictionary = {}
var ultimos_dados_brokk: Array[int] = []
var ultimos_dados_bandido: Array[int] = []
var fontes_vantagem_bandido: Array[String] = []
var fontes_desvantagem_bandido: Array[String] = []

var painel_brokk: PanelContainer
var painel_bandido: PanelContainer
var texto_vida_brokk: Label
var barra_vida_brokk: ProgressBar
var texto_vida_bandido: Label
var texto_arma_bandido: Label
var barra_vida_bandido: ProgressBar
var texto_iniciativa_brokk: Label
var texto_iniciativa_bandido: Label
var texto_resultado: Label
var texto_dado: Label
var botao_atacar: Button
var botao_ficha: Button
var botao_vantagem: Button
var botao_defender: Button
var botao_mover: Button
var botao_correr: Button
var botao_encerrar: Button
var texto_turno: Label
var texto_passivas: Label
var dialogo_habilidade: ConfirmationDialog
var dialogo_ficha: AcceptDialog
var texto_ficha: Label
var aguardando_decisao := false
var rolagem_em_andamento := false
var iniciativa_concluida := false
var turno_atual := ""
var numeros_iniciativa_brokk: Array[Label3D]
var numeros_iniciativa_bandido: Array[Label3D]


func _enter_tree() -> void:
	# Antes do _ready do ator: preserva o controlador e troca só o recurso visual.
	if ficha_brokk.ID == "zeno":
		var ator := get_node("BrokkSprite")
		ator.quadros_principais = load("res://assets/characters/zeno/zeno_animacoes.tres")
		ator.quadros_complementares = null


func _ready() -> void:
	if estado_brokk.has_method("iniciar_combate") and not estado_brokk.combate_ativo:
		estado_brokk.iniciar_combate()
	if semente_inicial < 0:
		gerador.randomize()
	else:
		gerador.seed = semente_inicial
	apresentacao.preparar_arena(self)
	apresentacao.arena_visual.add_child(efeitos)
	add_child(sonoridade)
	sonoridade.configurar(ambiente)
	grade.position = Vector2(44, 190)
	add_child(grade)
	move_child(grade, 0)
	grade.casa_clicada.connect(_ao_clicar_casa)
	grade.posicoes["Porrete"] = Vector2i(4, 2)
	grade.nao_posicionados.assign(["Brokk"] + _inimigos_vivos())
	_criar_visuais_equipamentos()
	sprite_brokk.scale = Vector2.ONE
	sprite_bandido.scale = Vector2(1.8, 1.8)
	_sincronizar_sprites()
	visual_dado.position = Vector2(663, 154)
	visual_dado.size = Vector2(320, 140)
	visual_dado.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	$DadoViewportContainer/DadoViewport.msaa_3d = Viewport.MSAA_2X
	# Garante a atualização do SubViewport enquanto o cubo estiver animando.
	$DadoViewportContainer/DadoViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE
	visual_dado.visible = true
	dado_3d.visible = false
	dado_bandido_3d.visible = false
	dado_iniciativa_brokk.visible = true
	dado_iniciativa_bandido.visible = true
	# Mantém inclusive os cantos dos cubos dentro do viewport enquanto giram.
	dado_iniciativa_brokk.scale = Vector3.ONE * 0.85
	dado_iniciativa_bandido.scale = Vector3.ONE * 0.85
	numeros_iniciativa_brokk = _criar_numeros_iniciativa(dado_iniciativa_brokk)
	numeros_iniciativa_bandido = _criar_numeros_iniciativa(dado_iniciativa_bandido)
	dado_iniciativa_porrete = dado_iniciativa_bandido.duplicate()
	dado_iniciativa_porrete.name = "DadoIniciativaPorrete"
	dado_iniciativa_bandido.get_parent().add_child(dado_iniciativa_porrete)
	# Retira somente os números duplicados antes de criar referências próprias.
	for filho in dado_iniciativa_porrete.get_children():
		if filho is Label3D:
			dado_iniciativa_porrete.remove_child(filho)
			filho.queue_free()
	numeros_iniciativa_porrete = _criar_numeros_iniciativa(dado_iniciativa_porrete)
	dado_iniciativa_brokk.position.x = -1.4
	dado_iniciativa_bandido.position.x = 0.0
	dado_iniciativa_porrete.position.x = 1.4
	for dado in [dado_iniciativa_brokk, dado_iniciativa_bandido, dado_iniciativa_porrete]:
		dado.scale = Vector3.ONE * 0.55
	_criar_faces_dado(dado_3d, Color("30251c"))
	_criar_faces_dado(dado_bandido_3d, Color("fff0e8"))
	_criar_interface()
	encontro.preparar(self)
	cenario = CenarioCombate.new()
	add_child(cenario)
	move_child(cenario, 0)
	cenario.configurar(ambiente)
	grade.opacidade_piso = 0.18
	add_child(inspecao)
	apresentacao.criar(self)
	if ficha_brokk.ID == "zeno":
		apresentacao.texto_pa.add_theme_font_size_override("font_size", 16)
		var quadros: SpriteFrames = sprite_brokk.animacao.sprite_frames
		var poses := {"atacar": [&"ataque", 4], "defender": [&"defesa", 2], "mover": [&"caminhar", 2], "correr": [&"correr", 2], "vantagem": [&"ataque", 0]}
		for id in poses:
			var arte: AtlasTexture = quadros.get_frame_texture(poses[id][0], poses[id][1]).duplicate()
			arte.margin = Rect2() # Cartas usam o recorte, sem as margens de animação.
			barra_cartas.cartas[id].arte = arte
			barra_cartas.cartas[id].definicao["arte"] = arte
	_sincronizar_sprites()
	estado_brokk.alterado.connect(_atualizar_interface)
	estado_brokk.condicoes.alterado.connect(_atualizar_interface)
	for inimigo in inimigos.values():
		inimigo.alterado.connect(_atualizar_interface)
		inimigo.condicoes.alterado.connect(_atualizar_interface)
	_atualizar_interface()
	queue_redraw()
	botao_atacar.disabled = true
	await _rolar_iniciativa()


func _draw() -> void:
	var tamanho_tela := get_viewport_rect().size
	if is_instance_valid(cenario):
		draw_rect(Rect2(Vector2.ZERO, tamanho_tela), Color("171c25"))
		return
	# Fundo de pedra e gradiente de luz quente no centro da masmorra.
	draw_rect(Rect2(Vector2.ZERO, tamanho_tela), Color("17171d"))
	draw_rect(Rect2(0, 0, tamanho_tela.x, 365), Color("28262b"))
	draw_rect(Rect2(0, 355, tamanho_tela.x, 185), Color("3b3028"))
	draw_rect(Rect2(0, 350, tamanho_tela.x, 10), Color("79604a"))
	draw_rect(Rect2(605, 169, 335, 285), Color("201e25"))

	# Blocos de pedra do cenário.
	for x in range(0, 1000, 120):
		draw_line(Vector2(x, 70), Vector2(x + 120, 70), Color("51484a"), 3.0)
		draw_line(Vector2(x + 55, 72), Vector2(x + 55, 145), Color("51484a"), 3.0)
		draw_line(Vector2(x - 30, 145), Vector2(x + 90, 145), Color("51484a"), 3.0)
		draw_line(Vector2(x + 5, 147), Vector2(x + 5, 220), Color("51484a"), 3.0)
		draw_line(Vector2(x, 220), Vector2(x + 120, 220), Color("51484a"), 3.0)
		draw_line(Vector2(x + 75, 222), Vector2(x + 75, 300), Color("51484a"), 3.0)

	# Tochas e sombras no fundo.
	draw_circle(Vector2(140, 190), 43, Color(0.95, 0.42, 0.12, 0.10))
	draw_circle(Vector2(140, 190), 25, Color(0.95, 0.42, 0.12, 0.14))
	draw_colored_polygon(PackedVector2Array([Vector2(135, 207), Vector2(145, 207), Vector2(143, 175), Vector2(138, 168)]), Color("b88754"))
	draw_colored_polygon(PackedVector2Array([Vector2(133, 181), Vector2(140, 159), Vector2(146, 181), Vector2(140, 190)]), Color("ffb347"))
	draw_circle(Vector2(800, 198), 35, Color(0.72, 0.18, 0.11, 0.08))

	if vida_bandido <= 0:
		_desenhar_bandido_derrotado()


func _desenhar_elipse(centro: Vector2, raios: Vector2, cor: Color) -> void:
	var pontos := PackedVector2Array()
	for indice in range(24):
		var angulo := TAU * float(indice) / 24.0
		pontos.append(centro + Vector2(cos(angulo) * raios.x, sin(angulo) * raios.y))
	draw_colored_polygon(pontos, cor)


func _desenhar_bandido_derrotado() -> void:
	var centro := sprite_bandido.position + Vector2(0, 20)
	_desenhar_elipse(centro, Vector2(27, 7), Color("17151a"))
	draw_line(centro - Vector2(20, 5), centro + Vector2(12, -5), Color("684b3c"), 12.0)
	draw_circle(centro + Vector2(21, -7), 9, Color("b98c68"))


func _criar_faces_dado(dado: Node3D, _cor: Color) -> void:
	Dados3D.configurar(dado, 6, Color("254ea2") if dado == dado_3d else Color("a13538"))


func _adicionar_face_dado(dado: Node3D, numero: String, posicao: Vector3, rotacao: Vector3, cor: Color) -> Label3D:
	var face := Label3D.new()
	face.text = numero
	face.position = posicao
	face.rotation = rotacao
	face.font_size = 48
	face.pixel_size = 0.006
	face.modulate = cor
	face.shaded = false
	face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Corrige o espelhamento causado pela rotação de cada face do cubo.
	if absf(rotacao.x) > 0.1:
		face.scale.y = -1.0
	else:
		face.scale.x = -1.0
	dado.add_child(face)
	return face


func _criar_interface() -> void:
	var camada_ui := CanvasLayer.new()
	add_child(camada_ui)
	var titulo := Label.new()
	titulo.text = "SANTA MINA / COMBATE"
	titulo.position = Vector2(24, 7)
	titulo.add_theme_font_size_override("font_size", 17)
	titulo.add_theme_color_override("font_color", Color("e6be69"))
	camada_ui.add_child(titulo)

	painel_brokk = _criar_painel(camada_ui, Vector2(24, 40), Vector2(365, 132))
	var coluna := _criar_coluna(painel_brokk, ficha_brokk.NOME.to_upper())
	coluna.add_theme_constant_override("separation", 0)
	_adicionar_label(coluna, "%s • Guerreiro nível 1" % ficha_brokk.RACA["nome"], 10, Color("c9c0af"))
	texto_vida_brokk = _adicionar_label(coluna, "", 13, Color("f1e7d0"))
	barra_vida_brokk = _adicionar_barra(coluna, Color("71965b"))
	barra_vida_brokk.custom_minimum_size.y = 8
	_adicionar_label(coluna, "%s (1H, 1d6) • Escudo de Madeira e Ferro (1H)" % ficha_brokk.arma_atual()["nome"], 10, Color("c9c0af"))
	texto_iniciativa_brokk = _adicionar_label(coluna, "%s | aguardando iniciativa" % ficha_brokk.NOME, 10, Color("c9c0af"))

	painel_bandido = _criar_painel(camada_ui, Vector2(405, 40), Vector2(257, 104))
	var inimigo := _criar_coluna(painel_bandido, "BANDIDO ARQUEIRO")
	inimigo.add_theme_constant_override("separation", 1)
	texto_vida_bandido = _adicionar_label(inimigo, "", 13, Color("f1e7d0"))
	barra_vida_bandido = _adicionar_barra(inimigo, Color("a9574b"))
	texto_arma_bandido = _adicionar_label(inimigo, "", 10, Color("c9c0af"))
	texto_iniciativa_bandido = _adicionar_label(inimigo, "Arqueiro | aguardando iniciativa", 10, Color("c9c0af"))
	painel_porrete = _criar_painel(camada_ui, Vector2(679, 40), Vector2(257, 104))
	var coluna_porrete := _criar_coluna(painel_porrete, "BANDIDO DO PORRETE")
	coluna_porrete.add_theme_constant_override("separation", 1)
	texto_vida_porrete = _adicionar_label(coluna_porrete, "", 13, Color("f1e7d0"))
	barra_vida_porrete = _adicionar_barra(coluna_porrete, Color("a95732"))
	_adicionar_label(coluna_porrete, "Porrete (1H) • 1d6+2 • DES 0 • Def 0", 10, Color("c9c0af"))
	texto_iniciativa_porrete = _adicionar_label(coluna_porrete, "Porrete | aguardando iniciativa", 10, Color("c9c0af"))

	botao_ficha = Button.new()
	botao_ficha.text = "Ficha"
	botao_ficha.position = Vector2(305, 6)
	botao_ficha.size = Vector2(84, 28)
	botao_ficha.pressed.connect(_abrir_ficha)
	camada_ui.add_child(botao_ficha)
	texto_turno = Label.new()
	texto_turno.position = Vector2(405, 7)
	texto_turno.size = Vector2(531, 32)
	texto_turno.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_turno.add_theme_font_size_override("font_size", 11)
	camada_ui.add_child(texto_turno)

	texto_dado = Label.new()
	texto_dado.position = Vector2(610, 290)
	texto_dado.size = Vector2(326, 31)
	texto_dado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_dado.add_theme_font_size_override("font_size", 13)
	texto_dado.add_theme_color_override("font_color", Color("f2d28b"))
	camada_ui.add_child(texto_dado)
	texto_passivas = Label.new()
	texto_passivas.position = Vector2(610, 346)
	texto_passivas.size = Vector2(326, 32)
	texto_passivas.add_theme_font_size_override("font_size", 10)
	texto_passivas.add_theme_color_override("font_color", Color("e8d9bc"))
	camada_ui.add_child(texto_passivas)
	texto_resultado = Label.new()
	texto_resultado.position = Vector2(610, 370)
	texto_resultado.size = Vector2(326, 84)
	texto_resultado.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_resultado.add_theme_font_size_override("font_size", 11)
	texto_resultado.add_theme_color_override("font_color", Color("eadfc9"))
	camada_ui.add_child(texto_resultado)
	texto_resultado.visible = false
	visual_ui.criar_lateral(camada_ui)

	dialogo_habilidade = ConfirmationDialog.new()
	dialogo_habilidade.dialog_autowrap = true
	dialogo_habilidade.get_label().add_theme_font_size_override("font_size", 15)
	dialogo_habilidade.confirmed.connect(_responder_habilidade.bind(true))
	dialogo_habilidade.canceled.connect(_responder_habilidade.bind(false))
	camada_ui.add_child(dialogo_habilidade)
	dialogo_ficha = AcceptDialog.new()
	dialogo_ficha.title = "Ficha de " + ficha_brokk.NOME
	var rolagem_ficha := ScrollContainer.new()
	rolagem_ficha.custom_minimum_size = Vector2(650, 360)
	rolagem_ficha.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dialogo_ficha.add_child(rolagem_ficha)
	texto_ficha = Label.new()
	texto_ficha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto_ficha.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_ficha.add_theme_font_size_override("font_size", 13)
	rolagem_ficha.add_child(texto_ficha)
	camada_ui.add_child(dialogo_ficha)

	var linha := HBoxContainer.new()
	linha.position = Vector2(24, 464)
	linha.size = Vector2(912, 248)
	linha.add_theme_constant_override("separation", 9)
	camada_ui.add_child(linha)
	barra_cartas = BarraCartas.new()
	barra_cartas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra_cartas.acao_solicitada.connect(_ao_usar_carta)
	linha.add_child(barra_cartas)
	# Referências anteriores apontam para o único controle de cada ação.
	botao_atacar = barra_cartas.cartas["atacar"]
	botao_defender = barra_cartas.cartas["defender"]
	botao_mover = barra_cartas.cartas["mover"]
	botao_correr = barra_cartas.cartas["correr"]
	botao_vantagem = barra_cartas.cartas["vantagem"]
	botao_encerrar = _botao_acao(linha, "Encerrar turno", _encerrar_turno)
	botao_encerrar.size_flags_horizontal = Control.SIZE_FILL
	botao_encerrar.size_flags_vertical = Control.SIZE_SHRINK_END
	botao_encerrar.custom_minimum_size.x = 115

	visual_ui.completar_cartao("Brokk", painel_brokk, coluna)
	visual_ui.completar_cartao("Bandido", painel_bandido, inimigo)
	visual_ui.completar_cartao("Porrete", painel_porrete, coluna_porrete)
	visual_ui.rotulos_armas["Brokk"] = coluna.get_child(5)
	visual_ui.rotulos_armas["Bandido"] = texto_arma_bandido
	visual_ui.rotulos_armas["Porrete"] = coluna_porrete.get_child(4)
	InterfaceCombate.preparar_botao(botao_encerrar, "encerrar")
	InterfaceCombate.preparar_botao(botao_ficha, "habilidades")


func _ao_usar_carta(id: String) -> void:
	if not _pode_agir() or not barra_cartas.cartas.has(id):
		return
	# Revalida no clique: a aparência nunca autoriza uma ação com estado antigo.
	_atualizar_interface()
	if barra_cartas.cartas[id].disabled:
		return
	match id:
		"atacar", "vantagem":
			if ataque_carta == id:
				_limpar_selecao()
				_mensagem("Seleção cancelada, sem gastar PA.")
			else:
				_limpar_selecao()
				ataque_carta = id
				_mensagem("%s selecionado: clique em um inimigo destacado para confirmar. Esc cancela sem custo." % barra_cartas.cartas[id].definicao["nome"])
		"defender":
			_defender()
		"mover", "correr":
			_selecionar_movimento(id == "correr")
	_atualizar_interface()


func _alvos_cartas_ataque() -> Array[String]:
	var validos: Array[String] = []
	for id in _inimigos_vivos():
		if Equipamentos.avaliar_alcance(ficha_brokk.arma_atual(), grade.posicoes["Brokk"], grade.posicoes[id], Vector2i(grade.COLUNAS, grade.LINHAS))["permitido"] and _linha_arco_livre(ficha_brokk.arma_atual(), grade.posicoes["Brokk"], grade.posicoes[id]):
			validos.append(id)
	return validos


func _botao_acao(pai: HBoxContainer, texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, 42)
	botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	botao.add_theme_font_size_override("font_size", 13)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func _criar_painel(pai: Node, posicao: Vector2, tamanho: Vector2) -> PanelContainer:
	var painel := PanelContainer.new()
	painel.position = posicao
	painel.size = tamanho
	painel.add_theme_stylebox_override("panel", InterfaceCombate.estilo())
	pai.add_child(painel)
	return painel


func _criar_coluna(painel: PanelContainer, titulo: String) -> VBoxContainer:
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 4)
	painel.add_child(coluna)
	var label_titulo := _adicionar_label(coluna, titulo, 14, Color("d9ae70"))
	label_titulo.add_theme_font_size_override("font_size", 14)
	return coluna


func _adicionar_label(pai: Control, texto: String, tamanho_fonte: int, cor: Color) -> Label:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", tamanho_fonte)
	label.add_theme_color_override("font_color", cor)
	pai.add_child(label)
	return label


func _adicionar_barra(pai: Control, cor: Color) -> ProgressBar:
	var barra := InterfaceCombate.barra(Color("b84740"), 7)
	pai.add_child(barra)
	return barra


func _pode_agir() -> bool:
	return posicionamento_concluido and turno_atual == "Brokk" and not rolagem_em_andamento and not movimento_em_andamento and vida_brokk > 0 and not _inimigos_vivos().is_empty()


func _mensagem(texto: String) -> void:
	var anterior := texto_resultado.text
	visual_ui.registrar(texto.trim_prefix(anterior + "\n") if not anterior.is_empty() and texto.begins_with(anterior + "\n") else texto)
	texto_resultado.text = texto
	texto_resultado.tooltip_text = texto


func _pagar_acao(acao: String) -> bool:
	if not _pode_agir():
		return false
	var custo: int = Regras.CUSTOS[acao]
	if not estado_brokk.gastar_pa(custo):
		_mensagem("PA insuficientes: %s custa %d PA; %s tem %d." % [acao, custo, ficha_brokk.NOME, estado_brokk.pa_atuais])
		return false
	_limpar_selecao()
	return true


func _ao_atacar() -> void:
	await _ataque_brokk(false)


func _atacar_com_vantagem() -> void:
	await _ataque_brokk(true)


func _ataque_brokk(vantagem: bool) -> void:
	if not _pode_agir() or not inimigos.has(alvo_selecionado) or inimigos[alvo_selecionado].pv_atuais <= 0:
		return
	if not _verificar_alcance("Brokk", alvo_selecionado, ficha_brokk.arma_atual()):
		return
	if not _pagar_acao("vantagem" if vantagem else "atacar"):
		return
	rolagem_em_andamento = true
	var alvo: String = alvo_selecionado
	Dados3D.configurar(dado_3d, ficha_brokk.dado_ataque(), Color("254ea2"))
	var teste_golpe := await _reagir_golpe_sujo(alvo)
	if not teste_golpe.is_empty() and not teste_golpe["sucesso"]:
		ultimo_ataque = Regras.ataque_fisico(1, 0, {})
		ultimo_ataque.merge({"natural": 0, "atacante": "Brokk", "alvo": alvo, "dano_recebido": 0, "golpe_sujo": teste_golpe, "dados": []}, true)
		ultimos_dados_brokk.clear()
		_mensagem("Golpe Sujo: %s falhou no teste. Ataque erra automaticamente: 0 de dano; PA do ataque gastos." % ficha_brokk.NOME)
		rolagem_em_andamento = false
		_atualizar_interface()
		return
	visual_dado.visible = true
	dado_3d.visible = true
	dado_bandido_3d.visible = false
	ultimos_dados_brokk.clear()
	_mensagem("%s prepara o ataque..." % ficha_brokk.NOME)
	_atualizar_interface()
	var modo := _modo_ataque_brokk(vantagem)
	for indice in range(Regras.quantidade_dados(modo)):
		texto_dado.text = "Rolando d%d %d..." % [ficha_brokk.dado_ataque(), indice + 1]
		var natural := gerador.randi_range(1, ficha_brokk.dado_ataque())
		ultimos_dados_brokk.append(natural)
		await _animar_dado(dado_3d, natural)
	var escolhido := Regras.indice_resultado(ultimos_dados_brokk, modo)
	var resultado_dado := Regras.selecionar_natural(ultimos_dados_brokk, modo)
	_mostrar_dados_brokk(resultado_dado, modo)
	if not estado_brokk.mestre_armas_usado:
		var aviso := "Repetir o natural %d?" % resultado_dado
		if modo == "vantagem":
			aviso = "Vantagem: %d e %d. Repetir somente o maior (%d)? O outro dado permanece." % [ultimos_dados_brokk[0], ultimos_dados_brokk[1], resultado_dado]
		var repetir := await _perguntar_habilidade("Mestre das Armas", aviso + "\n0 PA, uma vez por combate. O novo valor substitui obrigatoriamente o dado repetido.", "Repetir dado (0 PA)", "Manter resultado")
		if repetir and estado_brokk.confirmar_mestre_armas():
			texto_dado.text = "Mestre das Armas: rolando..."
			var novo := gerador.randi_range(1, ficha_brokk.dado_ataque())
			ultimos_dados_brokk[escolhido] = novo
			await _animar_dado(dado_3d, novo)
			resultado_dado = Regras.selecionar_natural(ultimos_dados_brokk, modo)
			_mostrar_dados_brokk(resultado_dado, modo)
	# Repetição da Espada é outra habilidade, com limite próprio e sem novo PA.
	if resultado_dado == 1 and estado_brokk.has_method("confirmar_repeticao_espada") and not estado_brokk.espada_repeticao_usada and Equipamentos.permite_repetir_erro(ficha_brokk.arma_atual(), {"FOR": ficha_brokk.atributo_efetivo("FOR"), "DES": ficha_brokk.atributo_efetivo("DES")}):
		var repetir_espada := await _perguntar_habilidade("Espada de Ferro", "O ataque terminou em natural 1. Repetir o ataque errado?\nUma vez por combate, sem novo custo de PA. Mantém o modo de rolagem; os novos dados substituem os anteriores.", "Repetir ataque", "Manter erro")
		if repetir_espada and estado_brokk.confirmar_repeticao_espada():
			ultimos_dados_brokk.clear()
			for indice in range(Regras.quantidade_dados(modo)):
				var novo := gerador.randi_range(1, ficha_brokk.dado_ataque())
				ultimos_dados_brokk.append(novo)
				texto_dado.text = "Espada de Ferro: rolando..."
				await _animar_dado(dado_3d, novo)
			resultado_dado = Regras.selecionar_natural(ultimos_dados_brokk, modo)
			_mostrar_dados_brokk(resultado_dado, modo)
	if ficha_brokk.talento_racial() == "Veterano de Batalha" and estado_brokk.registrar_ataque(resultado_dado, ficha_brokk.dado_ataque()):
		visual_ui.registrar("Veterano de Batalha: Dano +1 até o fim do combate.")
		await efeitos.apresentar_veterano("dano", sprite_brokk)
	var bonus_veterano: int = estado_brokk.bonus_veterano_dano if ficha_brokk.talento_racial() == "Veterano de Batalha" else 0
	var fogo := await _avaliar_fogo_amigo("Brokk", alvo, ficha_brokk.arma_atual(), resultado_dado)
	var alvo_resolvido: String = alvo if fogo.is_empty() else fogo["alvo"]
	var resultado_dano: int = resultado_dado if fogo.is_empty() else fogo["total"]
	ultimo_ataque = Regras.ataque_fisico(resultado_dano, ficha_brokk.atributo_ataque(), _fontes_defesa_alvo(alvo_resolvido, resultado_dado), ficha_brokk.bonus_arma(resultado_dado) + _bonus_alimentar("dano_armas") + bonus_veterano, false, fogo.is_empty())
	ultimo_ataque["bonus_arma"] = ficha_brokk.bonus_arma(resultado_dado)
	ultimo_ataque["bonus_alimento"] = _bonus_alimentar("dano_armas")
	ultimo_ataque["bonus_veterano"] = bonus_veterano
	ultimo_ataque["golpe_sujo"] = teste_golpe
	ultimo_ataque["natural"] = resultado_dado
	ultimo_ataque["fogo_amigo"] = not fogo.is_empty()
	ultimo_ataque["dados_dano"] = fogo.get("dados", [])
	if not fogo.is_empty():
		ultimo_ataque["expressao"] = "FOGO AMIGO! Ataque %d; dano %s %+d" % [resultado_dado, str(fogo["dados"]), ficha_brokk.atributo_ataque()]
	ultimo_ataque["atacante"] = "Brokk"
	ultimo_ataque["alvo"] = alvo
	ultimo_ataque["modo"] = modo
	ultimo_ataque["dados"] = ultimos_dados_brokk.duplicate()
	ultimo_ataque["dano_recebido"] = ultimo_ataque["dano"]
	# Dano final já inclui a Defesa do alvo original. Transferir só uma vez.
	var protetor := _protetor_me_protejam(alvo_resolvido, ultimo_ataque["dano"])
	var alvo_dano := alvo_resolvido if protetor.is_empty() else protetor
	ultimo_ataque["alvo_dano"] = alvo_dano
	ultimo_ataque["me_protejam"] = not protetor.is_empty()
	ultimo_ataque["dano_alvo_original"] = 0 if not protetor.is_empty() else ultimo_ataque["dano"]
	if not protetor.is_empty():
		_mensagem("TRIPA SECA: ME PROTEJAM, SEUS INÚTEIS!")
	var sprite_alvo: Sprite2D = encontro.sprites[alvo_dano]
	if not protetor.is_empty():
		await efeitos.apresentar_reacao_chefe("me_protejam", encontro.sprites[alvo_resolvido], sprite_alvo)
	if ficha_brokk.arma_atual()["tipo"] == "corpo_a_corpo":
		sprite_brokk.olhar_para(sprite_alvo.position - sprite_brokk.position)
		await sprite_brokk.animar_ataque_ate_impacto()
	await efeitos.apresentar(ficha_brokk.arma_atual(), ultimo_ataque.duplicate(true), sprite_brokk, sprite_alvo)
	inimigos[alvo_dano].pv_atuais -= int(ultimo_ataque["dano"])
	var transferencia := "" if protetor.is_empty() else "\nMe Protejam!: %s recebeu integralmente %d de dano; Tripa Seca recebeu 0. Sem recalcular Defesa." % [inimigos[protetor].nome, ultimo_ataque["dano"]]
	_mensagem(_descrever_ataque(ficha_brokk.NOME, inimigos[alvo_dano].nome, ficha_brokk.atributo_ataque(), inimigos[alvo_dano].pv_atuais, inimigos[alvo_dano].pv_maximos) + transferencia)
	if inimigos[alvo_dano].pv_atuais == 0:
		visual_ui.registrar("Derrota: " + inimigos[alvo_dano].nome)
	_sincronizar_sprites()
	_atualizar_interface()
	await get_tree().create_timer(1.2).timeout
	dado_3d.visible = false
	visual_dado.visible = false
	rolagem_em_andamento = false
	_verificar_fim_combate()
	if inimigos[alvo].pv_atuais == 0 and not _inimigos_vivos().is_empty():
		alvo_selecionado = _inimigos_vivos()[0]
	# O ataque gasta PA, mas o jogador decide quando encerrar o turno.
	_atualizar_interface()


func _protetor_me_protejam(alvo: String, dano_final: int) -> String:
	if not inimigos.has(alvo) or not grade.posicoes.has(alvo):
		return ""
	var chefe: RefCounted = inimigos[alvo]
	var habilidade: Dictionary = chefe.habilidades.get("me_protejam", {})
	if not habilidade.get("ativo", false) or chefe.pv_atuais <= 0 or dano_final <= 0:
		return ""
	if dano_final < int(habilidade["dano_alto"]) and dano_final < chefe.pv_atuais:
		return ""
	var escolhido := ""
	var ids: Array = inimigos.keys()
	ids.sort() # Ordem estável de IDs desempata PV iguais.
	for id: String in ids:
		var aliado: RefCounted = inimigos[id]
		if id == alvo or aliado.pv_atuais <= 0 or not aliado.ficha_id.begins_with("goblin_") or not grade.posicoes.has(id):
			continue
		if _distancia(grade.posicoes[id], grade.posicoes[alvo]) > int(habilidade["distancia"]):
			continue
		if escolhido.is_empty() or aliado.pv_atuais > inimigos[escolhido].pv_atuais:
			escolhido = id
	return escolhido


func _reagir_golpe_sujo(alvo: String) -> Dictionary:
	var inimigo: RefCounted = inimigos[alvo]
	if not inimigo.pode_usar_golpe_sujo(ficha_brokk.arma_atual()):
		return {}
	# Chamado somente depois da validação de alvo, alcance e pagamento do ataque.
	inimigo.consumir_golpe_sujo()
	await efeitos.apresentar_reacao_chefe("golpe_sujo", encontro.sprites[alvo], sprite_brokk)
	var usar_destreza := await _perguntar_habilidade("Golpe Sujo — escolha o teste", "Tripa Seca joga areia nos olhos do atacante!
Escolha Destreza ou Sabedoria: 1d20 + modificador, CD 12.
Falha: o ataque erra e os PA permanecem gastos.", "Destreza (%+d)" % ficha_brokk.atributo_efetivo("DES"), "Sabedoria (%+d)" % ficha_brokk.atributo_efetivo("SAB"))
	var atributo := "DES" if usar_destreza else "SAB"
	var natural := gerador.randi_range(1, 20)
	var bonus: int = ficha_brokk.atributo_efetivo(atributo)
	var total := natural + bonus
	var teste := {"atributo": atributo, "natural": natural, "bonus": bonus, "total": total, "cd": 12, "sucesso": total >= 12}
	var posicao_anterior := dado_iniciativa_brokk.position
	var escala_anterior := dado_iniciativa_brokk.scale
	dado_iniciativa_brokk.position = Vector3.ZERO
	dado_iniciativa_brokk.scale = Vector3.ONE * 0.85
	_definir_numeros_dado(numeros_iniciativa_brokk, str(natural))
	visual_dado.visible = true
	dado_iniciativa_brokk.visible = true
	texto_dado.text = "Teste %s: d20..." % atributo
	await _animar_dado(dado_iniciativa_brokk, natural)
	texto_dado.text = "%s: %d %+d = %d / CD 12" % [atributo, natural, bonus, total]
	_mensagem("Golpe Sujo — %s: d20 %d %+d = %d; CD 12: %s." % [atributo, natural, bonus, total, "sucesso, ataque prossegue" if teste["sucesso"] else "falha, ataque erra"])
	await get_tree().create_timer(1.2).timeout
	dado_iniciativa_brokk.visible = false
	dado_iniciativa_brokk.position = posicao_anterior
	dado_iniciativa_brokk.scale = escala_anterior
	visual_dado.visible = false
	return teste


func _fontes_defesa_alvo(id: String, natural: int) -> Dictionary:
	return _fontes_defesa_brokk(natural) if id == "Brokk" else {"base": inimigos[id].defesa}

func _linha_arco_livre(arma: Dictionary, origem: Vector2i, alvo: Vector2i) -> bool:
	if not arma.get("fogo_amigo", false):
		return true
	for obstaculo in grade.obstaculos:
		if Trajetoria.atravessa_obstaculo(origem, alvo, obstaculo):
			return false
	return true

func _avaliar_fogo_amigo(atacante: String, alvo: String, arma: Dictionary, natural: int) -> Dictionary:
	var vivos: Array[String] = _inimigos_vivos()
	if vida_brokk > 0:
		vivos.append("Brokk")
	var interceptacao := Trajetoria.primeiro(grade.posicoes[atacante], grade.posicoes[alvo], grade.posicoes, vivos, grade.obstaculos)
	if not Trajetoria.ativar(arma, natural, interceptacao):
		return {}
	var rolagem := RolagemArma.sortear(arma, "normal", gerador)
	var dado := dado_3d if atacante == "Brokk" else dado_bandido_3d
	Dados3D.configurar(dado, arma["dado"], Color("254ea2") if atacante == "Brokk" else Color("a13538"))
	_mensagem("FOGO AMIGO! A flecha atingiu %s! Rolando o dano da arma, sem novo custo de PA." % _nome_participante(interceptacao["id"]))
	for valor in rolagem["selecionados"]:
		await _animar_dado(dado, valor)
	texto_dado.text = "Ataque %d • dano %s" % [natural, str(rolagem["selecionados"])]
	return {"alvo": interceptacao["id"], "dados": rolagem["selecionados"], "total": rolagem["total"]}

func _modo_ataque_brokk(vantagem_comprada: bool = false) -> String:
	var vantagens: Array[String] = estado_brokk.fontes_vantagem.duplicate()
	if vantagem_comprada:
		vantagens.append("acao_com_vantagem")
	if inimigos.has(alvo_selecionado) and inimigos[alvo_selecionado].condicoes.derrubado:
		vantagens.append("alvo_derrubado")
	var desvantagens: Array[String] = estado_brokk.fontes_desvantagem.duplicate()
	var posicoes_alvos: Array[Vector2i] = []
	for id in _inimigos_vivos():
		posicoes_alvos.append(grade.posicoes[id])
	if Equipamentos.desvantagem_por_proximidade(ficha_brokk.arma_atual(), grade.posicoes["Brokk"], posicoes_alvos):
		desvantagens.append("arco_proximidade_ortogonal")
	return Regras.resolver_fontes_rolagem(vantagens, desvantagens)


func _mostrar_dados_brokk(resultado: int, modo: String = "normal") -> void:
	dado_3d.rotation = Dados3D.orientacao(dado_3d, resultado)
	texto_dado.text = "D%d: %d" % [ficha_brokk.dado_ataque(), resultado]
	if ultimos_dados_brokk.size() == 2:
		texto_dado.text = "%s: %d e %d | usado: %d" % [modo.capitalize(), ultimos_dados_brokk[0], ultimos_dados_brokk[1], resultado]


func _fontes_defesa_brokk(natural: int) -> Dictionary:
	var fontes := {"natural": ficha_brokk.bonus_pele_rocha(vida_brokk), "escudo": ficha_brokk.bonus_escudo(natural), "temporaria": estado_brokk.bonus_defesa_temporaria}
	if ficha_brokk.talento_racial() == "Veterano de Batalha":
		fontes["veterano"] = estado_brokk.bonus_veterano_defesa
	return fontes


func _verificar_alcance(atacante: String, alvo: String, arma: Dictionary) -> bool:
	if not grade.posicoes.has(atacante) or not grade.posicoes.has(alvo):
		return false
	var alcance := Equipamentos.avaliar_alcance(arma, grade.posicoes[atacante], grade.posicoes[alvo], Vector2i(grade.COLUNAS, grade.LINHAS))
	if alcance["permitido"] and not _linha_arco_livre(arma, grade.posicoes[atacante], grade.posicoes[alvo]):
		alcance = {"permitido": false, "motivo": "Trajetória do arco bloqueada por obstáculo."}
	if not alcance["permitido"]:
		_mensagem("%s: %s Nenhum PA foi gasto." % [arma["nome"], alcance["motivo"]])
	return bool(alcance["permitido"])


func _modo_ataque_bandido(vantagem: bool = false) -> String:
	return _modo_ataque_inimigo("Bandido", vantagem)


func _descrever_ataque(atacante: String, alvo: String, atributo: int, pv: int, maximo: int) -> String:
	if ultimo_ataque["erro"]:
		if ultimo_ataque.has("golpes"):
			return "%s: %s.\nTodos os golpes erraram. Dano 0. %s: %d/%d PV." % [atacante, ultimo_ataque["expressao"], alvo, pv, maximo]
		return "%s: natural 1, erro automático.\nDano 0. %s: %d/%d PV." % [atacante, alvo, pv, maximo]
	var fontes: Dictionary = ultimo_ataque["fontes"]
	var detalhe := "base %d" % fontes.get("base", 0) if fontes.has("base") else "Natural %d / Escudo %d / Defender %d / Veterano %d" % [fontes.get("natural", 0), fontes.get("escudo", 0), fontes.get("temporaria", 0), fontes.get("veterano", 0)]
	var extra := " +%d bônus do Machado" % ultimo_ataque["bonus_arma"] if ultimo_ataque["bonus_arma"] > 0 else ""
	if int(ultimo_ataque.get("bonus_alimento", 0)) > 0:
		extra += " +%d alimento" % ultimo_ataque["bonus_alimento"]
	if int(ultimo_ataque.get("bonus_veterano", 0)) > 0:
		extra += " +1 Veterano"
	var texto := "%s: d6 %d %+d%s = %d; acerto.\nDefesa %d (%s).\n" % [atacante, ultimo_ataque["natural"], atributo, extra, ultimo_ataque["bruto"], ultimo_ataque["defesa"], detalhe]
	if ultimo_ataque.has("expressao"):
		texto = "%s: %s = %d bruto; Defesa %d (%s).\n" % [atacante, ultimo_ataque["expressao"], ultimo_ataque["bruto"], ultimo_ataque["defesa"], detalhe]
	if int(ultimo_ataque.get("bonus_alimento", 0)) > 0:
		texto += "Alimento: +%d dano com armas. " % ultimo_ataque["bonus_alimento"]
	if ultimo_ataque.get("muralha", false):
		texto += "Muralha: %d → %d. " % [ultimo_ataque["dano"], ultimo_ataque["dano_recebido"]]
	if int(ultimo_ataque.get("absorvido_temporarios", 0)) > 0:
		texto += "PV temporários absorveram %d. " % ultimo_ataque["absorvido_temporarios"]
	return texto + "Dano %d. %s: %d/%d PV." % [ultimo_ataque["dano_recebido"], alvo, pv, maximo]


func _iniciar_turno_brokk() -> void:
	turno_atual = "Brokk"

	_limpar_selecao()
	estado_brokk.iniciar_turno()
	_registrar_turno("Brokk")
	_atualizar_interface()


func _inimigos_vivos() -> Array[String]:
	var vivos: Array[String] = []
	for id in inimigos:
		if inimigos[id].pv_atuais > 0:
			vivos.append(id)
	return vivos


func _nome_participante(id: String) -> String:
	return ficha_brokk.NOME if id == "Brokk" else inimigos[id].nome


func _verificar_fim_combate() -> bool:
	if vida_brokk > 0 and not _inimigos_vivos().is_empty():
		return false
	if finalizacao_emitida:
		return true
	finalizacao_emitida = true
	turno_atual = ""
	if estado_brokk.has_method("encerrar_combate"):
		estado_brokk.encerrar_combate()
	if alimentos != null:
		alimentos.avancar("combate")
		alimentos.atualizar_ficha(ficha_brokk)
	_mensagem(texto_resultado.text + "\nCombate encerrado: %s %s." % [ficha_brokk.NOME, "venceu" if vida_brokk > 0 else "foi derrotado"])
	_atualizar_interface()
	combate_finalizado.emit(vida_brokk > 0)
	return true


func _selecionar_alvo(id: String) -> bool:
	if not _pode_agir() or not inimigos.has(id) or inimigos[id].pv_atuais <= 0:
		return false
	alvo_selecionado = id
	_mensagem("Alvo: %s. Escolha Atacar ou Vantagem. Clique em outro inimigo para trocar." % inimigos[id].nome)
	_atualizar_interface()
	return true


func _encerrar_turno() -> void:
	if not _pode_agir():
		return
	_limpar_selecao()
	await _avancar_turno()


func _avancar_turno() -> void:
	if _verificar_fim_combate():
		return
	var indice := ordem_turnos.find(turno_atual)
	for passo in range(1, ordem_turnos.size() + 1):
		var proximo: String = ordem_turnos[(indice + passo) % ordem_turnos.size()]
		if proximo == "Brokk":
			_iniciar_turno_brokk()
			return
		if inimigos[proximo].pv_atuais > 0:
			await _iniciar_turno_inimigo(proximo)
			return


func _iniciar_turno_bandido() -> void:
	await _iniciar_turno_inimigo("Bandido")


func _iniciar_turno_inimigo(id: String) -> void:
	if not inimigos.has(id) or not posicionamento_concluido or _verificar_fim_combate():
		return
	turno_atual = id
	if inimigos[id].pv_atuais <= 0:
		await _avancar_turno()
		return
	inimigos[id].iniciar_turno()
	_registrar_turno(id)
	_atualizar_interface()
	await get_tree().create_timer(0.4).timeout
	# Ataque válido sempre vem antes de movimentação, inclusive com arco próximo.
	for tentativa in range(grade.COLUNAS * grade.LINHAS):
		if _pode_atacar_inimigo(id):
			break
		var origem: Vector2i = grade.posicoes[id]
		await _mover_inimigo(id)
		if grade.posicoes[id] == origem:
			break
	await _executar_ataque_inimigo(id)


func _distancia(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func _pode_atacar_inimigo(id: String) -> bool:
	# Sem efeitos colaterais: a mesma validação serve à decisão e à execução.
	if not inimigos.has(id) or not posicionamento_concluido or turno_atual != id or finalizacao_emitida or movimento_em_andamento or rolagem_em_andamento:
		return false
	var inimigo: RefCounted = inimigos[id]
	if inimigo.pv_atuais <= 0 or vida_brokk <= 0 or inimigo.pa_atuais < Regras.CUSTOS["atacar"]:
		return false
	if not grade.posicoes.has(id) or not grade.posicoes.has("Brokk"):
		return false
	return Equipamentos.avaliar_alcance(inimigo.arma, grade.posicoes[id], grade.posicoes["Brokk"], Vector2i(grade.COLUNAS, grade.LINHAS))["permitido"] and _linha_arco_livre(inimigo.arma, grade.posicoes[id], grade.posicoes["Brokk"])


func _caminho_para_ataque(id: String) -> Array[Vector2i]:
	# Busca uma casa de ataque realmente alcançável, contornando bloqueios.
	# Cada trecho reduz a distância no caminho; não há recuo entre casas equivalentes.
	var melhor: Array[Vector2i] = []
	var arma: Dictionary = inimigos[id].arma
	var heroi: Vector2i = grade.posicoes["Brokk"]
	for y in range(grade.LINHAS):
		for x in range(grade.COLUNAS):
			var destino := Vector2i(x, y)
			if not Equipamentos.avaliar_alcance(arma, destino, heroi, Vector2i(grade.COLUNAS, grade.LINHAS))["permitido"] or not _linha_arco_livre(arma, destino, heroi):
				continue
			if destino == grade.posicoes[id]:
				return [] # Já está em alcance: não desperdiçar movimento, mesmo sem PA.
			var caminho := grade.caminho(id, destino, grade.COLUNAS * grade.LINHAS)
			if not caminho.is_empty() and (melhor.is_empty() or caminho.size() < melhor.size()):
				melhor = caminho
	return melhor


func _mover_inimigo(id: String) -> void:
	if not inimigos.has(id) or not posicionamento_concluido or finalizacao_emitida or turno_atual != id or movimento_em_andamento or rolagem_em_andamento:
		return
	var inimigo: RefCounted = inimigos[id]
	if inimigo.pv_atuais <= 0 or vida_brokk <= 0 or not grade.posicoes.has(id) or not grade.posicoes.has("Brokk") or _pode_atacar_inimigo(id):
		return
	var caminho := _caminho_para_ataque(id)
	if caminho.is_empty():
		return
	var gratuito: bool = inimigo.habilidades.get("passo_agil", {}).get("ativo", false) and inimigo.passo_agil_rodada != numero_rodada
	var passos := 1
	var custo: int = 0 if gratuito else Regras.CUSTOS["mover"]
	if not gratuito and caminho.size() >= 2 and inimigo.pa_atuais >= Regras.CUSTOS["correr"]:
		passos = 2
		custo = Regras.CUSTOS["correr"]
	if inimigo.pa_atuais < custo:
		return
	caminho.resize(mini(passos, caminho.size()))
	if caminho.is_empty() or not inimigo.gastar_pa(custo):
		return
	if gratuito:
		inimigo.passo_agil_rodada = numero_rodada
		visual_ui.registrar(inimigo.nome + ": Passo Ágil, 1 casa, 0 PA.")
	movimento_em_andamento = true
	_atualizar_interface()
	var sprite: Sprite2D = encontro.sprites[id]
	var animado := sprite.has_method("iniciar_deslocamento")
	if animado:
		sprite.call("iniciar_deslocamento", passos > 1, Vector2(caminho[0] - grade.posicoes[id]))
	for casa in caminho:
		if animado:
			sprite.call("olhar_para", Vector2(casa - grade.posicoes[id]))
		var tween := create_tween()
		tween.tween_property(sprite, "position", grade.position + grade.centro(casa), 0.30 if animado else 0.16)
		await tween.finished
		grade.posicionar(id, casa)
		sonoridade.passo()
		_sincronizar_sprites()
	if animado:
		sprite.call("parar_deslocamento")
	movimento_em_andamento = false
	_atualizar_interface()


func _executar_ataque_bandido() -> void:
	await _executar_ataque_inimigo("Bandido")


func _modo_ataque_inimigo(id: String, vantagem: bool = false) -> String:
	var vantagens: Array[String] = inimigos[id].fontes_vantagem.duplicate()
	var desvantagens: Array[String] = inimigos[id].fontes_desvantagem.duplicate()
	if id == "Bandido":
		vantagens.append_array(fontes_vantagem_bandido)
		desvantagens.append_array(fontes_desvantagem_bandido)
	if vantagem:
		vantagens.append("habilidade")
	if estado_brokk.condicoes.derrubado:
		vantagens.append("alvo_derrubado")
	var alvos: Array[Vector2i] = [grade.posicoes["Brokk"]]
	if Equipamentos.desvantagem_por_proximidade(inimigos[id].arma, grade.posicoes[id], alvos):
		desvantagens.append("arco_proximidade_ortogonal")
	return Regras.resolver_fontes_rolagem(vantagens, desvantagens)


func _executar_ataque_inimigo(id: String) -> void:
	if not inimigos.has(id) or not posicionamento_concluido or turno_atual != id or rolagem_em_andamento or movimento_em_andamento or inimigos[id].pv_atuais <= 0 or vida_brokk <= 0:
		return
	var inimigo: RefCounted = inimigos[id]
	if not _pode_atacar_inimigo(id) or not inimigo.gastar_pa(Regras.CUSTOS["atacar"]):
		_mensagem("%s encerrou o turno: sem alcance ou PA para atacar." % inimigo.nome)
		await _avancar_turno()
		return
	var modo := _modo_ataque_inimigo(id)
	var bonus: int = inimigo.bonus_ataque
	rolagem_em_andamento = true
	visual_dado.visible = true
	dado_3d.visible = false
	dado_bandido_3d.visible = true
	_mensagem("%s: %s..." % [inimigo.nome, modo.capitalize()])
	_atualizar_interface()
	var rolagem := RolagemArma.sortear(inimigo.arma, modo, gerador)
	ultimos_dados_bandido.assign(rolagem["totais"])
	await encontro.animar_rolagem(self, inimigo.arma, rolagem, modo)
	var natural: int = rolagem["total"]
	var natural_efeitos := natural if rolagem["natural_unico"] else 0
	var golpes_independentes: bool = inimigo.arma.get("golpes_independentes", false)
	var natural_escudo := natural_efeitos
	if golpes_independentes:
		# Basta um golpe elegível. Dois resultados 2/3 não somam dois escudos.
		for valor in rolagem["selecionados"]:
			if ficha_brokk.bonus_escudo(valor) > 0:
				natural_escudo = valor
				break
	var fogo := await _avaliar_fogo_amigo(id, "Brokk", inimigo.arma, natural_efeitos)
	var alvo_resolvido: String = "Brokk" if fogo.is_empty() else fogo["alvo"]
	var resultado_dano: int = natural if fogo.is_empty() else fogo["total"]
	if alvo_resolvido == "Brokk":
		estado_brokk.registrar_dado_inimigo(natural_escudo)
	var fontes := _fontes_defesa_alvo(alvo_resolvido, natural_escudo)
	if golpes_independentes and fogo.is_empty():
		ultimo_ataque = Regras.ataque_golpes(rolagem["selecionados"], bonus, fontes)
	else:
		ultimo_ataque = Regras.ataque_fisico(resultado_dano, bonus, fontes, 0, false, fogo.is_empty())
	ultimo_ataque["fogo_amigo"] = not fogo.is_empty()
	ultimo_ataque["dados_dano"] = fogo.get("dados", [])
	if not fogo.is_empty():
		ultimo_ataque["expressao"] = "FOGO AMIGO! Ataque %d; dano %s %+d" % [natural_efeitos, str(fogo["dados"]), bonus]
	if not rolagem["natural_unico"] or inimigo.arma["dado"] != 6:
		ultimo_ataque["expressao"] = "%s %+d" % [str(rolagem["selecionados"]), bonus]
	if golpes_independentes:
		var descricoes := PackedStringArray()
		for indice in range(ultimo_ataque["golpes"].size()):
			var golpe: Dictionary = ultimo_ataque["golpes"][indice]
			descricoes.append("Golpe %d: d4 %d (%s)" % [indice + 1, golpe["natural"], "erro" if golpe["erro"] else "acerto"])
		ultimo_ataque["expressao"] = "%s; soma dos acertos %d %+d" % ["; ".join(descricoes), ultimo_ataque["soma_acertos"], bonus]
		texto_dado.text = "2d4: %d e %d • acertos: %d" % [rolagem["selecionados"][0], rolagem["selecionados"][1], ultimo_ataque["soma_acertos"]]
	ultimo_ataque["natural"] = natural_efeitos
	ultimo_ataque["natural_escudo"] = natural_escudo
	ultimo_ataque["dados_selecionados"] = rolagem["selecionados"].duplicate()
	ultimo_ataque["atacante"] = id
	ultimo_ataque["alvo"] = "Brokk"
	ultimo_ataque["modo"] = modo
	ultimo_ataque["dados"] = ultimos_dados_bandido.duplicate()
	var dano: int = ultimo_ataque["dano"]
	var usou_muralha := false
	if alvo_resolvido == "Brokk" and dano > 0 and not estado_brokk.muralha_usada:
		var reagir := await _perguntar_habilidade("Muralha de Ferro", "%s: rolagem %s %+d = %d. Defesa %d; restam %d de dano físico.\nUsar Muralha para receber %d? 1 PA será descontado do próximo turno.\nUma vez por combate." % [inimigo.nome, str(rolagem["selecionados"]), bonus, ultimo_ataque["bruto"], ultimo_ataque["defesa"], dano, floori(dano / 2.0)], "Usar Muralha", "Receber dano")
		if reagir:
			dano = estado_brokk.confirmar_muralha(dano, ficha_brokk.MURALHA_CUSTO_PA)
			usou_muralha = true
	ultimo_ataque["muralha"] = usou_muralha
	ultimo_ataque["dano_recebido"] = dano
	var protetor := _protetor_me_protejam(alvo_resolvido, dano)
	var alvo_dano := alvo_resolvido if protetor.is_empty() else protetor
	ultimo_ataque["alvo_dano"] = alvo_dano
	ultimo_ataque["me_protejam"] = not protetor.is_empty()
	if not protetor.is_empty():
		visual_ui.registrar("TRIPA SECA: ME PROTEJAM, SEUS INÚTEIS!")
	var sprite_atacante: Sprite2D = encontro.sprites[id]
	var sprite_alvo: Sprite2D = sprite_brokk if alvo_dano == "Brokk" else encontro.sprites[alvo_dano]
	if not protetor.is_empty():
		await efeitos.apresentar_reacao_chefe("me_protejam", encontro.sprites[alvo_resolvido], sprite_alvo)
	await efeitos.apresentar(inimigo.arma, ultimo_ataque.duplicate(true), sprite_atacante, sprite_alvo, escudo_visual if alvo_dano == "Brokk" else null)
	var restante: int = alimentos.absorver(dano) if alvo_dano == "Brokk" and alimentos != null else dano
	ultimo_ataque["absorvido_temporarios"] = dano - restante
	if alvo_dano == "Brokk":
		vida_brokk -= restante
		# Defender é um gatilho já definido. Esquiva fica na função do estado,
		# sem criar uma ação nova; bloqueio automático do escudo aguarda definição.
		var defendeu: bool = estado_brokk.bonus_defesa_temporaria > 0 and not ultimo_ataque["erro"]
		if ficha_brokk.talento_racial() == "Veterano de Batalha" and estado_brokk.registrar_defesa(dano, defendeu):
			ultimo_ataque["veterano_defesa_ativou"] = true
			visual_ui.registrar("Veterano de Batalha: Defesa +1 até o fim do combate.")
			await efeitos.apresentar_veterano("defesa", sprite_brokk)
	else:
		inimigos[alvo_dano].pv_atuais -= restante
		if inimigos[alvo_dano].pv_atuais == 0:
			visual_ui.registrar("Derrota: " + inimigos[alvo_dano].nome)
	if int(ultimo_ataque["fontes"].get("escudo", 0)) > 0:
		visual_ui.registrar("Escudo de %s: −2 dano pela Defesa condicional." % ficha_brokk.NOME)
	var efeito := ""
	if alvo_dano == "Brokk" and Equipamentos.tenta_derrubar(inimigo.arma, natural_efeitos, {"FOR": inimigo.forca}):
		var regra: String = ficha_brokk.regra_derrubado_por_proeza(int(inimigo.arma["dado"])) if inimigo.arma["categoria"] == "comum" else "sem_regra_especial"
		var resposta: String = estado_brokk.condicoes.aplicar_derrubado(regra)
		ultimo_ataque["derrubado"] = resposta
		efeito = "\nFirmeza de Rocha: Brokk resistiu ao Derrubado!" if resposta == "imune" else "\nDerrubado: " + resposta
	_mensagem(_descrever_ataque(inimigo.nome, _nome_participante(alvo_dano), bonus, vida_brokk if alvo_dano == "Brokk" else inimigos[alvo_dano].pv_atuais, ficha_brokk.pv_maximos() if alvo_dano == "Brokk" else inimigos[alvo_dano].pv_maximos) + efeito)
	if vida_brokk == 0:
		visual_ui.registrar("Derrota: " + ficha_brokk.NOME)
	_sincronizar_sprites()
	_atualizar_interface()
	await get_tree().create_timer(1.2).timeout
	dado_bandido_3d.visible = false
	if encontro.dado_extra != null:
		encontro.dado_extra.visible = false
	visual_dado.visible = false
	rolagem_em_andamento = false
	if not _verificar_fim_combate():
		await _avancar_turno()


func _defender() -> void:
	if not _pode_agir():
		return
	if estado_brokk.bonus_defesa_temporaria > 0:
		_mensagem("Defender já está ativo (+2) até o início do próximo turno. Nenhum PA adicional foi gasto.")
		return
	if estado_brokk.pa_atuais < Regras.CUSTOS["defender"]:
		_mensagem("PA insuficientes: Defender custa 1 PA.")
		return
	_limpar_selecao()
	estado_brokk.defender()
	sprite_brokk.defender()
	_mensagem("Defender: +2 Defesa até o início do próximo turno de %s. Restam %d PA." % [ficha_brokk.NOME, estado_brokk.pa_atuais])
	_atualizar_interface()


func _selecionar_movimento(correr: bool) -> void:
	if not _pode_agir():
		return
	var modo := "correr" if correr else "mover"
	if estado_brokk.pa_atuais < Regras.CUSTOS[modo]:
		_mensagem("PA insuficientes: %s custa %d PA; restam %d." % [modo, Regras.CUSTOS[modo], estado_brokk.pa_atuais])
		return
	if modo_movimento == modo:
		_limpar_selecao()
		_mensagem("Seleção cancelada, sem gastar PA.")
		_atualizar_interface()
		return
	_limpar_selecao()
	modo_movimento = modo
	grade.destinos = grade.casas_movimento("Brokk", _passos_brokk(correr))
	grade.queue_redraw()
	_mensagem("%s: clique em uma casa verde. Custo %d PA somente ao confirmar destino válido. Esc cancela." % [modo.capitalize(), Regras.CUSTOS[modo]])
	_atualizar_interface()


func _mover_para(destino: Vector2i, correr: bool = false) -> bool:
	if not _pode_agir():
		return false
	var caminho := grade.caminho("Brokk", destino, _passos_brokk(correr))
	if caminho.is_empty():
		_mensagem("Destino inválido: respeite o caminho ortogonal, a ocupação e os limites. Nenhum PA gasto.")
		return false
	if not _pagar_acao("correr" if correr else "mover"):
		return false
	movimento_em_andamento = true
	grade.trilha.assign([grade.posicoes["Brokk"]])
	grade.trilha.append_array(caminho)
	grade.queue_redraw()
	_atualizar_interface()
	sprite_brokk.iniciar_deslocamento(correr, Vector2(caminho[0] - grade.posicoes["Brokk"]))
	for casa in caminho:
		sprite_brokk.olhar_para(Vector2(casa - grade.posicoes["Brokk"]))
		var tween := create_tween()
		# Só muda a duração visual; destinos, caminho e custo são os mesmos.
		tween.tween_property(sprite_brokk, "position", grade.position + grade.centro(casa), 0.30 if correr else 0.50)
		await tween.finished
		grade.posicionar("Brokk", casa)
		sonoridade.passo()
		_sincronizar_sprites()
	sprite_brokk.parar_deslocamento()
	movimento_em_andamento = false
	grade.trilha.clear()
	grade.queue_redraw()
	_mensagem("%s em %s. Restam %d/%d PA." % [ficha_brokk.NOME, grade.nome_casa(destino), estado_brokk.pa_atuais, estado_brokk.pa_maximos])
	_atualizar_interface()
	return true


func _ao_clicar_casa(casa: Vector2i) -> void:
	if selecionando_posicao:
		_confirmar_posicao(casa)
	elif modo_movimento != "":
		await _mover_para(casa, modo_movimento == "correr")
	elif ataque_carta != "" and _pode_agir():
		for id in _alvos_cartas_ataque():
			if casa == grade.posicoes[id]:
				var vantagem := ataque_carta == "vantagem"
				_selecionar_alvo(id)
				await _ataque_brokk(vantagem)
				return
		_mensagem("Alvo inválido ou fora do alcance. Escolha um inimigo destacado; nenhum PA gasto.")
	elif _pode_agir() and casa == grade.posicoes["Brokk"]:
		_mensagem("%s selecionado em %s. Escolha Atacar, Defender, Mover ou Correr." % [ficha_brokk.NOME, grade.nome_casa(casa)])
	elif _pode_agir():
		for id in _inimigos_vivos():
			if casa == grade.posicoes[id]:
				_selecionar_alvo(id)
				break


func _avancar_posicionamento() -> void:
	while formacao.atual() != "":
		var id := formacao.atual()
		if id in formacao.herois:
			selecionando_posicao = true
			grade.destinos = grade.casas_iniciais(total_iniciativa_brokk)
			grade.queue_redraw()
			_mensagem("Posicionamento por iniciativa: vez de %s. Escolha uma casa verde. Sem custo de PA." % _nome_participante(id))
			_atualizar_interface()
			return
		var casa := formacao.escolher(grade, inimigos[id].arma, inimigos[id].fileira_preferida)
		if casa.x < 0:
			_mensagem("Formação bloqueada: nenhuma casa inicial válida para " + _nome_participante(id))
			return
		grade.posicionar(id, casa)
		grade.nao_posicionados.erase(id)
		formacao.confirmar(id, casa)
		visual_ui.registrar("Formação: %s escolheu %s." % [_nome_participante(id), grade.nome_casa(casa)])
	selecionando_posicao = false
	posicionamento_concluido = true
	_limpar_selecao()
	_sincronizar_sprites()
	_mensagem("Formação concluída. %s age primeiro." % _nome_participante(primeiro_a_agir))
	if primeiro_a_agir == "Brokk":
		_iniciar_turno_brokk()
	else:
		turno_atual = primeiro_a_agir
		_iniciar_turno_inimigo.call_deferred(primeiro_a_agir)


func _confirmar_posicao(casa: Vector2i) -> bool:
	if not selecionando_posicao or formacao.atual() != "Brokk" or casa not in grade.casas_iniciais(total_iniciativa_brokk):
		_mensagem("Posição inicial inválida: escolha uma casa verde livre do lado dos heróis.")
		return false
	grade.posicionar("Brokk", casa)
	grade.nao_posicionados.erase("Brokk")
	formacao.confirmar("Brokk", casa)
	selecionando_posicao = false
	_avancar_posicionamento()
	_sincronizar_sprites()
	return true


func _limpar_selecao() -> void:
	ataque_carta = ""
	grade.alvos_validos.clear()
	modo_movimento = ""
	grade.destinos.clear()
	grade.trilha.clear()
	grade.queue_redraw()


func _sincronizar_sprites() -> void:
	sprite_brokk.position = grade.position + grade.centro(grade.posicoes["Brokk"])
	sprite_bandido.position = grade.position + grade.centro(grade.posicoes["Bandido"])
	sprite_brokk.definir_vivo(vida_brokk > 0)
	sprite_brokk.visible = (vida_brokk > 0 or sprite_brokk.morte_em_andamento) and "Brokk" not in grade.nao_posicionados
	# O sprite derrotado fica deitado em sua própria casa.
	sprite_bandido.rotation = PI / 2.0 if vida_bandido == 0 else 0.0
	sprite_bandido.modulate = Color("777777") if vida_bandido == 0 else Color.WHITE
	if is_instance_valid(sprite_porrete):
		sprite_porrete.position = grade.position + grade.centro(grade.posicoes["Porrete"])
		sprite_porrete.rotation = PI / 2.0 if inimigos["Porrete"].pv_atuais == 0 else 0.0
		sprite_porrete.modulate = Color("777777") if inimigos["Porrete"].pv_atuais == 0 else Color("dfb98b")
		porrete_visual.visible = inimigos["Porrete"].pv_atuais > 0
	if is_instance_valid(escudo_visual):
		escudo_visual.visible = ficha_brokk.escudo_equipado and vida_brokk > 0
	grade.derrotados.clear()
	for id in inimigos:
		if inimigos[id].pv_atuais == 0:
			grade.derrotados.append(id)
	grade.queue_redraw()
	encontro.sincronizar(self)
	queue_redraw()


func _criar_visuais_equipamentos() -> void:
	sprite_porrete = sprite_bandido.duplicate()
	sprite_porrete.name = "BandidoPorreteSprite"
	sprite_porrete.scale = Vector2(1.8, 1.8)
	add_child(sprite_porrete)
	escudo_visual = Polygon2D.new()
	escudo_visual.name = "EscudoMadeiraFerro"
	escudo_visual.polygon = PackedVector2Array([Vector2(7, -2), Vector2(18, -2), Vector2(18, 8), Vector2(13, 13), Vector2(7, 8)])
	escudo_visual.color = Color("84552f")
	sprite_brokk.add_child(escudo_visual)
	# A arte original já contém o escudo. Mantém só a âncora dos efeitos,
	# estado de visibilidade e vibração, evitando desenhar um segundo escudo.
	escudo_visual.modulate.a = 0.0
	escudo_visual.position = Vector2(12, 7)
	var borda := Line2D.new()
	borda.points = escudo_visual.polygon
	borda.closed = true
	borda.width = 1.6
	borda.default_color = Color("b6bbc0")
	escudo_visual.add_child(borda)
	var reforco := Line2D.new()
	reforco.points = PackedVector2Array([Vector2(8, 4), Vector2(17, 4)])
	reforco.width = 1.5
	reforco.default_color = Color("9aa2a8")
	escudo_visual.add_child(reforco)
	porrete_visual = Polygon2D.new()
	porrete_visual.name = "PorreteMadeira"
	porrete_visual.polygon = PackedVector2Array([Vector2(-10, 9), Vector2(-7, 8), Vector2(-10, -5), Vector2(-9, -16), Vector2(-16, -18), Vector2(-18, -13), Vector2(-14, -4)])
	porrete_visual.color = Color("9b663a")
	sprite_porrete.add_child(porrete_visual)
	var contorno := Line2D.new()
	contorno.points = porrete_visual.polygon
	contorno.closed = true
	contorno.width = 1.0
	contorno.default_color = Color("4d3221")
	porrete_visual.add_child(contorno)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and (modo_movimento != "" or ataque_carta != ""):
		_limpar_selecao()
		_mensagem("Seleção cancelada, sem gastar PA.")
		_atualizar_interface()


func _perguntar_habilidade(titulo: String, mensagem: String, confirmar: String, recusar: String) -> bool:
	dialogo_habilidade.title = titulo
	dialogo_habilidade.dialog_text = mensagem
	dialogo_habilidade.get_ok_button().text = confirmar
	dialogo_habilidade.get_cancel_button().text = recusar
	aguardando_decisao = true
	dialogo_habilidade.popup_centered(Vector2i(580, 210))
	var confirmada: bool = await decisao_habilidade
	dialogo_habilidade.hide()
	return confirmada


func _responder_habilidade(confirmada: bool) -> void:
	if not aguardando_decisao:
		return
	if confirmada and not dialogo_habilidade.title.begins_with("Golpe Sujo"):
		visual_ui.registrar("Habilidade ativada: " + dialogo_habilidade.title)
	aguardando_decisao = false
	decisao_habilidade.emit(confirmada)


func _abrir_ficha() -> void:
	if rolagem_em_andamento or movimento_em_andamento or aguardando_decisao or turno_atual in inimigos:
		return
	texto_ficha.text = _resumo_ficha()
	dialogo_ficha.popup_centered(Vector2i(700, 470))


func _resumo_ficha() -> String:
	var linhas: Array[String] = [
		"%s • %s • %s nível %d" % [ficha_brokk.NOME, ficha_brokk.RACA["nome"], ficha_brokk.CLASSE["nome"], ficha_brokk.NIVEL],
		"PV: %d/%d (base %d + CON total %+d)" % [vida_brokk, ficha_brokk.pv_maximos(), ficha_brokk.CLASSE["pv_base"], ficha_brokk.atributo("CON")],
		"Atributos: classe + raça = total",
	]
	for atributo in ["FOR", "DES", "CON", "INT", "SAB", "CAR"]:
		linhas.append("%s: %+d + %+d = %+d" % [atributo, ficha_brokk.CLASSE["atributos"].get(atributo, 0), ficha_brokk.RACA["atributos"].get(atributo, 0), ficha_brokk.atributo(atributo)])
	linhas.append("DES base %+d; efetiva %+d com escudo (-1). Iniciativa usa a DES efetiva." % [ficha_brokk.atributo("DES"), ficha_brokk.atributo_efetivo("DES")])
	linhas.append("%s: arma equipada, físico 1d%d; adjacência conforme alcance da arma. Natural 1 erra." % [ficha_brokk.arma_atual()["nome"], ficha_brokk.dado_ataque()])
	if ficha_brokk.talento_racial() == "Veterano de Batalha":
		linhas.append("Espada de Ferro: 1d6 + FOR; repete um ataque errado, 1/combate, se FOR ou DES >= 2. Repetição: " + ("usada" if estado_brokk.espada_repeticao_usada else "disponível") + ".")
		linhas.append("Humano (O Versátil): +1 FOR e +1 CON; Talento Universal: Veterano de Batalha.")
		linhas.append("Veterano: natural final da arma >= 5 ativa Dano +1 já naquele ataque, até o fim do combate.")
		linhas.append("Veterano: defender/esquivar sem receber dano ativa Defesa +1 até o fim do combate. Cada bônus só ativa uma vez.")
	else:
		linhas.append("Natural 6: +2 ao dano bruto se FOR >= 2 (bônus do machado, não crítico).")
	linhas.append("%s: 1H; +2 Defesa contra natural utilizado 2 ou 3; -1 DES." % ficha_brokk.EQUIPAMENTOS["escudo"]["nome"])
	linhas.append("Escudo não modifica custos de PA nem quantidade de casas de movimento/corrida.")
	linhas.append("Bandido: Arco Curto, comum, 2H, 1d6 +1; qualquer casa do tabuleiro.")
	linhas.append("Arco: Desvantagem contra inimigo adjacente ortogonal; diagonal não impõe Desvantagem.")
	linhas.append("Bandido do Porrete: 8 PV, FOR +2, DES 0, Defesa 0; comum 1H, 1d6 + FOR, adjacente inclusive diagonal.")
	linhas.append("Porrete: natural 6 com FOR >= 2 tenta Derrubado. Zeno não possui a imunidade racial dos anões." if ficha_brokk.talento_racial() != "" else "Porrete: natural 6 com FOR >= 2 tenta Derrubado. Firmeza de Rocha impede a condição em Brokk, preservando o dano.")
	linhas.append("Derrubado (provisório): atacantes recebem Vantagem; -1 PA por aplicação no início do próximo turno, quando a condição termina.")
	linhas.append("Muralha de Ferro: %s. Reação 1/combate; metade do dano físico, para baixo." % ("usada" if estado_brokk.muralha_usada else "disponível"))
	linhas.append("Custo: 1 PA no próximo turno. Pendente: %d; já descontado: %d." % [estado_brokk.pa_debito_pendente, estado_brokk.pa_debito_registrado])
	linhas.append("Mestre das Armas: %s. 0 PA; repete um d6, aceitando o segundo; 1/combate." % ("usada" if estado_brokk.mestre_armas_usado else "disponível"))
	linhas.append("Físico Atlético: vantagem em desafios só de FOR e resistência a doenças (preparado).")
	if ficha_brokk.talento_racial() == "":
		linhas.append("Firmeza de Rocha: proeza com d6/d8 não Derruba; d10/d12: resistência com vantagem.")
		linhas.append("Pele de Rocha: %s. +1 Defesa Natural se PV > metade (8 a 14)." % ("ativa" if ficha_brokk.bonus_pele_rocha(vida_brokk) > 0 else "inativa"))
	linhas.append("Defesa Total = Natural + escudo (natural 2/3) + Defender + Veterano quando ativo. Reduz o dano antes de Muralha.")
	linhas.append("Recuperação preparada: descanso curto/longo + Comida no fim do turno de exploração.")
	linhas.append("PA por turno: 5. Ataque 3; Vantagem 5; Defender 1; Mover 2; Correr até 2 casas: 3.")
	if alimentos != null:
		linhas.append("Efeitos alimentares ativos: " + alimentos.resumo())
		linhas.append("PV temporários: %d, separados dos PV normais." % alimentos.pv_temporarios())
		var efetivos: Array[String] = []
		for atributo in ["FOR", "DES", "CON", "INT", "SAB", "CAR"]:
			efetivos.append("%s %+d" % [atributo, ficha_brokk.atributo_efetivo(atributo)])
		linhas.append("Atributos efetivos com equipamento/alimentos: " + " • ".join(efetivos))
	return "\n".join(linhas)


func _animar_dado(dado: Node3D, resultado: int) -> void:
	sonoridade.rolar()
	await Dados3D.animar(dado, resultado).finished


func _iniciar_animacao_iniciativa(dado: Node3D, resultado: int) -> Tween:
	sonoridade.rolar()
	return Dados3D.animar(dado, resultado)


func _criar_numeros_iniciativa(dado: Node3D) -> Array[Label3D]:
	return Dados3D.configurar(dado, 20, Color("254ea2") if dado == dado_iniciativa_brokk else Color("a13538"))


func _definir_numeros_dado(_numeros: Array[Label3D], _texto: String) -> void:
	# Números permanentes por face. A orientação exibe o resultado verdadeiro.
	pass


func _orientacao_do_resultado(resultado: int) -> Vector3:
	return Dados3D.orientacao_tipo(6, resultado)


func _rolar_iniciativa() -> void:
	var participantes: Array[String] = ["Brokk"]
	participantes.append_array(_inimigos_vivos())
	var dados := encontro.dados
	for i in range(participantes.size()):
		var dado: Node3D = dados[participantes[i]]
		var passo := 1.4 if participantes.size() == 4 else (1.8 if participantes.size() == 3 else 2.2)
		dado.position.x = (i - (participantes.size() - 1) / 2.0) * passo
		dado.scale = Vector3.ONE * (0.65 if participantes.size() == 4 else (0.8 if participantes.size() == 3 else 0.9))
	var numeros := encontro.numeros
	var rotulos := encontro.iniciativas
	var tentativa := 1
	iniciativa_concluida = false
	visual_dado.visible = true
	for id in dados:
		dados[id].visible = id in participantes
	while true:
		iniciativas.clear()
		var totais: Array[int] = []
		var empate := false
		var animacao: Tween
		for id in participantes:
			var natural := gerador.randi_range(1, 20)
			var des: int = ficha_brokk.atributo_efetivo("DES") if id == "Brokk" else inimigos[id].destreza
			var bonus_iniciativa := _bonus_alimentar("iniciativa") if id == "Brokk" else 0
			var total := natural + des + bonus_iniciativa
			iniciativas[id] = {"natural": natural, "destreza": des, "alimento": bonus_iniciativa, "total": total}
			if total in totais:
				empate = true
			totais.append(total)
			_definir_numeros_dado(numeros[id], "...")
			animacao = _iniciar_animacao_iniciativa(dados[id], natural)
		var nomes_dados: Array[String] = []
		for id in participantes:
			nomes_dados.append(_nome_participante(id).trim_prefix("Bandido ").trim_prefix("Goblin ").trim_prefix("do "))
		texto_dado.add_theme_font_size_override("font_size", 18)
		texto_dado.text = "Iniciativa • tentativa %d" % tentativa
		texto_dado.tooltip_text = " | ".join(nomes_dados)
		_mensagem("Todos rolam 1d20 + DES efetiva simultaneamente.")
		await animacao.finished
		for id in participantes:
			var valor: Dictionary = iniciativas[id]
			_definir_numeros_dado(numeros[id], str(valor["natural"]))
			var cafe := " + Café %d" % valor["alimento"] if valor["alimento"] > 0 else ""
			rotulos[id].text = "%s | natural %d + DES efetiva %d%s = %d" % [id, valor["natural"], valor["destreza"], cafe, valor["total"]]
			rotulos[id].tooltip_text = rotulos[id].text
			if participantes.size() > 3 and id != "Brokk":
				rotulos[id].text = "d20 %d + DES %d = %d" % [valor["natural"], valor["destreza"], valor["total"]]
			rotulos[id].add_theme_font_size_override("font_size", 10)
			if id != "Brokk":
				inimigos[id].iniciativa_natural = valor["natural"]
				inimigos[id].iniciativa_total = valor["total"]
		if empate:
			_mensagem("Empate na iniciativa. Todos os participantes rolam novamente.")
			tentativa += 1
			await get_tree().create_timer(0.8).timeout
			continue
		ordem_turnos.assign(participantes)
		ordem_turnos.sort_custom(func(esquerda: String, direita: String) -> bool: return iniciativas[esquerda]["total"] > iniciativas[direita]["total"])
		total_iniciativa_brokk = iniciativas["Brokk"]["total"]
		primeiro_a_agir = ordem_turnos[0]
		iniciativa_concluida = true
		var nomes_ordem := PackedStringArray()
		for id in ordem_turnos:
			nomes_ordem.append(_nome_participante(id))
		_mensagem("Ordem: %s. Escolha a posição inicial de %s após os dados." % [" → ".join(nomes_ordem), ficha_brokk.NOME])
		await get_tree().create_timer(1.5).timeout
		for dado in dados.values():
			dado.visible = false
		visual_dado.visible = false
		texto_dado.text = "Iniciativa concluída • ordem definida"
		formacao.iniciar(ordem_turnos, ["Brokk"])
		grade.nao_posicionados.assign(ordem_turnos)
		_avancar_posicionamento()
		return


func _registrar_turno(id: String) -> void:
	# Apenas contabiliza os turnos iniciados pela ordem existente.
	if numero_rodada == 0 or id in participantes_rodada:
		numero_rodada += 1
		participantes_rodada.clear()
		if numero_rodada > 1 and alimentos != null:
			alimentos.avancar("combate")
			alimentos.atualizar_ficha(ficha_brokk)
	participantes_rodada.append(id)
	historico_turnos.append(id)
	var pa: int = estado_brokk.pa_atuais if id == "Brokk" else inimigos[id].pa_atuais
	visual_ui.registrar("Rodada %d • Início do turno de %s: %d PA." % [numero_rodada, _nome_participante(id), pa])


func _alvo_no_alcance() -> bool:
	if not inimigos.has(alvo_selecionado) or inimigos[alvo_selecionado].pv_atuais <= 0:
		return false
	return Equipamentos.avaliar_alcance(ficha_brokk.arma_atual(), grade.posicoes["Brokk"], grade.posicoes[alvo_selecionado], Vector2i(grade.COLUNAS, grade.LINHAS))["permitido"] and _linha_arco_livre(ficha_brokk.arma_atual(), grade.posicoes["Brokk"], grade.posicoes[alvo_selecionado])


func _atualizar_interface() -> void:
	apresentacao.atualizar(self)
	estado_brokk.bonus_defesa_natural = ficha_brokk.bonus_pele_rocha(vida_brokk)
	estado_brokk.bonus_defesa_escudo = ficha_brokk.bonus_escudo(estado_brokk.ultimo_dado_inimigo)
	texto_vida_brokk.text = "PV %d/%d • PA %d/%d" % [vida_brokk, ficha_brokk.pv_maximos(), estado_brokk.pa_atuais, estado_brokk.pa_maximos]
	barra_vida_brokk.max_value = ficha_brokk.pv_maximos()
	barra_vida_brokk.value = vida_brokk
	if alimentos != null and alimentos.pv_temporarios() > 0:
		texto_vida_brokk.text += " • +%d PV temp." % alimentos.pv_temporarios()
	visual_ui.rotulos_armas["Brokk"].text = "%s (1H, 1d%d) • %s" % [ficha_brokk.arma_atual()["nome"], ficha_brokk.dado_ataque(), ficha_brokk.EQUIPAMENTOS["escudo"]["nome"] if ficha_brokk.escudo_equipado else "Sem escudo"]
	var estados_brokk: Array[String] = []
	if estado_brokk.condicoes.derrubado:
		estados_brokk.append("Derrubado")
	if estado_brokk.bonus_defesa_temporaria > 0:
		estados_brokk.append("Defender +%d" % estado_brokk.bonus_defesa_temporaria)
	if estado_brokk.bonus_defesa_natural > 0:
		estados_brokk.append("Pele de Rocha +%d" % estado_brokk.bonus_defesa_natural)
	visual_ui.atualizar_cartao("Brokk", estado_brokk.pa_atuais, estado_brokk.pa_maximos, vida_brokk > 0, turno_atual == "Brokk", estados_brokk)
	encontro.atualizar(self)
	var pode := _pode_agir()
	var alcance := _alvo_no_alcance()
	for botao in [botao_atacar, botao_vantagem, botao_defender, botao_mover, botao_correr, botao_encerrar]:
		var acao: String = botao.get_meta("acao")
		var custo := int(Regras.CUSTOS.get(acao, 0))
		var nome_acao: String = {"atacar": "Atacar", "vantagem": "Vantagem", "defender": "Defender", "mover": "Mover", "correr": "Correr", "encerrar": "Encerrar turno"}[acao]
		if acao == "encerrar":
			botao.text = nome_acao
		var motivo := ""
		if not pode:
			motivo = "Aguarde sua vez, a animação ou confirme o posicionamento inicial."
		elif estado_brokk.pa_atuais < custo:
			motivo = "PA insuficientes: custa %d PA; disponíveis %d." % [custo, estado_brokk.pa_atuais]
		elif acao in ["atacar", "vantagem"] and _alvos_cartas_ataque().is_empty():
			motivo = "Sem alvo válido no alcance da arma e com trajetória livre. Aproxime-se ou selecione outro."
		elif acao == "defender" and estado_brokk.bonus_defesa_temporaria > 0:
			motivo = "Defender já está ativo até o início do próximo turno."
		elif acao in ["mover", "correr"] and grade.casas_movimento("Brokk", _passos_brokk(acao == "correr")).is_empty():
			motivo = "Nenhuma casa livre alcançável com esta ação."
		if acao == "encerrar":
			botao.disabled = not motivo.is_empty()
			botao.tooltip_text = motivo if not motivo.is_empty() else "Encerra o turno voluntariamente."
		else:
			barra_cartas.atualizar(acao, ataque_carta == acao or modo_movimento == acao, motivo)
	grade.alvos_validos.assign(_alvos_cartas_ataque() if ataque_carta != "" and pode else [])

	botao_ficha.disabled = rolagem_em_andamento or movimento_em_andamento or turno_atual in inimigos
	botao_ficha.tooltip_text = "Ficha completa e estados das habilidades. Mestre das Armas e Muralha são oferecidos no momento apropriado."
	var muralha := "usada" if estado_brokk.muralha_usada else "disponível"
	var mestre := "usada" if estado_brokk.mestre_armas_usado else "disponível"
	texto_passivas.text = "Defender: +%d • Pele de Rocha: +%d %s\nMuralha: %s • Mestre: %s" % [estado_brokk.bonus_defesa_temporaria, estado_brokk.bonus_defesa_natural, "ativa" if estado_brokk.bonus_defesa_natural > 0 else "inativa", muralha, mestre]
	if ficha_brokk.talento_racial() == "Veterano de Batalha":
		texto_passivas.text = "Defender +%d • Muralha: %s • Mestre: %s\nVeterano Defesa +%d (%s) • Dano +%d (%s)\nEspada: repetição %s" % [estado_brokk.bonus_defesa_temporaria, muralha, mestre, estado_brokk.bonus_veterano_defesa, "ativa" if estado_brokk.bonus_veterano_defesa > 0 else ("usada" if estado_brokk.veterano_defesa_ativado else "disponível"), estado_brokk.bonus_veterano_dano, "ativo" if estado_brokk.bonus_veterano_dano > 0 else ("usado" if estado_brokk.veterano_dano_ativado else "disponível"), "usada" if estado_brokk.espada_repeticao_usada else "disponível"]
		apresentacao.texto_pa.text += "\nVeterano DEF +%d / DANO +%d" % [estado_brokk.bonus_veterano_defesa, estado_brokk.bonus_veterano_dano]
	texto_passivas.tooltip_text = "Mestre: repetição, 0 PA, após o dado. Muralha: reação, 1 PA no próximo turno.\nEscudo: +%d contra o natural inimigo %d. Débito pendente: %d PA." % [estado_brokk.bonus_defesa_escudo, estado_brokk.ultimo_dado_inimigo, estado_brokk.pa_debito_pendente]
	visual_ui.ordem_visivel.clear()
	for id in ordem_turnos:
		if id == "Brokk" and vida_brokk > 0 or inimigos.has(id) and inimigos[id].pv_atuais > 0:
			visual_ui.ordem_visivel.append(id)
	visual_ui.proximo = ""
	if not visual_ui.ordem_visivel.is_empty() and turno_atual != "":
		var indice := visual_ui.ordem_visivel.find(turno_atual)
		visual_ui.proximo = visual_ui.ordem_visivel[(indice + 1) % visual_ui.ordem_visivel.size()]
	var fase := "Rolando iniciativa"
	if selecionando_posicao:
		fase = "Escolha posição inicial"
	elif posicionamento_concluido:
		fase = ("Sua vez: " + ficha_brokk.NOME) if turno_atual == "Brokk" else ("Inimigo: " + _nome_participante(turno_atual) if turno_atual != "" else "Combate encerrado")
	var nomes: Array[String] = []
	for id in visual_ui.ordem_visivel:
		nomes.append(_nome_participante(id).trim_prefix("Bandido ").trim_prefix("Goblin ").trim_prefix("do "))
	texto_turno.text = "Rodada %d • %s\n%s | Próximo: %s" % [numero_rodada, fase, " → ".join(nomes), _nome_participante(visual_ui.proximo) if visual_ui.proximo != "" else "—"]
	texto_turno.add_theme_color_override("font_color", Color("e6be69") if turno_atual == "Brokk" else Color("dbb69f"))
	texto_turno.tooltip_text = "Ordem real de iniciativa. Derrotados são omitidos. A rodada avança quando o ciclo de turnos recomeça."
	var alvo_vivo: bool = inimigos.has(alvo_selecionado) and inimigos[alvo_selecionado].pv_atuais > 0
	grade.alvo_destacado = alvo_selecionado if alvo_vivo and posicionamento_concluido else ""
	grade.alvo_no_alcance = alcance
	grade.queue_redraw()
	visual_ui.texto_alvo.text = "Alvo: %s\n%s: %s" % [_nome_participante(alvo_selecionado) if alvo_vivo else "nenhum", ficha_brokk.arma_atual()["nome"], "no alcance • clique para trocar" if alcance else "fora do alcance • aproxime-se"]


func _bonus_alimentar(chave: String) -> int:
	return alimentos.bonus(chave) if alimentos != null else 0


func _passos_brokk(correr: bool) -> int:
	return (2 if correr else 1) + (_bonus_alimentar("movimento") if alimentos != null and alimentos.movimento_por_acao else 0)
