extends Node2D
signal reacao_apresentada(nome: String)
## Apresentação apenas: recebe uma cópia do ataque e não conhece PV, PA ou estados.

const PASTA_AUDIO := "res://audio/combate/"
const SONS := ["escudo", "corte_normal", "corte_forte", "pancada_normal", "pancada_forte", "disparo_arco", "impacto_flecha", "impacto_flecha_forte"]
const CATEGORIAS := {
	"cortante": {"normal": "corte_normal", "forte": "corte_forte"},
	"perfurante": {"normal": "corte_normal", "forte": "corte_forte"},
	"contundente": {"normal": "pancada_normal", "forte": "pancada_forte"},
	"projetil": {"normal": "impacto_flecha", "forte": "impacto_flecha_forte"},
}

var sons: Dictionary = {}
var canais: Dictionary = {}
var ultimo_feedback: Dictionary = {}
var eventos: Array[String] = []
var resolucoes := 0


func _ready() -> void:
	z_index = 20
	for nome in SONS:
		sons[nome] = load(PASTA_AUDIO + nome + ".wav")
	for canal in ["arma", "impacto", "escudo"]:
		var player := AudioStreamPlayer.new()
		player.name = "Audio_" + canal
		player.volume_db = -9.0
		add_child(player)
		canais[canal] = player


func _exit_tree() -> void:
	for player: AudioStreamPlayer in canais.values():
		player.stop()
		player.stream = null
	sons.clear()


static func planejar(arma: Dictionary, ataque: Dictionary) -> Dictionary:
	var natural := int(ataque.get("natural", 0))
	var valido := natural >= 1 and natural <= int(arma.get("dado", 0))
	if int(arma.get("quantidade_dados", 1)) > 1:
		var dados: Array = ataque.get("dados_selecionados", [])
		valido = dados.size() == int(arma["quantidade_dados"])
		for dado in dados:
			valido = valido and int(dado) >= 1 and int(dado) <= int(arma["dado"])
	var acerto: bool = valido and not ataque.get("erro", true) and (natural != 1 or ataque.get("fogo_amigo", false))
	var fontes: Dictionary = ataque.get("fontes", {})
	var natural_escudo := int(ataque.get("natural_escudo", natural))
	return {
		"categoria": arma.get("categoria_efeito", "perfurante"),
		"acerto": acerto,
		"forte": acerto and int(arma.get("dado", 0)) == 6 and natural in [5, 6],
		"escudo": acerto and natural_escudo in [2, 3] and int(fontes.get("escudo", 0)) == 2 and int(ataque.get("defesa", 0)) >= 2 and not ataque.get("defesa_ignorada", false),
		"disparo": valido and arma.get("categoria_efeito", "") == "projetil",
	}


func _registrar(evento: String) -> void:
	eventos.append(evento)
	if eventos.size() > 128:
		eventos.pop_front()


func _tocar(som: String, canal: String) -> void:
	var player: AudioStreamPlayer = canais[canal]
	player.stream = sons[som]
	player.play()
	_registrar("som:" + som)


