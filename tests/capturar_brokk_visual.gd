extends "res://tests/teste_brokk.gd"

func foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura renderizada: " + nome)

func _executar() -> void:
	Engine.time_scale = 1.0
	var demo: Control = load("res://BrokkAnimacoes.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await foto("brokk_idle_original")
	demo.atacar()
	await demo.grande.impacto
	await foto("brokk_ataque_original")
	await demo.grande.animacao.animation_finished
	demo.queue_free()
	await process_frame
	Engine.time_scale = 5.0
	await _novo_combate(true)
	await foto("brokk_combate_idle")
	_aproximar_brokk()
	cena.gerador.seed = _semente([6])
	Engine.time_scale = 1.0
	cena._ao_atacar()
	await cena.sprite_brokk.impacto
	await foto("brokk_combate_ataque")
	Engine.time_scale = 5.0
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	_verificar(cena.sprite_brokk.ataques_apresentados == 1 and cena.estado_brokk.pa_atuais == 2, "Golpe animado real com custo preservado")
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS BROKK: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
