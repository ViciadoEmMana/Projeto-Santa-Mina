extends Node
## Narrativa e exploração fora do tabuleiro; Combate.tscn continua independente.
const Sistema = preload("res://sistema_campanha.gd")
const Capitulos = preload("res://capitulos_campanha.gd")
const Comidas = preload("res://catalogo_consumiveis.gd")
const UI = preload("res://interface_combate.gd")
const Descanso = preload("res://sistema_descanso.gd")
const CenarioVisual = preload("res://scripts/presentation/cenario_combate.gd")
const Salvamento = preload("res://salvamento_campanha.gd")

var campanha := Sistema.new()
var salvamento := Salvamento.new()
var combate: Node
var tela: Control
var titulo: Label
var narrativa: RichTextLabel
var estatisticas: Label
var local: Label
var inventario: RichTextLabel
var mensagem: Label
var selecao_comida: OptionButton
var selecao_habilidade: OptionButton
var botao_confronto: Button
var botao_viagem: Button
var botao_curto: Button
var botao_longo: Button
var botao_comer: Button
var botao_continuar: Button
var descricao_comida: Label
var fundo_arte: TextureRect
var botao_salvar: Button
var botao_carregar: Button

func _ready() -> void:
	_criar_tela()
	atualizar()

func _painel(posicao: Vector2, tamanho: Vector2) -> VBoxContainer:
	var painel := PanelContainer.new()
	painel.position = posicao
	painel.size = tamanho
	painel.add_theme_stylebox_override("panel", UI.estilo())
	tela.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 8)
	painel.add_child(coluna)
	return coluna

func _label(pai: Control, texto: String, tamanho: int = 13) -> Label:
	var resultado := Label.new()
	resultado.text = texto
	resultado.add_theme_font_size_override("font_size", tamanho)
	resultado.add_theme_color_override("font_color", Color("eadfc9"))
	resultado.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pai.add_child(resultado)
	return resultado

func _botao(pai: Control, texto: String, acao: Callable) -> Button:
	var resultado := Button.new()
	resultado.text = texto
	resultado.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI.preparar_botao(resultado, "campanha")
	resultado.pressed.connect(acao)
	pai.add_child(resultado)
	return resultado

func _criar_tela() -> void:
	var camada := CanvasLayer.new()
	add_child(camada)
	tela = Control.new()
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	camada.add_child(tela)
	var fundo := ColorRect.new()
	fundo.color = Color("17171d")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.add_child(fundo)
	fundo_arte = TextureRect.new()
	fundo_arte.name = "ArteDoLocal"
	fundo_arte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo_arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo_arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo_arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fundo_arte.modulate = Color(0.42, 0.42, 0.42)
	tela.add_child(fundo_arte)
	var cabecalho := _label(tela, Capitulos.TITULO, 23)
	cabecalho.position = Vector2(24, 14)
	cabecalho.size = Vector2(684, 54)
	cabecalho.add_theme_color_override("font_color", Color("e6be69"))
	var persistencia := HBoxContainer.new()
	persistencia.position = Vector2(724, 22)
	persistencia.size = Vector2(212, 34)
	tela.add_child(persistencia)
	botao_salvar = _botao(persistencia, "Salvar", _salvar)
	botao_carregar = _botao(persistencia, "Carregar", _carregar)
	for botao in [botao_salvar, botao_carregar]:
		botao.add_theme_font_size_override("font_size", 13)
	botao_salvar.tooltip_text = "Salva neste slot e mantém uma cópia da gravação anterior. Disponível fora do combate."
	botao_carregar.tooltip_text = "Retoma a última gravação, substituindo a partida em memória. Nada é carregado automaticamente."
	var esquerda := _painel(Vector2(24, 80), Vector2(570, 308))
	titulo = _label(esquerda, "", 18)
	titulo.add_theme_color_override("font_color", Color("e6be69"))
	local = _label(esquerda, "", 12)
	narrativa = RichTextLabel.new()
	narrativa.custom_minimum_size = Vector2(0, 175)
	narrativa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	narrativa.add_theme_font_size_override("normal_font_size", 14)
	narrativa.add_theme_color_override("default_color", Color("eadfc9"))
	esquerda.add_child(narrativa)
	mensagem = _label(esquerda, "", 11)
	var direita := _painel(Vector2(610, 80), Vector2(326, 374))
	estatisticas = _label(direita, "", 12)
	inventario = RichTextLabel.new()
	inventario.custom_minimum_size = Vector2(0, 144)
	inventario.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventario.add_theme_font_size_override("normal_font_size", 12)
	inventario.add_theme_color_override("default_color", Color("eadfc9"))
	direita.add_child(inventario)
	selecao_comida = OptionButton.new()
	selecao_comida.item_selected.connect(func(_indice: int) -> void: atualizar_botoes())
	direita.add_child(selecao_comida)
	descricao_comida = _label(direita, "", 11)
	botao_comer = _botao(direita, "Consumir fora de combate", _consumir)
	var acoes := _painel(Vector2(24, 400), Vector2(570, 116))
	var linha := HBoxContainer.new()
	acoes.add_child(linha)
	botao_viagem = _botao(linha, "Concluir deslocamento", _deslocar)
	botao_confronto = _botao(linha, "Iniciar confronto", iniciar_combate)
	botao_continuar = _botao(linha, "Próximo capítulo", _continuar)
	var descanso := HBoxContainer.new()
	acoes.add_child(descanso)
	selecao_habilidade = OptionButton.new()
	selecao_habilidade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	descanso.add_child(selecao_habilidade)
	botao_curto = _botao(descanso, "Descanso Curto", _descansar.bind("curto"))
	botao_longo = _botao(descanso, "Descanso Longo", _descansar.bind("longo"))
	var rodape := _painel(Vector2(610, 466), Vector2(326, 50))
	var extras := HBoxContainer.new()
	rodape.add_child(extras)
	var reiniciar := _botao(extras, "Reiniciar", _reiniciar)
	reiniciar.tooltip_text = "Começa uma nova campanha em memória. O slot salvo permanece disponível até você salvar novamente."
	_botao(extras, "Combate original", iniciar_original)

