extends Control
## Mostruário separado. Não participa da campanha nem altera fichas de combate.
const PORRETE = preload("res://scenes/characters/BandidoPorrete.tscn")
const ARQUEIRO = preload("res://scenes/characters/BandidoArqueiro.tscn")
const BROKK = preload("res://scenes/characters/Brokk.tscn")
var grande: Sprite2D
var pequeno: Sprite2D

func _ready() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color("171C25")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	_rotulo("BANDIDO DO PORRETE • HUMANO", Vector2(30, 20), 25)
	_rotulo("Arte original • proporções humanas • porrete de uma mão", Vector2(30, 60), 16)
	for x in [538, 670, 802]:
		var casa := ColorRect.new()
		casa.position = Vector2(x, 206)
		casa.size = Vector2(88, 88)
		casa.color = Color("34495a")
		add_child(casa)
	grande = PORRETE.instantiate()
	grande.position = Vector2(260, 275)
	add_child(grande)
	grande.scale = Vector2.ONE * 3
	var brokk: Sprite2D = BROKK.instantiate()
	brokk.position = Vector2(582, 250)
	add_child(brokk)
	var arqueiro: Sprite2D = ARQUEIRO.instantiate()
	arqueiro.position = Vector2(714, 250)
	add_child(arqueiro)
	pequeno = PORRETE.instantiate()
	pequeno.position = Vector2(846, 250)
	add_child(pequeno)
	_rotulo("Brokk", Vector2(560, 310), 16)
	_rotulo("Arqueiro", Vector2(680, 310), 16)
	_rotulo("Porrete", Vector2(818, 310), 16)
	_rotulo("Escala de combate • casas 88×88", Vector2(550, 341), 16)
	_rotulo("Ampliação 3×", Vector2(205, 385), 16)
	var acoes := [&"ataque", &"caminhar", &"dano", &"morte", &"idle"]
	var nomes := ["Golpear", "Caminhar", "Dano", "Morte", "Idle / reiniciar"]
	for i in range(acoes.size()):
		var escolha := Button.new()
		escolha.text = nomes[i]
		escolha.position = Vector2(547 + (i % 3) * 126, 380 + (i / 3) * 42)
		escolha.size = Vector2(118, 36)
		escolha.pressed.connect(executar_acao.bind(acoes[i]))
		add_child(escolha)
	_rotulo("Mostruário: sem PA, dados ou dano.\nNo combate, a pancada existente acompanha o contato do porrete.", Vector2(30, 485), 15)

func _rotulo(texto: String, posicao: Vector2, tamanho: int) -> void:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rotulo)

func executar_acao(acao: StringName) -> void:
	if grande.em_ataque or (not grande.vivo and acao != &"idle"):
		return
	for sprite in [grande, pequeno]:
		if acao == &"idle":
			sprite.definir_vivo(true)
			sprite.parar_deslocamento()
		elif acao == &"caminhar":
			sprite.iniciar_deslocamento(false, Vector2.LEFT)
		else:
			sprite.parar_deslocamento()
			if acao == &"ataque":
				sprite.animar_golpe_ate_impacto()
			elif acao == &"dano":
				sprite.reagir_impacto(false, 1)
			else:
				sprite.definir_vivo(false)
