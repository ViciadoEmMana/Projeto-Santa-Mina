extends SceneTree
## Captura opcional com renderização real (sem --headless):
## Godot --path . --script res://tests/capturar_interface.gd

var cena: Node


func _initialize() -> void:
	Engine.time_scale = 4.0
	call_deferred("_capturar")


func _process(_delta: float) -> bool:
	if is_instance_valid(cena) and cena.aguardando_decisao:
		cena._responder_habilidade(false)
	return false


func _capturar() -> void:
	cena = load("res://Combate.tscn").instantiate()
	root.add_child(cena)
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			cena._confirmar_posicao(Vector2i(2, 1))
		if cena._pode_agir():
			break
	if not cena._pode_agir():
		push_error("Não foi possível preparar a captura.")
		quit(1)
		return
	await cena._mover_para(Vector2i(3, 1))
	cena._selecionar_alvo("Bandido")
	await process_frame
	await RenderingServer.frame_post_draw
	var imagem := root.get_texture().get_image()
	var resultado := imagem.save_png("res://tests/interface_combate.png")
	print("Captura da interface: ", resultado)
	cena.queue_free()
	await process_frame
	await create_timer(0.1, true, false, true).timeout
	quit(resultado)
