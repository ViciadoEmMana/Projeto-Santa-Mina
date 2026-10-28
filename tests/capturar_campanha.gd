extends SceneTree
## Capturas reais de telas de apresentação; execute sem --headless.
var tela: Node
var combate: Node

func _initialize() -> void:
	Engine.time_scale = 4
	call_deferred("_capturar")

func _process(_delta: float) -> bool:
	if is_instance_valid(combate) and combate.aguardando_decisao:
		combate._responder_habilidade(false)
	return false

func foto(nome: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var resultado := root.get_texture().get_image().save_png("res://tests/" + nome + ".png")
	print("Captura %s: %d" % [nome, resultado])

func _capturar() -> void:
	tela = load("res://Campanha.tscn").instantiate()
	root.add_child(tela)
	await foto("campanha_inicio")
	# Fixture visual: preparação após capítulo I, Brokk ferido com habilidades gastas.
	tela.campanha.capitulo = 1
	tela.campanha.localizacao = "Acampamento Protegido"
	tela.campanha.estado_brokk.pv_atuais = 4
	tela.campanha.estado_brokk.mestre_armas_usado = true
	tela.campanha.estado_brokk.muralha_usada = true
	tela.atualizar()
	tela._deslocar()
	for indice in range(tela.selecao_comida.item_count):
		if tela.selecao_comida.get_item_metadata(indice) == "costela":
			tela.selecao_comida.select(indice)
	tela.atualizar_botoes()
	await foto("campanha_descanso")
	tela._descansar("longo")
	# Credita as vitórias anteriores pela mesma API; a captura final terá o total
	# de recompensas da campanha, não apenas o loot isolado do chefe.
	for capitulo in [1, 2]:
		tela.campanha.iniciar_confronto()
		for inimigo in tela.campanha.inimigos_atuais.values():
			inimigo.pv_atuais = 0
		tela.campanha.concluir_confronto(true)
		tela.campanha.avancar_capitulo()
	tela.atualizar()
	tela.iniciar_combate()
	combate = tela.combate
	await foto("campanha_iniciativa_chefe")
	for i in range(2000):
		await process_frame
		if combate.selecionando_posicao:
			combate._confirmar_posicao(Vector2i(2, 1))
		if combate._pode_agir():
			break
	await foto("campanha_chefe")
	# Fixture visual de encerramento: usa o mesmo evento de vitória do jogo.
	for inimigo in combate.inimigos.values():
		inimigo.pv_atuais = 0
	combate._verificar_fim_combate()
	await process_frame
	await process_frame
	combate = null
	await foto("campanha_final")
	tela.queue_free()
	await process_frame
	await create_timer(0.1, true, false, true).timeout
	quit()
