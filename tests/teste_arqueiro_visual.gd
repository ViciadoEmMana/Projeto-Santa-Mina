extends "res://tests/teste_brokk.gd"
const VisualArqueiro = preload("res://scripts/presentation/arqueiro_visual.gd")
const SistemaCampanha = preload("res://sistema_campanha.gd")

func _executar() -> void:
	var contagens := {&"idle": 4, &"caminhar": 4, &"disparo": 8, &"dano": 4, &"morte": 8}
	for nome in contagens:
		_verificar(VisualArqueiro.QUADROS.get_frame_count(nome) == contagens[nome], "Quadros corretos: " + nome)
		for i in range(contagens[nome]):
			var atlas: AtlasTexture = VisualArqueiro.QUADROS.get_frame_texture(nome, i)
			_verificar(atlas.atlas.resource_path.ends_with("_v02.png"), "Somente revisão humana v02 entra na integração")
			_verificar(atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0, "Margens não cortam cabeça, arco ou corpo")
	await _novo_combate()
	var sprite: Sprite2D = cena.sprite_bandido
	_verificar(sprite.get_script() == VisualArqueiro and sprite.texture == null, "Arqueiro substituído por componente próprio")
	_verificar(cena.apresentacao.arena_visual.get_node("BandidoSprite") == sprite and cena.encontro.sprites["Bandido"] == sprite, "Referências do controlador e do adaptador apontam ao mesmo nó na arena")
	_verificar(cena.sprite_porrete.get_script() != VisualArqueiro, "Clone de porrete não herda arte de arqueiro")
	var atlas_idle: AtlasTexture = sprite.animacao.sprite_frames.get_frame_texture("idle", 0)
	var altura_humana: float = atlas_idle.region.size.y * sprite.animacao.scale.y
	var atlas_brokk: AtlasTexture = cena.sprite_brokk.animacao.sprite_frames.get_frame_texture("idle", 0)
	var altura_brokk: float = atlas_brokk.region.size.y * cena.sprite_brokk.animacao.scale.y
	_verificar(altura_humana > altura_brokk + 14 and altura_humana < 80, "Humano tem porte claramente mais alto que o anão sem sair da casa")
	var rng: int = cena.gerador.state
	await create_timer(0.3).timeout
	_verificar(cena.gerador.state == rng and cena.pa_bandido == 0, "Idle não rola nem concede PA")
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([4])
	var copia_rng := RandomNumberGenerator.new()
	copia_rng.state = cena.gerador.state
	copia_rng.randi_range(1, 6)
	await cena._executar_ataque_bandido()
	_verificar(sprite.reproducoes.get(&"disparo", 0) == 1 and cena.vida_brokk == 10, "Disparo real preserva 1d6+1 e Defesa de Brokk")
	_verificar(cena.pa_bandido == 0 and cena.gerador.state == copia_rng.state, "Um custo de ataque e nenhuma rolagem extra da animação")
	_verificar(sprite.animacao.animation == &"idle" and not sprite.em_disparo, "Recuperação do disparo retorna ao idle")
	# Usa parede para exigir deslocamento, pois a IA já ataca se há linha livre.
	cena.grade.obstaculos.assign([Vector2i(3, 1)])
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	rng = cena.gerador.state
	cena._mover_inimigo("Bandido")
	_verificar(sprite.em_movimento and sprite.animacao.animation == &"caminhar", "IA usa caminhada quando realmente precisa alcançar linha livre")
	for i in range(1500):
		await process_frame
		if not cena.movimento_em_andamento:
			break
	_verificar(cena.pa_bandido in [0, 1] and cena.gerador.state == rng, "Movimento preserva custo individual sem rolagens")
	cena.grade.obstaculos.clear()
	cena.turno_atual = "Brokk"
	cena.estado_brokk.iniciar_turno()
	_aproximar_brokk()
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 1 and sprite.reproducoes.get(&"dano", 0) == 1, "Dano recebido usa reação própria sem alterar PV calculado")
	cena.estado_brokk.iniciar_turno() # Novo turno controlado da fixture.
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 0 and sprite.reproducoes.get(&"morte", 0) == 1, "Morte inicia uma vez após dano fatal")
	_verificar(sprite.visible and sprite.rotation == 0 and sprite.animacao.frame == 7 and not sprite.animacao.is_playing(), "Corpo derrotado fica na última pose, sem rotação duplicada")
	cena._sincronizar_sprites()
	_verificar(sprite.reproducoes.get(&"morte", 0) == 1 and "Bandido" in cena.grade.derrotados, "Sincronização não reinicia morte e libera ocupação")
	await _fechar_combate()
	# Protege os capítulos que reutilizam o ID Bandido para goblin e chefe.
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
		_verificar(cena.sprite_bandido.get_script() != VisualArqueiro, "Arte humana não substitui criaturas do capítulo %d" % (capitulo + 1))
		await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO ARQUEIRO VISUAL: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