func _comida() -> String:
	return str(selecao_comida.get_item_metadata(selecao_comida.selected)) if selecao_comida.selected >= 0 else ""

func atualizar_botoes() -> void:
	var explorando := campanha.fase == "exploracao"
	var possui := int(campanha.inventario.mantimentos.get(_comida(), 0)) > 0
	descricao_comida.text = Comidas.descrever(_comida()) if Comidas.ITENS.has(_comida()) else "Escolha um mantimento."
	botao_confronto.visible = explorando
	botao_viagem.visible = explorando
	botao_viagem.disabled = campanha.fim_turno_exploracao
	botao_comer.disabled = not explorando or not possui
	botao_curto.disabled = not explorando or not possui or not campanha.fim_turno_exploracao or selecao_habilidade.get_item_metadata(selecao_habilidade.selected) == ""
	botao_longo.disabled = not explorando or not possui or not campanha.fim_turno_exploracao or campanha.localizacao not in Descanso.SEGUROS
	botao_curto.tooltip_text = "Fim de turno de deslocamento + 1 mantimento; recupera exatamente a habilidade gasta escolhida."
	botao_longo.tooltip_text = "Fim de turno + 1 mantimento em Cidade, Vila ou Acampamento Protegido. Proibido na masmorra."
	botao_continuar.visible = campanha.fase == "vitoria"
	botao_salvar.disabled = campanha.fase == "combate" or is_instance_valid(combate)
	botao_carregar.disabled = is_instance_valid(combate) or not salvamento.existe()

func atualizar() -> void:
	var dados: Dictionary = campanha.dados_capitulo()
	fundo_arte.texture = CenarioVisual.textura_fundo(dados["local"])
	titulo.text = dados["titulo"]
	local.text = "Capítulo %d/4 • %s • Turno de exploração %d%s" % [campanha.capitulo + 1, campanha.localizacao, campanha.turno_exploracao, " concluído" if campanha.fim_turno_exploracao else " em andamento"]
	narrativa.text = dados["intro"] if campanha.fase == "exploracao" else dados["vitoria"]
	if campanha.fase == "derrota":
		titulo.text = "DERROTA — BROKK CAIU"
		narrativa.text = "Zeno caiu. A carga continua nas mãos de Tripa Seca.\n\nA campanha terminou em derrota. Use Reiniciar para começar novamente, sem recompensas ou progressão desta batalha."
	elif campanha.fase in ["vitoria", "final"]:
		narrativa.text += "\n\nRECOMPENSAS\n" + campanha.ultima_recompensa
		if campanha.fase == "final":
			titulo.text = "VITÓRIA — SANTA MINA ESTÁ ABASTECIDA!"
	var estado: RefCounted = campanha.estado_brokk
	estatisticas.text = "ZENO • HUMANO GUERREIRO\nPV %d/%d • +%d temporários • %d coroas\nMestre das Armas: %s\nMuralha de Ferro: %s" % [estado.pv_atuais, estado.pv_maximos, campanha.alimentos.pv_temporarios(), campanha.inventario.coroas, "gasta" if estado.mestre_armas_usado else "disponível", "gasta" if estado.muralha_usada else "disponível"]
	estatisticas.tooltip_text = "Efeitos: " + campanha.alimentos.resumo()
	var linhas: Array[String] = ["MANTIMENTOS (provisões iniciais de teste)"]
	for id in campanha.inventario.mantimentos:
		linhas.append("%s ×%d" % [Comidas.ITENS[id]["nome"], campanha.inventario.mantimentos[id]])
	linhas.append("\nEQUIPAMENTOS — guardados, não equipados")
	for nome in campanha.inventario.equipamentos:
		linhas.append("%s ×%d" % [nome, campanha.inventario.equipamentos[nome]])
	for nome in campanha.inventario.especiais:
		linhas.append("%s ×%d (efeito pendente)" % [nome, campanha.inventario.especiais[nome]])
	linhas.append("\nEFEITOS: " + campanha.alimentos.resumo())
	inventario.text = "\n".join(linhas)
	var escolhido := _comida()
	selecao_comida.clear()
	for id in Comidas.ITENS:
		selecao_comida.add_item("%s ×%d" % [Comidas.ITENS[id]["nome"], campanha.inventario.mantimentos.get(id, 0)])
		var indice := selecao_comida.item_count - 1
		selecao_comida.set_item_metadata(indice, id)
		if id == escolhido:
			selecao_comida.select(indice)
	selecao_habilidade.clear()
	for id in ["mestre_armas_usado", "muralha_usada"]:
		if estado.get(id):
			selecao_habilidade.add_item("Mestre das Armas" if id == "mestre_armas_usado" else "Muralha de Ferro")
			selecao_habilidade.set_item_metadata(selecao_habilidade.item_count - 1, id)
	if selecao_habilidade.item_count == 0:
		selecao_habilidade.add_item("Nenhuma habilidade gasta")
		selecao_habilidade.set_item_metadata(0, "")
	atualizar_botoes()

