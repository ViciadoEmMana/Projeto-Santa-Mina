extends Control
## Mostruário independente, sem estado de combate nem assets externos.
const Brokk = preload("res://scenes/characters/Brokk.tscn")
var grande: Sprite2D
var pequeno: Sprite2D
var botao: Button
var estado: Label

func _ready() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color("171C25")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	_rotulo("BROKK PEDRAFÉRREA • ANIMAÇÕES", Vector2(30, 22), 25)
	_rotulo("Anão Guerreiro • arte própria a partir do conceito aprovado", Vector2(30, 60), 16)
	_rotulo("Ampliação 4× para inspecionar os quadros", Vector2(85, 385), 16)
	_rotulo("Escala de combate • casa 88×88", Vector2(580, 310), 16)
	var casa := ColorRect.new()
	casa.position = Vector2(656, 206)
	casa.size = Vector2(88, 88)
	casa.color = Color("34495a")
	add_child(casa)
	grande = Brokk.instantiate()
	grande.position = Vector2(260, 230)
	grande.scale = Vector2.ONE * 4
	grande.ocultar_apos_morte = false
	add_child(grande)
	pequeno = Brokk.instantiate()
	pequeno.position = Vector2(700, 250)
	pequeno.ocultar_apos_morte = false
	add_child(pequeno)
	botao = Button.new()
	botao.text = "Atacar com machado"
	botao.position = Vector2(555, 345)
	botao.size = Vector2(118, 36)
	botao.pressed.connect(atacar)
	add_child(botao)
	botao.text = "Machado"
	var nomes := ["Caminhar", "Correr", "Defender", "Dano", "Morte", "Idle / reiniciar"]
	var acoes := [&"caminhar", &"correr", &"defesa", &"dano", &"morte", &"idle"]
	for i in range(nomes.size()):
		var escolha := Button.new()
		escolha.text = nomes[i]
		escolha.position = Vector2(555 + ((i + 1) % 3) * 126, 345 + ((i + 1) / 3) * 42)
		escolha.size = Vector2(118, 36)
		escolha.pressed.connect(executar_acao.bind(acoes[i]))
		add_child(escolha)
	estado = Label.new()
	estado.position = Vector2(555, 477)
	estado.text = "Idle • corpo e equipamentos preservados"
	add_child(estado)
	_rotulo("Mostruário visual: não rola dados nem aplica dano. Movimento em ciclo no lugar;\nno combate, os mesmos quadros acompanham o caminho real. Idle reinicia após a morte.", Vector2(30, 498), 14)

func _rotulo(texto: String, posicao: Vector2, tamanho: int) -> void:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rotulo)

func atacar() -> void:
	if not grande.vivo or grande.em_ataque or pequeno.em_ataque:
		return
	grande.parar_deslocamento()
	pequeno.parar_deslocamento()
	botao.disabled = true
	grande.animar_ataque_ate_impacto()
	pequeno.animar_ataque_ate_impacto()
	await grande.animacao.animation_finished
	botao.disabled = false

func executar_acao(acao: StringName) -> void:
	if grande.em_ataque:
		return
	if acao != &"idle" and not grande.vivo:
		return
	for sprite in [grande, pequeno]:
		if acao == &"idle":
			sprite.definir_vivo(true)
			sprite.parar_deslocamento()
		elif acao in [&"caminhar", &"correr"]:
			sprite.iniciar_deslocamento(acao == &"correr")
		else:
			sprite.parar_deslocamento()
			if acao == &"defesa":
				sprite.defender()
			elif acao == &"dano":
				sprite.reagir_impacto(false, 1)
			else:
				sprite.definir_vivo(false)
	estado.text = "Visual: " + String(acao) + (" • use Idle para reiniciar" if acao == &"morte" else "")
