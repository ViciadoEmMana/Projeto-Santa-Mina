extends "res://tests/teste_brokk.gd"

func foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura real: " + nome)

func _executar() -> void:
	Engine.time_scale = 1.0
	var demo: Control = load("res://PorreteAnimacoes.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await foto("porrete_humano_comparacao")
	demo.executar_acao(&"ataque")
	await demo.grande.impacto
	paused = true
	await foto("porrete_ataque_original")
	paused = false
	await demo.grande.animacao.animation_finished
	demo.executar_acao(&"caminhar")
	await create_timer(0.2).timeout
	await foto("porrete_caminhada_original")
	demo.executar_acao(&"dano")
	await create_timer(0.1).timeout
	await foto("porrete_dano_original")
	demo.executar_acao(&"morte")
	await demo.grande.morte_finalizada
	await foto("porrete_morte_original")
	demo.queue_free()
	await process_frame
	Engine.time_scale = 5
	await _novo_combate(true)
	await foto("porrete_combate_idle")
	cena.ordem_turnos.assign(["Porrete", "Brokk", "Bandido"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Porrete": Vector2i(3, 1), "Bandido": Vector2i(5, 0)}
	cena._sincronizar_sprites()
	Engine.time_scale = 0.5
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 3
	cena.gerador.seed = _semente([4])
	cena._executar_ataque_inimigo("Porrete")
	await cena.sprite_porrete.impacto
	paused = true
	await foto("porrete_combate_ataque")
	paused = false
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	cena.inimigos["Porrete"].pv_atuais = 1 # Fixture de ataque fatal, não regra nova.
	cena._selecionar_alvo("Porrete")
	cena.gerador.seed = _semente([2])
	cena._ao_atacar()
	await cena.sprite_porrete.morte_finalizada
	await foto("porrete_combate_morte")
	Engine.time_scale = 5
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS PORRETE: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
