extends "res://tests/teste_faca_cega.gd"
## Captura nativa do resultado; não usa o slot salvo do jogador.

func _executar() -> void:
	var campanha := Sistema.new()
	campanha.capitulo = 2
	await _encontro(campanha)
	for par in [[1, 4], [2, 3]]:
		var dados: Array[int] = []
		dados.assign(par)
		_preparar_facas(dados)
		Engine.time_scale = 1.0
		cena._executar_ataque_inimigo("Porrete")
		for quadro in range(3000):
			await process_frame
			if cena.vida_brokk != 14:
				break
		verificar(cena.visual_dado.is_visible_in_tree() and cena.ultimo_ataque["dados_selecionados"] == dados, "Captura durante resultado real dos dois golpes")
		var modo_anterior: int = cena.visual_dado.process_mode
		var viewport: SubViewport = cena.visual_dado.get_child(0)
		var atualizacao_anterior := viewport.render_target_update_mode
		cena.visual_dado.process_mode = Node.PROCESS_MODE_ALWAYS
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		Engine.time_scale = 0.0
		paused = true
		await process_frame
		await RenderingServer.frame_post_draw
		verificar(cena.Dados3D.resultado_visivel(cena.dado_bandido_3d) == dados[0] and cena.Dados3D.resultado_visivel(cena.encontro.dado_extra) == dados[1], "Faces nativas correspondem aos valores do cálculo")
		var nome := "res://tests/faca_cega_%d_%d" % [dados[0], dados[1]]
		verificar(root.get_texture().get_image().save_png(nome + ".png") == OK, "Captura da interface")
		verificar(viewport.get_texture().get_image().save_png(nome + "_dados.png") == OK, "Captura das faces dos dados")
		paused = false
		Engine.time_scale = 20.0
		cena.visual_dado.process_mode = modo_anterior
		viewport.render_target_update_mode = atualizacao_anterior
		for quadro in range(2000):
			await process_frame
			if not cena.rolagem_em_andamento:
				break
	await _fechar()
	print("CAPTURAS FACA CEGA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
