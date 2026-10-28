extends "res://tests/teste_atualizacao.gd"

func foto(nome: String) -> void:
	await create_timer(0.14, true, false, true).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura real salva: " + nome)

func _executar() -> void:
	Engine.time_scale = 4
	var c := Sistema.new()
	c.capitulo = 3
	c.iniciar_confronto()
	cena = load("res://Combate.tscn").instantiate()
	cena.inimigos = c.inimigos_atuais
	cena.semente_inicial = _semente_iniciativa()
	root.add_child(cena)
	for i in range(2500):
		await process_frame
		if cena.selecionando_posicao:
			break
	await foto("interface_posicionamento")
	cena._confirmar_posicao(Vector2i(2, 1))
	for i in range(2500):
		await process_frame
		if cena._pode_agir():
			break
	await foto("interface_turno_jogador")
	cena.barra_cartas.cartas["atacar"].pressed.emit()
	await foto("interface_carta_selecionada")
	cena._limpar_selecao()
	cena.estado_brokk.pa_atuais = 1
	cena._atualizar_interface()
	await foto("interface_carta_indisponivel")
	cena.estado_brokk.pa_atuais = 5
	cena._atualizar_interface()
	for i in range(12):
		cena.visual_ui.registrar("Registro %d: rolagem, Defesa e dano preservados; histórico pode ser percorrido pela barra lateral." % (i + 1))
	await foto("interface_registro")
	cena.ordem_turnos.assign(["Brokk", "Bandido"])
	cena.gerador.seed = _semente_dado(6, 1)
	cena._iniciar_turno_inimigo("Bandido")
	for i in range(500):
		await process_frame
		if cena.rolagem_em_andamento:
			break
	await foto("interface_turno_inimigo")
	for i in range(1500):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	await _fechar()
	var demo: Node = load("res://Dados.tscn").instantiate()
	root.add_child(demo)
	await foto("dados_seis_tipos")
	demo.lancar()
	await foto("dados_seis_animados")
	for i in range(1000):
		await process_frame
		if not demo.em_rolagem:
			break
	for dado in demo.dados:
		verificar(Dados3D.resultado_visivel(dado) == dado.get_meta("resultado"), "Mostruário para no valor realmente sorteado")
	demo.queue_free()
	await process_frame
	print("CAPTURAS ATUALIZAÇÃO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
