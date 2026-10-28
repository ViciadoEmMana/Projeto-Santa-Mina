extends "res://tests/teste_cartas.gd"
## Execute sem --headless para capturas reais; não modifica regras ou recursos.

func foto(nome: String) -> void:
	await create_timer(0.16, true, false, true).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	var resultado := root.get_texture().get_image().save_png("res://tests/" + nome + ".png")
	verificar(resultado == OK, "Captura salva: " + nome)

func _executar() -> void:
	Engine.time_scale = 4
	await preparar()
	await foto("cartas_basicas")
	cena.botao_mover._foco(true)
	await foto("cartas_foco")
	cena.botao_mover._foco(false)
	clicar("atacar")
	await foto("cartas_ataque_selecionado")
	cena._ao_clicar_casa(Vector2i(3, 1))
	await foto("cartas_dados_3d")
	for i in range(1500):
		await process_frame
		if not cena.rolagem_em_andamento:
			break
	cena.estado_brokk.pa_atuais = 5
	cena._atualizar_interface()
	escapar()
	clicar("correr")
	await foto("cartas_corrida_selecionada")
	escapar()
	cena.estado_brokk.pa_atuais = 1
	cena._atualizar_interface()
	await foto("cartas_pa_insuficientes")
	var tamanho_anterior := root.size
	root.size = Vector2i(800, 600)
	await foto("cartas_compactas")
	root.size = tamanho_anterior
	await _fechar()
	# Uma partida com ações pelas cartas e inimigos executando seus turnos.
	await _partida_pelas_cinco_cartas()
	await create_timer(0.1, true, false, true).timeout
	print("CAPTURAS CARTAS: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
