extends "res://tests/teste_arena_interface.gd"

func foto(nome: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	if nome == "arena_ataque_dado":
		_verificar(cena.visual_dado.is_visible_in_tree() and cena.dado_3d.visible, "Dado continua visível no quadro efetivamente capturado")
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura real: " + nome)

func _executar() -> void:
	await _novo_combate(true)
	await _mouse(Vector2(10, 10))
	_medidas()
	await foto("arena_ampliada")
	await _mouse(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Brokk"])))
	await foto("arena_inspecao_brokk")
	await _clique(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Bandido"])))
	await _mouse(Vector2(10, 10))
	await foto("arena_inspecao_bandido")
	cena.inspecao._fechar()
	# Duas pessoas na mesma coluna conferem PV e silhuetas em linhas vizinhas.
	cena.grade.posicoes["Brokk"] = Vector2i(2, 0)
	cena.grade.posicoes["Bandido"] = Vector2i(3, 1)
	cena.grade.posicoes["Porrete"] = Vector2i(3, 2)
	cena._sincronizar_sprites()
	await foto("arena_pv_linhas_vizinhas")
	for tamanho in [Vector2i(1280, 960), Vector2i(864, 648)]:
		root.size = tamanho
		await process_frame
		await process_frame
		await foto("arena_%dx%d" % [tamanho.x, tamanho.y])
	var velocidade_anterior := Engine.time_scale
	Engine.time_scale = 1.0
	cena.estado_brokk.mestre_armas_usado = true
	cena.estado_brokk.pa_atuais = 5
	_aproximar_brokk()
	cena._selecionar_alvo("Bandido")
	cena.gerador.seed = _semente([2])
	cena._ao_atacar()
	for i in range(2000):
		await process_frame
		if cena.dado_3d.visible and cena.vida_bandido == 1:
			break
	_verificar(cena.dado_3d.visible and cena.ultimo_ataque["natural"] == 2 and cena.vida_bandido == 1, "Captura de ataque real mantém dado e dano sincronizados")
	_verificar(cena.visual_dado.is_visible_in_tree() and cena.visual_dado.size.x >= 320 and cena.visual_dado.size.y >= 120, "Viewport do dado realmente visível e dimensionado")
	# Congela o instante do resultado, mantendo somente a renderização 3D ativa.
	var modo_anterior: int = cena.visual_dado.process_mode
	var viewport_dado: SubViewport = cena.visual_dado.get_child(0)
	var atualizacao_anterior := viewport_dado.render_target_update_mode
	cena.visual_dado.process_mode = Node.PROCESS_MODE_ALWAYS
	viewport_dado.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	Engine.time_scale = 0.0 # Timers process_always também precisam congelar.
	paused = true
	await process_frame
	await RenderingServer.frame_post_draw
	var imagem_dado: Image = cena.visual_dado.get_child(0).get_texture().get_image()
	var pixels_visiveis := 0
	for y in range(0, imagem_dado.get_height(), 4):
		for x in range(0, imagem_dado.get_width(), 4):
			if imagem_dado.get_pixel(x, y).a > 0.1:
				pixels_visiveis += 1
	_verificar(pixels_visiveis > 10, "Textura do SubViewport contém o dado renderizado")
	_verificar(imagem_dado.save_png("res://tests/arena_dado_viewport.png") == OK, "Captura adicional do dado 3D, sem pausar seu viewport")
	print("Dado renderizado: ", cena.visual_dado.get_global_rect(), " • pixels amostrados: ", pixels_visiveis)
	await foto("arena_ataque_dado")
	paused = false
	Engine.time_scale = velocidade_anterior
	cena.visual_dado.process_mode = modo_anterior
	viewport_dado.render_target_update_mode = atualizacao_anterior
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	await _fechar_combate()
	await _quarto_participante(false)
	await foto("arena_chefe")
	await _mouse(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Bandido"])))
	await foto("arena_inspecao_tripa")
	await _fechar_combate()
	print("CAPTURAS ARENA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
