extends "res://tests/teste_brokk.gd"

func foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura real: " + nome)

func fotografar_deslocamento(destino: Vector2i, correr: bool, nome: String) -> void:
	# Congela no evento real do segundo quadro para o driver não saltar a pose
	# durante a leitura do framebuffer. Não força posição, quadro, PA ou dano.
	var congelar := func() -> void:
		if cena.sprite_brokk.animacao.animation in [&"caminhar", &"correr"] and cena.sprite_brokk.animacao.frame == 2:
			paused = true
	cena.sprite_brokk.animacao.frame_changed.connect(congelar)
	cena._mover_para(destino, correr)
	for i in range(2000):
		await process_frame
		if paused:
			break
	await foto(nome)
	cena.sprite_brokk.animacao.frame_changed.disconnect(congelar)
	paused = false
	for i in range(2000):
		await process_frame
		if not cena.movimento_em_andamento:
			break

func _executar() -> void:
	Engine.time_scale = 1.0
	var demo: Control = load("res://BrokkAnimacoes.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	for acao in [&"caminhar", &"correr", &"defesa", &"dano"]:
		demo.executar_acao(acao)
		await create_timer(0.17).timeout
		await foto("brokk_" + String(acao) + "_original")
		demo.executar_acao(&"idle")
	demo.executar_acao(&"morte")
	await demo.grande.morte_finalizada
	await foto("brokk_morte_original")
	_verificar(demo.grande.animacao.frame == 7 and not demo.grande.vivo, "Mostruário conserva pose final")
	demo.queue_free()
	await process_frame
	Engine.time_scale = 5.0
	await _novo_combate(true)
	# Câmera lenta só na captura, para o driver renderizar o meio do trajeto.
	Engine.time_scale = 0.2
	await fotografar_deslocamento(Vector2i(1, 1), false, "brokk_caminhada_combate")
	await fotografar_deslocamento(Vector2i(0, 0), true, "brokk_corrida_combate")
	_verificar(cena.estado_brokk.pa_atuais == 0, "Captura real preserva 2 PA + 3 PA")
	cena.vida_brokk = 0 # Fixture visual de derrota; não altera o jogo.
	cena._sincronizar_sprites()
	await create_timer(0.45).timeout
	await foto("brokk_morte_combate")
	await cena.sprite_brokk.morte_finalizada
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS COMPLEMENTOS: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
