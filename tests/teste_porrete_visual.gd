extends "res://tests/teste_brokk.gd"
const VisualPorrete = preload("res://scripts/presentation/porrete_visual.gd")
const SistemaCampanha = preload("res://sistema_campanha.gd")

func _executar() -> void:
	var contagens := {&"idle": 4, &"caminhar": 4, &"ataque": 8, &"dano": 4, &"morte": 8}
	for nome in contagens:
		_verificar(VisualPorrete.QUADROS.get_frame_count(nome) == contagens[nome], "Quadros corretos: " + nome)
		_verificar(VisualPorrete.QUADROS.get_animation_loop(nome) == (nome in [&"idle", &"caminhar"]), "Loop somente em idle e caminhada")
		for i in range(contagens[nome]):
			var atlas: AtlasTexture = VisualPorrete.QUADROS.get_frame_texture(nome, i)
			_verificar(atlas.atlas.resource_path.begins_with("res://assets/enemies/bandits/porrete/"), "Fonte exclusiva e original do bandido")
			_verificar(atlas.get_size() == Vector2(640, 640) and atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0, "Tela estável com margem sem recortes")
			_verificar(is_equal_approx(atlas.margin.position.y + atlas.region.size.y, 560), "Apoio dos pés permanece no mesmo chão")
	await _novo_combate(true)
	var sprite: Sprite2D = cena.sprite_porrete
	_verificar(sprite.get_script() == VisualPorrete and sprite.texture == null, "Componente próprio substitui somente o humano de porrete")
	_verificar(cena.apresentacao.arena_visual.get_node("BandidoPorreteSprite") == sprite and cena.encontro.sprites["Porrete"] == sprite, "Referências do nó e do adaptador coincidem na arena")
	_verificar(cena.porrete_visual.get_parent() == sprite and is_zero_approx(cena.porrete_visual.modulate.a), "Âncora preservada sem porrete geométrico duplicado")
	var atlas_idle: AtlasTexture = sprite.animacao.sprite_frames.get_frame_texture("idle", 0)
	var atlas_brokk: AtlasTexture = cena.sprite_brokk.animacao.sprite_frames.get_frame_texture("idle", 0)
	var altura_humana: float = atlas_idle.region.size.y * sprite.animacao.scale.y
	var altura_brokk: float = atlas_brokk.region.size.y * cena.sprite_brokk.animacao.scale.y
	_verificar(altura_humana > altura_brokk + 14 and altura_humana < 80, "Bandido mantém porte humano maior que o anão")
	var rng: int = cena.gerador.state
	await create_timer(0.3).timeout
	_verificar(cena.gerador.state == rng, "Idle não consome RNG")
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Porrete": Vector2i(3, 1), "Bandido": Vector2i(5, 0)}
	cena._sincronizar_sprites()
	cena.ordem_turnos.assign(["Porrete", "Brokk", "Bandido"])
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(sprite.reproducoes.get(&"ataque", 0) == 0 and cena.gerador.state == rng, "Fora do turno não anima, rola ou cobra")
	for natural in [1, 2, 4, 6]:
		cena.vida_brokk = 14
		cena.turno_atual = "Porrete"
		cena.inimigos["Porrete"].pa_atuais = 3
		cena.gerador.seed = _semente([natural])
		var copia := RandomNumberGenerator.new()
		copia.state = cena.gerador.state
		copia.randi_range(1, 6)
		var ataques: int = sprite.reproducoes.get(&"ataque", 0)
		await cena._executar_ataque_inimigo("Porrete")
		var esperado: int = 0 if natural == 1 else natural + 2 - (3 if natural in [2, 3] else 1)
		_verificar(cena.vida_brokk == 14 - esperado, "Dano e Defesa preservados no natural %d" % natural)
		_verificar(sprite.reproducoes.get(&"ataque", 0) == ataques + 1, "Um golpe visual por ataque, incluindo erro")
		_verificar(cena.inimigos["Porrete"].pa_atuais == 0 and cena.gerador.state == copia.state, "Ataque cobra 3 PA e uma rolagem, sem extras do visual")
		_verificar(cena.Dados3D.resultado_visivel(cena.dado_bandido_3d) == natural, "Dado vermelho coincide com cálculo")
		_verificar(sprite.animacao.animation == &"idle" and not sprite.em_ataque, "Golpe recupera sem bloquear o próximo turno")
		_verificar(not cena.estado_brokk.condicoes.derrubado, "Firmeza de Rocha preservada contra porrete d6")
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 2
	var ataques: int = sprite.reproducoes.get(&"ataque", 0)
	rng = cena.gerador.state
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(sprite.reproducoes.get(&"ataque", 0) == ataques and cena.gerador.state == rng, "PA insuficientes não iniciam golpe")
	cena.grade.posicoes["Porrete"] = Vector2i(5, 2)
	cena.grade.obstaculos.assign([Vector2i(4, 2)])
	cena._sincronizar_sprites()
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 3
	cena._mover_inimigo("Porrete")
	_verificar(sprite.em_movimento and sprite.animacao.animation == &"caminhar", "Movimento válido usa caminhada")
	for i in range(1500):
		await process_frame
		if not cena.movimento_em_andamento:
			break
	_verificar(not sprite.em_movimento and sprite.animacao.animation == &"idle", "Caminhada encerra no destino")
	_verificar(cena.grade.posicoes["Porrete"] != Vector2i(4, 2) and cena.inimigos["Porrete"].pa_atuais in [0, 1], "IA respeita obstáculo e custo de movimento")
	cena.grade.obstaculos.clear()
	cena.grade.posicoes["Porrete"] = Vector2i(3, 1)
	cena._sincronizar_sprites()
	cena.turno_atual = "Brokk"
	cena.estado_brokk.iniciar_turno()
	cena._selecionar_alvo("Porrete")
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	_verificar(cena.inimigos["Porrete"].pv_atuais == 3 and sprite.reproducoes.get(&"dano", 0) == 1, "Golpe real de Brokk aplica dano e reação")
	cena.estado_brokk.iniciar_turno() # Novo turno controlado da fixture.
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	_verificar(cena.inimigos["Porrete"].pv_atuais == 0 and sprite.reproducoes.get(&"morte", 0) == 1, "Dano fatal inicia uma única morte")
	_verificar(sprite.visible and sprite.rotation == 0 and sprite.animacao.frame == 7 and not sprite.animacao.is_playing(), "Último quadro de morte permanece sem rotação duplicada")
	cena._sincronizar_sprites()
	_verificar(sprite.reproducoes.get(&"morte", 0) == 1 and "Porrete" in cena.grade.derrotados, "Sincronização não reinicia morte e mantém casa liberada")
	await _fechar_combate()
	for capitulo in [1, 2, 3]:
		var campanha := SistemaCampanha.new()
		campanha.capitulo = capitulo
		campanha.iniciar_confronto()
		cena = load("res://Combate.tscn").instantiate()
		cena.inimigos = campanha.inimigos_atuais
		cena.semente_inicial = 17
		root.add_child(cena)
		for i in range(2000):
			await process_frame
			if cena.selecionando_posicao:
				break
		_verificar(cena.sprite_porrete.get_script() != VisualPorrete, "Humano não substitui goblins do capítulo %d" % (capitulo + 1))
		await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO PORRETE VISUAL: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
