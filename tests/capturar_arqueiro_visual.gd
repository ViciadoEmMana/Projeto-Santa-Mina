extends "res://tests/teste_brokk.gd"

func foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura real: " + nome)

func _executar() -> void:
	Engine.time_scale = 1.0
	var demo: Control = load("res://ArqueiroAnimacoes.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await foto("arqueiro_humano_comparacao")
	demo.executar_acao(&"disparo")
	await demo.grande.soltura
	paused = true
	await foto("arqueiro_disparo_original")
	paused = false
	await demo.grande.animacao.animation_finished
	demo.executar_acao(&"caminhar")
	await create_timer(0.2).timeout
	await foto("arqueiro_caminhada_original")
	demo.executar_acao(&"dano")
	await create_timer(0.1).timeout
	await foto("arqueiro_dano_original")
	demo.executar_acao(&"morte")
	await demo.grande.morte_finalizada
	await foto("arqueiro_morte_original")
	demo.queue_free()
	await process_frame
	Engine.time_scale = 5
	await _novo_combate(true)
	await foto("arqueiro_combate_idle")
	Engine.time_scale = 0.5
	cena.ordem_turnos.assign(["Bandido", "Brokk", "Porrete"])
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente([4])
	cena._executar_ataque_bandido()
	await cena.sprite_bandido.soltura
	paused = true
	await foto("arqueiro_combate_disparo")
	paused = false
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	_aproximar_brokk()
	cena.vida_bandido = 1 # Fixture visual de morte por ataque real, não regra nova.
	cena.gerador.seed = _semente([2])
	cena._ao_atacar()
	await cena.sprite_bandido.morte_finalizada
	await foto("arqueiro_combate_morte")
	Engine.time_scale = 5
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS ARQUEIRO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