func apresentar(arma: Dictionary, ataque: Dictionary, atacante: Sprite2D, alvo: Sprite2D, escudo: Node2D = null) -> void:
	ultimo_feedback = planejar(arma, ataque)
	resolucoes += 1
	var categoria: String = ultimo_feedback["categoria"]
	var forte: bool = ultimo_feedback["forte"]
	if ultimo_feedback["disparo"]:
		if atacante.has_method("animar_disparo_ate_soltura"):
			atacante.call("olhar_para", alvo.position - atacante.position)
			await atacante.call("animar_disparo_ate_soltura")
		_tocar("disparo_arco", "arma")
		var chegada := alvo.position if ultimo_feedback["acerto"] else alvo.position + Vector2(0, -33)
		var origem: Vector2 = atacante.call("origem_disparo") if atacante.has_method("origem_disparo") else atacante.position
		await _flecha(origem, chegada, forte)
	elif atacante.has_method("animar_golpe_ate_impacto"):
		atacante.call("olhar_para", alvo.position - atacante.position)
		await atacante.call("animar_golpe_ate_impacto")
	if not ultimo_feedback["acerto"]:
		_registrar("erro")
		return
	_registrar("impacto:" + categoria + (":forte" if forte else ":normal"))
	var conjunto: Dictionary = CATEGORIAS.get(categoria, CATEGORIAS["perfurante"])
	_tocar(conjunto["forte" if forte else "normal"], "impacto")
	if alvo.has_method("reagir_impacto"):
		alvo.call("olhar_para", atacante.position - alvo.position)
		alvo.call("reagir_impacto", ultimo_feedback["escudo"] or ataque.get("muralha", false), int(ataque.get("dano_recebido", 0)))
	if forte:
		match categoria:
			"cortante":
				_corte(alvo.position)
			"contundente":
				_particulas(alvo.position, Color("bc9c73"), 10, 23.0)
			"projetil":
				_particulas(alvo.position, Color("ffd586"), 7, 18.0)
			"perfurante":
				_traco(alvo.position - Vector2(22, 0), alvo.position + Vector2(22, 0), Color("e8f6ff"), 3.0)
		_reagir(alvo, categoria == "contundente")
	if ultimo_feedback["escudo"] and is_instance_valid(escudo):
		_tocar("escudo", "escudo")
		_registrar("escudo")
		_particulas(to_local(escudo.global_position) + Vector2(22, 8), Color("ffe29a"), 7, 20.0)
		_vibrar_escudo(escudo)
		_texto_escudo(alvo.position)
	# Curto intervalo de impacto antes de atualizar PV e mensagens no controlador.
	await get_tree().create_timer(0.24).timeout


func _flecha(origem: Vector2, destino: Vector2, forte: bool) -> void:
	var flecha := Node2D.new()
	flecha.position = origem
	flecha.rotation = (destino - origem).angle()
	add_child(flecha)
	var haste := Line2D.new()
	haste.points = PackedVector2Array([Vector2(-18, 0), Vector2.ZERO])
	haste.width = 2.0
	haste.default_color = Color("c8a879")
	flecha.add_child(haste)
	var ponta := Polygon2D.new()
	ponta.polygon = PackedVector2Array([Vector2(5, 0), Vector2(-2, -3), Vector2(-2, 3)])
	ponta.color = Color("dae4eb")
	flecha.add_child(ponta)
	if forte:
		var rastro := Line2D.new()
		rastro.points = PackedVector2Array([Vector2(-39, 0), Vector2(-5, 0)])
		rastro.width = 4.0
		rastro.default_color = Color(1.0, 0.78, 0.35, 0.65)
		flecha.add_child(rastro)
	var tween := create_tween()
	tween.tween_property(flecha, "position", destino, 0.18)
	await tween.finished
	flecha.queue_free()


func _traco(inicio: Vector2, fim: Vector2, cor: Color, largura: float) -> void:
	var linha := Line2D.new()
	linha.points = PackedVector2Array([inicio, fim])
	linha.width = largura
	linha.default_color = cor
	add_child(linha)
	var tween := create_tween()
	tween.tween_property(linha, "modulate:a", 0.0, 0.20)
	tween.tween_callback(linha.queue_free)

func apresentar_reacao_chefe(nome: String, chefe: Sprite2D, alvo: Sprite2D) -> void:
	if chefe.has_method("animar_reacao"):
		chefe.call("olhar_para", alvo.position - chefe.position)
		await chefe.call("animar_reacao")
	_registrar("reacao:" + nome)
	if nome == "golpe_sujo":
		# Areia apenas visual; o teste DES/SAB permanece no resolvedor existente.
		for i in range(8):
			var grao := Polygon2D.new()
			grao.polygon = PackedVector2Array([Vector2(-1, -1), Vector2(2, -1), Vector2(1, 2)])
			grao.color = Color("d2b47e")
			grao.position = chefe.position + Vector2(-15, -15)
			add_child(grao)
			var tween := create_tween().set_parallel(true)
			tween.tween_property(grao, "position", alvo.position + Vector2((i % 3) * 3 - 3, -25 + i), 0.22)
			tween.tween_property(grao, "modulate:a", 0.0, 0.32)
			tween.chain().tween_callback(grao.queue_free)
	else:
		# Destaca o aliado real da transferência sem mover unidades ou recalcular dano.
		_particulas(alvo.position, Color("efc36d"), 8, 28.0)
		var linha := Line2D.new()
		linha.default_color = Color("efc36d")
		linha.width = 2
		linha.points = PackedVector2Array([alvo.position + Vector2(-32, -36), alvo.position + Vector2(32, -36), alvo.position + Vector2(32, 32), alvo.position + Vector2(-32, 32), alvo.position + Vector2(-32, -36)])
		add_child(linha)
		var tween := create_tween()
		tween.tween_property(linha, "modulate:a", 0.0, 0.45)
		tween.tween_callback(linha.queue_free)
	reacao_apresentada.emit(nome)
	await get_tree().create_timer(0.25).timeout


