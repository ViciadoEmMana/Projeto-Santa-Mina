extends "res://tests/teste_zeno.gd"
## Renderização nativa e eventos pela entrada real do Viewport.

func _mouse_zeno(ponto: Vector2) -> void:
	var evento := InputEventMouseMotion.new()
	evento.position = ponto
	evento.global_position = ponto
	root.push_input(evento, true)
	await process_frame
	await process_frame

func _clique_zeno(ponto: Vector2) -> void:
	await _mouse_zeno(ponto)
	for pressionado in [true, false]:
		var evento := InputEventMouseButton.new()
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.pressed = pressionado
		evento.position = ponto
		evento.global_position = ponto
		root.push_input(evento, true)
		await process_frame
	await process_frame

func _foto_zeno(nome: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura nativa: " + nome)

func _executar() -> void:
	root.gui_embed_subwindows = true
	cena = load("res://Combate.tscn").instantiate()
	cena.semente_inicial = _semente_iniciativa()
	root.add_child(cena)
	for quadro in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			break
	await _clique_zeno(cena.grade.to_global(cena.grade.centro(Vector2i(2, 1))))
	verificar(cena.posicionamento_concluido and cena._pode_agir(), "Mouse confirma posição após iniciativa")
	await _foto_zeno("zeno_arena")
	await _mouse_zeno(cena.grade.to_global(cena.grade.centro(Vector2i(2, 1))))
	verificar(cena.inspecao.exibido == "Brokk", "Hover inspeciona Zeno")
	await _foto_zeno("zeno_inspecao")
	await _clique_zeno(cena.botao_ficha.get_global_rect().get_center())
	verificar(cena.dialogo_ficha.visible and cena.texto_ficha.text.begins_with("Zeno • Humano"), "Mouse abre ficha de Zeno")
	await _foto_zeno("zeno_ficha")
	# Fecha o diálogo por seu botão real antes do teste da tecla Esc no tabuleiro.
	await _clique_zeno(Vector2(cena.dialogo_ficha.position) + cena.dialogo_ficha.get_ok_button().get_global_rect().get_center())
	verificar(not cena.dialogo_ficha.visible, "Botão real fecha ficha")
	await _clique_zeno(cena.botao_mover.get_global_rect().get_center())
	verificar(cena.modo_movimento == "mover", "Mouse seleciona carta Mover")
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.pressed = true
	root.push_input(tecla, true)
	await process_frame
	verificar(cena.modo_movimento == "" and cena.estado_brokk.pa_atuais == 5, "Esc cancela sem gastar PA")
	await _clique_zeno(cena.botao_mover.get_global_rect().get_center())
	await _clique_zeno(cena.grade.to_global(cena.grade.centro(Vector2i(2, 0))))
	for quadro in range(500):
		await process_frame
		if not cena.movimento_em_andamento:
			break
	verificar(cena.grade.posicoes["Brokk"] == Vector2i(2, 0) and cena.estado_brokk.pa_atuais == 3, "Mouse move uma casa livre por 2 PA")
	cena.gerador.seed = _semente_zeno([5])
	Engine.time_scale = 1.0
	await _clique_zeno(cena.botao_atacar.get_global_rect().get_center())
	var alvo: Vector2i = cena.grade.posicoes["Porrete"]
	await _clique_zeno(cena.grade.to_global(cena.grade.centro(alvo)))
	for quadro in range(2000):
		await process_frame
		if cena.inimigos["Porrete"].pv_atuais == 0:
			break
	verificar(cena.ultimo_ataque["natural"] == 5 and cena.ultimo_ataque["dano"] == 9 and cena.estado_brokk.bonus_veterano_dano == 1, "Ataque pelo mouse usa 5 + FOR 3 + Veterano 1")
	verificar(cena.Dados3D.resultado_visivel(cena.dado_3d) == 5 and cena.dado_3d.visible, "Dado real para em 5")
	var viewport: SubViewport = cena.visual_dado.get_child(0)
	var modo: int = cena.visual_dado.process_mode
	cena.visual_dado.process_mode = Node.PROCESS_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	Engine.time_scale = 0.0
	paused = true
	await _foto_zeno("zeno_ataque_veterano")
	verificar(viewport.get_texture().get_image().save_png("res://tests/zeno_dado.png") == OK, "Textura nativa do d6")
	paused = false
	Engine.time_scale = 20
	cena.visual_dado.process_mode = modo
	for quadro in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	await _fechar()
	await _encontro(Sistema.new())
	_caso_zeno([3])
	cena.inimigos["Bandido"].pv_maximos = 6
	cena.inimigos["Bandido"].pv_atuais = 6
	cena.grade.posicoes["Bandido"] = Vector2i(3, 2)
	cena.ordem_turnos.assign(["Brokk", "Bandido"])
	cena._sincronizar_sprites()
	cena._defender()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	await cena._executar_ataque_inimigo("Bandido")
	verificar(cena.estado_brokk.bonus_veterano_defesa == 1, "Veterano defensivo no renderizador nativo")
	await _foto_zeno("zeno_defesa_veterano")
	await _fechar()
	var campanha = load("res://Campanha.tscn").instantiate()
	root.add_child(campanha)
	await process_frame
	verificar(campanha.estatisticas.text.contains("ZENO") and not campanha.narrativa.text.contains("Brokk"), "Campanha identifica Zeno")
	await _foto_zeno("zeno_campanha")
	campanha.queue_free()
	await process_frame
	print("CAPTURAS ZENO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
