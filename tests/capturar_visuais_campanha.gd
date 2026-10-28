extends "res://tests/teste_visuais_campanha.gd"
## Capturas de cenas renderizadas, sem montar imagens fora do Godot.

func foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	_verificar(root.get_texture().get_image().save_png("res://tests/" + nome + ".png") == OK, "Captura: " + nome)

func _esperar_ataque() -> void:
	for i in range(2000):
		await process_frame
		if not cena.rolagem_em_andamento:
			return
	_verificar(false, "Ataque deve terminar durante a captura")

func _executar() -> void:
	Engine.time_scale = 1
	var galeria: Control = load("res://InimigosAnimacoes.tscn").instantiate()
	root.add_child(galeria)
	await process_frame
	await foto("elenco_original_idle")
	galeria.executar_acao(&"ataque")
	await create_timer(0.30).timeout
	paused = true
	await foto("elenco_original_ataques")
	paused = false
	await create_timer(0.6).timeout
	galeria.executar_acao(&"caminhar")
	await create_timer(0.18).timeout
	paused = true
	await foto("elenco_original_caminhada")
	paused = false
	galeria.executar_acao(&"dano")
	await create_timer(0.10).timeout
	paused = true
	await foto("elenco_original_dano")
	paused = false
	await create_timer(0.5).timeout
	galeria.executar_acao(&"morte")
	await create_timer(1.0).timeout
	await foto("elenco_original_morte")
	galeria.queue_free()
	await process_frame
	for capitulo in range(4):
		Engine.time_scale = 5
		await _abrir_capitulo(capitulo)
		await foto("cenario_capitulo_%d" % (capitulo + 1))
		if capitulo == 3:
			Engine.time_scale = 0.6
			cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(3, 1), "Porrete": Vector2i(4, 1), "Sucata": Vector2i(4, 2)}
			cena._sincronizar_sprites()
			cena._selecionar_alvo("Bandido")
			cena.gerador.seed = _semente([1])
			cena._ao_atacar()
			await cena.efeitos.reacao_apresentada
			_verificar(cena.encontro.sprites["Bandido"].animacao.animation == &"reacao" and cena.encontro.sprites["Bandido"].animacao.frame == 2, "Areia começa no quadro do gesto")
			await create_timer(0.05).timeout
			paused = true
			await foto("chefe_golpe_sujo_original")
			paused = false
			Engine.time_scale = 5
			await _esperar_ataque()
			cena.estado_brokk.iniciar_turno()
			cena.gerador.seed = _semente([4])
			Engine.time_scale = 0.6
			cena._ao_atacar()
			await cena.efeitos.reacao_apresentada
			_verificar(cena.encontro.sprites["Bandido"].animacao.animation == &"reacao" and cena.encontro.sprites["Bandido"].animacao.frame == 2, "Protetor é destacado no quadro do gesto")
			paused = true
			await foto("chefe_me_protejam_original")
			paused = false
			Engine.time_scale = 5
			await _esperar_ataque()
			await foto("chefe_transferencia_resolvida")
		await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS VISUAIS CAMPANHA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