func apresentar_veterano(tipo: String, heroi: Sprite2D) -> void:
	# Apresentação somente: nenhuma rolagem, PA ou cálculo de dano aqui.
	_registrar("veterano:" + tipo)
	_tocar("escudo" if tipo == "defesa" else "corte_forte", "escudo" if tipo == "defesa" else "arma")
	var cor := Color("79c5ff") if tipo == "defesa" else Color("ffc464")
	_particulas(heroi.position + Vector2(0, -8), cor, 8, 25.0)
	var texto := Label.new()
	texto.text = "VETERANO +1 " + ("DEF" if tipo == "defesa" else "DANO")
	texto.position = heroi.position + Vector2(-58, -48)
	texto.add_theme_font_size_override("font_size", 12)
	texto.modulate = cor
	add_child(texto)
	var tween := create_tween()
	tween.tween_property(texto, "position:y", texto.position.y - 15, 0.6)
	tween.parallel().tween_property(texto, "modulate:a", 0.0, 0.6)
	tween.tween_callback(texto.queue_free)
	await get_tree().create_timer(0.25).timeout


func _corte(centro: Vector2) -> void:
	var arco := Line2D.new()
	arco.width = 4.0
	arco.default_color = Color("e5f5ff")
	for i in range(13):
		var angulo := lerpf(-2.6, 0.5, float(i) / 12.0)
		arco.add_point(centro + Vector2(cos(angulo) * 29, sin(angulo) * 20))
	add_child(arco)
	var tween := create_tween()
	tween.tween_property(arco, "modulate:a", 0.0, 0.20)
	tween.tween_callback(arco.queue_free)


func _particulas(centro: Vector2, cor: Color, quantidade: int, distancia: float) -> void:
	# Trajetórias radiais determinísticas: não usam o gerador dos dados de combate.
	for i in range(quantidade):
		var particula := Polygon2D.new()
		particula.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2), Vector2(2, 0), Vector2(0, 2)])
		particula.color = cor
		particula.position = centro
		add_child(particula)
		var angulo := TAU * float(i) / quantidade
		var tween := create_tween().set_parallel(true)
		tween.tween_property(particula, "position", centro + Vector2(cos(angulo), sin(angulo)) * distancia, 0.22)
		tween.tween_property(particula, "modulate:a", 0.0, 0.22)
		tween.chain().tween_callback(particula.queue_free)


func _reagir(alvo: Sprite2D, vibracao: bool) -> void:
	var cor_original := alvo.modulate
	var offset_original := alvo.offset
	alvo.modulate = Color("fff2d5")
	var tween := create_tween()
	if vibracao:
		for deslocamento in [2.0, -2.0, 1.0, 0.0]:
			tween.tween_property(alvo, "offset", offset_original + Vector2(deslocamento, 0), 0.035)
	else:
		tween.tween_interval(0.14)
	tween.tween_callback(func() -> void:
		alvo.modulate = cor_original
		alvo.offset = offset_original)


func _vibrar_escudo(escudo: Node2D) -> void:
	var rotacao_original := escudo.rotation
	var tween := create_tween()
	for deslocamento in [0.09, -0.09, 0.05, 0.0]:
		tween.tween_property(escudo, "rotation", rotacao_original + deslocamento, 0.04)


func _texto_escudo(centro: Vector2) -> void:
	var texto := Label.new()
	texto.text = "ESCUDO! −2 DANO"
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.add_theme_font_size_override("font_size", 12)
	texto.add_theme_color_override("font_color", Color("ffe2a0"))
	texto.position = Vector2(clampf(centro.x - 85, 44, 402), maxf(212, centro.y - 38))
	add_child(texto)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(texto, "position:y", texto.position.y - 18, 0.40)
	tween.tween_property(texto, "modulate:a", 0.0, 0.40)
	tween.chain().tween_callback(texto.queue_free)
