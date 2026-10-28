extends Control
## Comparação de todos os visuais, sem PA, dados, inimigos extras ou combate.
const Adaptador = preload("res://adaptador_encontro.gd")
const BROKK = preload("res://scenes/characters/Brokk.tscn")
var atores: Array[Sprite2D] = []

func _ready() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color("171C25")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	_rotulo("SANTA MINA • PERSONAGENS ORIGINAIS", Vector2(26, 12), 23)
	_rotulo("Escala ampliada igualmente em 1,5× • sem regras de combate neste mostruário", Vector2(26, 43), 14)
	var nomes: Array = Adaptador.VISUAIS.keys()
	nomes.append("Brokk Pedraférrea")
	for i in range(nomes.size()):
		var ator: Sprite2D = BROKK.instantiate() if i == nomes.size() - 1 else Adaptador.VISUAIS[nomes[i]].instantiate()
		ator.position = Vector2(120 + (i % 4) * 240, 174 + (i / 4) * 210)
		add_child(ator)
		ator.scale = Vector2.ONE * 1.5
		if i == nomes.size() - 1:
			ator.ocultar_apos_morte = false
		atores.append(ator)
		var nome := _rotulo(nomes[i], Vector2((i % 4) * 240, 228 + (i / 4) * 210), 15)
		nome.size.x = 240
		nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var acoes := [&"ataque", &"caminhar", &"dano", &"morte", &"idle"]
	var textos := ["Atacar", "Caminhar", "Dano", "Morte", "Idle / reiniciar"]
	for i in range(acoes.size()):
		var botao := Button.new()
		botao.text = textos[i]
		botao.position = Vector2(26 + i * 184, 485)
		botao.size = Vector2(174, 36)
		botao.pressed.connect(executar_acao.bind(acoes[i]))
		add_child(botao)

func _rotulo(texto: String, posicao: Vector2, fonte: int) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.add_theme_font_size_override("font_size", fonte)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rotulo)
	return rotulo

func executar_acao(acao: StringName) -> void:
	for ator in atores:
		var arqueiro: bool = ator.has_meta("arqueiro_original")
		if (ator.em_disparo if arqueiro else ator.em_ataque):
			continue
		if acao == &"idle":
			ator.definir_vivo(true)
			ator.parar_deslocamento()
		elif not ator.vivo:
			continue
		elif acao == &"caminhar":
			ator.iniciar_deslocamento(false, Vector2.RIGHT if ator == atores[-1] else Vector2.LEFT)
		else:
			ator.parar_deslocamento()
			if acao == &"morte":
				ator.definir_vivo(false)
			elif acao == &"dano":
				ator.reagir_impacto(false, 1)
			elif arqueiro:
				ator.animar_disparo_ate_soltura()
			elif ator == atores[-1]:
				ator.animar_ataque_ate_impacto()
			else:
				ator.animar_golpe_ate_impacto()
