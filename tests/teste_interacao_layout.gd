extends "res://tests/teste_brokk.gd"
## Usa a rota real de entrada do Viewport, sem chamar callbacks de clique.

func _clique(ponto: Vector2) -> void:
	var movimento := InputEventMouseMotion.new()
	movimento.position = ponto
	movimento.global_position = ponto
	root.push_input(movimento, true)
	await process_frame
	for pressionado in [true, false]:
		var evento := InputEventMouseButton.new()
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.position = ponto
		evento.global_position = ponto
		evento.pressed = pressionado
		root.push_input(evento, true)
		await process_frame

func _executar() -> void:
	cena = load("res://Combate.tscn").instantiate()
	cena.semente_inicial = _semente_primeiro_turno()
	root.add_child(cena)
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			break
	_verificar(cena.selecionando_posicao, "Iniciativa termina aguardando posição do jogador")
	await process_frame
	await _clique(cena.grade.to_global(cena.grade.centro(Vector2i(2, 1))))
	_verificar(cena.posicionamento_concluido and not cena.selecionando_posicao, "Clique atravessa layout e confirma posição inicial")
	_verificar(cena.grade.posicoes["Brokk"] == Vector2i(2, 1) and cena.turno_atual == "Brokk", "Posição correta e início do turno respeitam iniciativa")
	var carta: Control = cena.barra_cartas.cartas["mover"]
	await _clique(carta.get_global_transform() * (carta.size / 2.0))
	_verificar(cena.modo_movimento == "mover", "Carta recebe clique real após posicionamento")
	var destino := Vector2i(1, 1)
	_verificar(destino in cena.grade.destinos, "Movimento destaca destino válido")
	await _clique(cena.grade.to_global(cena.grade.centro(destino)))
	for i in range(1000):
		await process_frame
		if not cena.movimento_em_andamento:
			break
	_verificar(cena.grade.posicoes["Brokk"] == destino and cena.estado_brokk.pa_atuais == 3, "Clique na grade move e cobra somente 2 PA")
	var botao: Control = cena.botao_encerrar
	await _clique(botao.get_global_transform() * (botao.size / 2.0))
	_verificar(cena.turno_atual != "Brokk", "Encerrar turno recebe clique real")
	# Permite concluir a ação inimiga antes de liberar a cena.
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento and not cena.movimento_em_andamento:
			break
	cena.queue_free()
	await process_frame
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO INTERAÇÃO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
