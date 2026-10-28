extends "res://tests/teste_salvamento.gd"
## Capturas reais com slot temporário; execute com renderizador.

func foto(nome: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura renderizada: " + nome)

func _executar() -> void:
	var tela = load("res://Campanha.tscn").instantiate()
	tela.salvamento = slot
	root.add_child(tela)
	vencer(tela.campanha)
	tela.campanha.avancar_capitulo()
	tela.campanha.estado_brokk.pv_atuais = 9
	tela.campanha.estado_brokk.mestre_armas_usado = true
	tela.campanha.estado_brokk.muralha_usada = true
	tela.campanha.consumir("cerveja")
	tela.atualizar()
	await process_frame
	await _clique(tela.botao_salvar)
	verificar(slot.existe() and tela.mensagem.text.begins_with("Campanha salva"), "Salvar por clique nativo")
	verificar(not tela.botao_salvar.get_global_rect().intersects(tela.botao_carregar.get_global_rect()), "Botões não se sobrepõem")
	await foto("salvamento_gravado")
	tela.queue_free()
	await process_frame
	tela = load("res://Campanha.tscn").instantiate()
	tela.salvamento = slot
	root.add_child(tela)
	await process_frame
	verificar(not tela.botao_carregar.disabled and tela.campanha.capitulo == 0, "Nova instância oferece carga sem carregar automaticamente")
	await foto("salvamento_reabrir")
	await _clique(tela.botao_carregar)
	verificar(tela.campanha.capitulo == 1 and tela.campanha.estado_brokk.pv_atuais == 9 and tela.campanha.estado_brokk.muralha_usada, "Carga restaura capítulo, PV e uso")
	await foto("salvamento_carregado")
	# Confere os controles no mesmo tamanho lógico das telas anteriores.
	for botao in [tela.botao_salvar, tela.botao_carregar]:
		verificar(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(botao.get_global_rect()), "Persistência dentro da área visível")
	for tamanho in [Vector2i(1280, 720), Vector2i(864, 648)]:
		root.size = tamanho
		await process_frame
		await process_frame
		await _clique(tela.botao_salvar)
		await _clique(tela.botao_carregar)
		verificar(tela.mensagem.text.begins_with("Campanha carregada") and tela.campanha.estado_brokk.pv_atuais == 9, "Cliques continuam corretos na resolução " + str(tamanho))
		for botao in [tela.botao_salvar, tela.botao_carregar]:
			verificar(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(botao.get_global_rect()), "Botões enquadrados em " + str(tamanho))
		await foto("salvamento_%dx%d" % [tamanho.x, tamanho.y])
	tela.queue_free()
	await process_frame
	print("CAPTURAS SALVAMENTO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