func _deslocar() -> void:
	if campanha.concluir_deslocamento():
		mensagem.text = "Turno de deslocamento concluído. Descanso disponível se os demais requisitos forem cumpridos."
	atualizar()

func _consumir() -> void:
	mensagem.text = "Mantimento consumido; efeito aplicado." if campanha.consumir(_comida()) else "Consumo não permitido ou estoque vazio."
	atualizar()

func _descansar(tipo: String) -> void:
	var habilidade := str(selecao_habilidade.get_item_metadata(selecao_habilidade.selected))
	var resultado: Dictionary = campanha.descansar(tipo, _comida(), habilidade)
	mensagem.text = resultado["mensagem"]
	atualizar()

func _continuar() -> void:
	if campanha.avancar_capitulo():
		mensagem.text = "PV e habilidades preservados. Prepare-se antes do próximo confronto."
	atualizar()

func _reiniciar() -> void:
	campanha.reiniciar()
	mensagem.text = "Nova campanha. Provisões de teste: uma unidade de cada alimento, sem preços."
	atualizar()

func _salvar() -> void:
	if is_instance_valid(combate):
		mensagem.text = "Conclua o combate antes de salvar."
		return
	var resultado := salvamento.salvar(campanha)
	mensagem.text = resultado["mensagem"]
	atualizar_botoes()

func _carregar() -> void:
	if is_instance_valid(combate) or campanha.fase == "combate":
		mensagem.text = "Conclua o combate antes de carregar uma campanha."
		return
	var resultado := salvamento.carregar()
	if resultado["ok"]:
		campanha = resultado["campanha"]
	mensagem.text = resultado["mensagem"]
	atualizar()

func iniciar_combate(semente: int = -1) -> void:
	if not campanha.iniciar_confronto():
		return
	mensagem.text = ""
	combate = load("res://Combate.tscn").instantiate()
	combate.ambiente = campanha.dados_capitulo()["local"]
	combate.semente_inicial = semente
	combate.estado_brokk = campanha.estado_brokk
	combate.ficha_brokk = campanha.ficha_brokk
	combate.alimentos = campanha.alimentos
	combate.inimigos = campanha.inimigos_atuais
	combate.combate_finalizado.connect(_confronto_concluido)
	tela.visible = false
	add_child(combate)

func _confronto_concluido(vitoria: bool) -> void:
	if not campanha.concluir_confronto(vitoria):
		return
	mensagem.text = "Minicampanha concluída! Mantimentos recuperados." if campanha.fase == "final" else ("Capítulo vencido. Consulte as recompensas e continue quando estiver pronto." if vitoria else "Zeno foi derrotado. Reinicie para tentar novamente.")
	_retornar.call_deferred()

func _retornar() -> void:
	if is_instance_valid(combate):
		combate.queue_free()
	combate = null
	tela.visible = true
	atualizar()

func iniciar_original() -> void:
	combate = load("res://Combate.tscn").instantiate()
	combate.combate_finalizado.connect(func(_vitoria: bool) -> void: _retornar.call_deferred())
	tela.visible = false
	add_child(combate)
