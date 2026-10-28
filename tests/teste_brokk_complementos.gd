extends "res://tests/teste_brokk.gd"
const Visual = preload("res://scripts/presentation/brokk_visual.gd")

func _esperar_movimento() -> void:
	for i in range(1500):
		await process_frame
		if not cena.movimento_em_andamento:
			return
	_verificar(false, "Movimento deve terminar sem travar")

func _executar() -> void:
	var definicoes := {&"caminhar": 8, &"correr": 8, &"defesa": 4, &"dano": 4, &"morte": 8}
	for nome in definicoes:
		var quadros: SpriteFrames = Visual.COMPLEMENTOS
		_verificar(quadros.get_frame_count(nome) == definicoes[nome], "Quantidade de quadros: " + nome)
		_verificar(quadros.get_animation_loop(nome) == (nome in [&"caminhar", &"correr"]), "Loop somente nos deslocamentos")
		for i in range(definicoes[nome]):
			var atlas: AtlasTexture = quadros.get_frame_texture(nome, i)
			_verificar(atlas.atlas.resource_path.begins_with("res://assets/characters/brokk/"), "Fonte própria, sem imagens legadas")
			_verificar(atlas.get_size() == Vector2(384, 384), "Tela virtual estável entre poses")
			_verificar(atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0 and atlas.region.size.x * Visual.ESCALA_ATLAS * float(Visual.ESCALAS.get(nome, 1.0)) < 88, "Corpo, armas e queda cabem na casa")
	await _novo_combate()
	var sprite: Sprite2D = cena.sprite_brokk
	_verificar(sprite.animacao.sprite_frames != Visual.QUADROS and not Visual.QUADROS.has_animation("morte"), "Combinação de recursos não modifica atlas compartilhado original")
	var rng: int = cena.gerador.state
	cena._mover_para(Vector2i(1, 1))
	_verificar(cena.movimento_em_andamento and sprite.em_movimento and sprite.animacao.animation == &"caminhar", "Caminhada inicia junto ao deslocamento válido")
	_verificar(sprite.animacao.flip_h, "Deslocamento à esquerda orienta somente a apresentação")
	await cena._ao_atacar()
	_verificar(cena.estado_brokk.pa_atuais == 3 and cena.gerador.state == rng, "Ação concorrente durante caminhada não cobra ou rola")
	await _esperar_movimento()
	_verificar(cena.grade.posicoes["Brokk"] == Vector2i(1, 1) and cena.estado_brokk.pa_atuais == 3, "Mover continua ortogonal e custa 2 PA")
	_verificar(not sprite.em_movimento and sprite.animacao.animation == &"idle", "Caminhada termina em idle")
	cena._mover_para(Vector2i(0, 0), true)
	_verificar(sprite.animacao.animation == &"correr" and cena.estado_brokk.pa_atuais == 0, "Corrida usa sua animação e cobra somente 3 PA")
	await _esperar_movimento()
	_verificar(cena.grade.posicoes["Brokk"] == Vector2i(0, 0) and cena.gerador.state == rng, "Corrida termina no destino sem rolagens extras")
	await _fechar_combate()
	await _novo_combate()
	sprite = cena.sprite_brokk
	rng = cena.gerador.state
	cena._defender()
	_verificar(sprite.animacao.animation == &"defesa" and cena.estado_brokk.pa_atuais == 4 and cena.estado_brokk.bonus_defesa_temporaria == 2, "Defender apresenta escudo e preserva bônus/custo")
	cena._defender()
	_verificar(sprite.reproducoes.get(&"defesa", 0) == 1 and cena.estado_brokk.pa_atuais == 4, "Defender duplicado não cobra nem reinicia animação")
	await create_timer(0.6).timeout
	_verificar(sprite.animacao.animation == &"idle" and cena.gerador.state == rng, "Defesa recupera sem alterar RNG")
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([4])
	await cena._executar_ataque_bandido()
	_verificar(sprite.reproducoes.get(&"dano", 0) == 1 and cena.vida_brokk == 12, "Impacto real apresenta dano, Defesa e PV preservados")
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([2])
	await cena._executar_ataque_bandido()
	_verificar(sprite.reproducoes.get(&"defesa", 0) == 2 and cena.vida_brokk == 12, "Escudo condicional bloqueia visualmente sem inventar redução")
	var danos: int = sprite.reproducoes.get(&"dano", 0)
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([1])
	await cena._executar_ataque_bandido()
	_verificar(sprite.reproducoes.get(&"dano", 0) == danos and cena.vida_brokk == 12, "Erro não produz dano ou reação de acerto")
	cena.vida_brokk = 1 # Fixture exclusiva de ataque fatal, sem alterar a ficha.
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([4])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 0 and sprite.reproducoes.get(&"morte", 0) == 1, "Ataque fatal inicia uma única morte, sem ressuscitar")
	_verificar(not sprite.morte_em_andamento and not sprite.visible and sprite.animacao.frame == 7, "Morte termina no último quadro e mantém fluxo de derrota")
	cena._sincronizar_sprites()
	_verificar(sprite.reproducoes.get(&"morte", 0) == 1, "Atualizar interface não repete morte")
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO COMPLEMENTOS: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
