extends Control
const ARQUEIRO = preload("res://scenes/characters/BandidoArqueiro.tscn")
const BROKK = preload("res://scenes/characters/Brokk.tscn")
var grande: Sprite2D
var pequeno: Sprite2D
var brokk: Sprite2D
var botao: Button

func _ready() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color("171C25")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	_rotulo("BANDIDO ARQUEIRO • HUMANO", Vector2(30, 20), 25)
	_rotulo("Proporção revisada • cabeça menor, tronco e pernas alongados", Vector2(30, 60), 16)
	for x in [595, 727]:
		var casa := ColorRect.new()
		casa.position = Vector2(x, 206)
		casa.size = Vector2(88, 88)
		casa.color = Color("34495a")
		add_child(casa)
	grande = ARQUEIRO.instantiate()
	grande.position = Vector2(270, 275) # Reserva espaço acima para o arco erguido.
	grande.scale = Vector2.ONE * 3
	add_child(grande)
	# O componente controla somente o filho; escala da raiz é do mostruário.
	grande.scale = Vector2.ONE * 3
	brokk = BROKK.instantiate()
	brokk.position = Vector2(639, 250)
	add_child(brokk)
	pequeno = ARQUEIRO.instantiate()
	pequeno.position = Vector2(771, 250)
	add_child(pequeno)
	_rotulo("Brokk", Vector2(615, 310), 16)
	_rotulo("Humano", Vector2(743, 310), 16)
	_rotulo("Escala de combate • casas 88×88", Vector2(580, 337), 16)
	_rotulo("Ampliação 3×", Vector2(215, 380), 16)
	var acoes := [&"disparo", &"caminhar", &"dano", &"morte", &"idle"]
	var nomes := ["Disparar", "Caminhar", "Dano", "Morte", "Idle / reiniciar"]
	for i in range(acoes.size()):
		var escolha := Button.new()
		escolha.text = nomes[i]
		escolha.position = Vector2(555 + (i % 3) * 126, 380 + (i / 3) * 42)
		escolha.size = Vector2(118, 36)
		escolha.pressed.connect(executar_acao.bind(acoes[i]))
		add_child(escolha)
		if i == 0:
			botao = escolha
	_rotulo("Mostruário: animações sem PA, rolagens ou dano.\nNo combate, a flecha existente sai na soltura da corda.", Vector2(30, 485), 15)

func _rotulo(texto: String, posicao: Vector2, tamanho: int) -> void:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rotulo)

func executar_acao(acao: StringName) -> void:
	if grande.em_disparo or (not grande.vivo and acao != &"idle"):
		return
	if acao == &"disparo":
		botao.disabled = true
		for sprite in [grande, pequeno]:
			sprite.parar_deslocamento()
			sprite.animar_disparo_ate_soltura()
		await grande.animacao.animation_finished
		botao.disabled = false
		return
	for sprite in [grande, pequeno]:
		if acao == &"idle":
			sprite.definir_vivo(true)
			sprite.parar_deslocamento()
		elif acao == &"caminhar":
			sprite.iniciar_deslocamento(false, Vector2.LEFT)
		else:
			sprite.parar_deslocamento()
			if acao == &"dano":
				sprite.reagir_impacto(false, 1)
			else:
				sprite.definir_vivo(false)
