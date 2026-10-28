extends "res://tests/teste_brokk.gd"
const Visual = preload("res://scripts/presentation/brokk_visual.gd")

func _executar() -> void:
	var quadros: SpriteFrames = Visual.QUADROS
	_verificar(quadros.get_frame_count("idle") == 8 and quadros.get_animation_loop("idle"), "Idle com oito quadros em loop")
	_verificar(quadros.get_frame_count("ataque") == 8 and not quadros.get_animation_loop("ataque"), "Ataque de oito quadros sem repetição")
	for nome in [&"idle", &"ataque"]:
		for i in range(8):
			var atlas: AtlasTexture = quadros.get_frame_texture(nome, i)
			_verificar(atlas.atlas.resource_path.begins_with("res://assets/characters/brokk/"), "Quadro usa somente a arte original de Brokk")
			_verificar(atlas.get_size() == Vector2(384, 384), "Tela virtual constante evita alteração de escala")
			_verificar(atlas.region.size.x <= 314 and atlas.region.size.y <= 308 and atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0, "Corpo e arma cabem na tela, sem recorte por célula uniforme")
	await _novo_combate()
	var sprite: Sprite2D = cena.sprite_brokk
	_verificar(sprite.get_script() == Visual and sprite.texture == null, "Nó preservado usa controlador próprio, sem textura legada")
	_verificar(sprite.scale == Vector2.ONE and sprite.animacao.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Escala da raiz e filtro explícitos")
	var estado_rng: int = cena.gerador.state
	var quadro_inicial: int = sprite.animacao.frame
	await create_timer(0.2).timeout
	_verificar(sprite.animacao.animation == &"idle" and sprite.animacao.frame != quadro_inicial, "Idle avança durante o turno")
	_verificar(cena.gerador.state == estado_rng and cena.estado_brokk.pa_atuais == 5, "Idle não altera RNG nem PA")
	_aproximar_brokk()
	var posicao: Vector2 = sprite.position
	cena.gerador.seed = _semente([2])
	var copia_rng := RandomNumberGenerator.new()
	copia_rng.state = cena.gerador.state
	copia_rng.randi_range(1, 6)
	await cena._ao_atacar()
	_verificar(sprite.ataques_apresentados == 1, "Ataque real apresenta exatamente uma animação")
	_verificar(cena.ultimo_ataque["natural"] == 2 and cena.vida_bandido == 1 and cena.estado_brokk.pa_atuais == 2, "Animação preserva natural, dano e custo")
	_verificar(cena.gerador.state == copia_rng.state, "Animação não faz rolagem adicional")
	_verificar(sprite.animacao.animation == &"idle" and not sprite.em_ataque, "Recuperação retorna ao idle")
	_verificar(sprite.position == posicao and sprite.offset == Vector2.ZERO, "Apresentação não muda posição ou offset da grade")
	_verificar(is_zero_approx(cena.escudo_visual.modulate.a) and cena.escudo_visual.visible, "Âncora do escudo preservada sem duplicação gráfica")
	cena.vida_brokk = 0
	cena._sincronizar_sprites()
	_verificar(sprite.visible and sprite.morte_em_andamento and sprite.animacao.animation == &"morte", "Derrota começa animação própria sem restaurar PV")
	await create_timer(0.9).timeout
	_verificar(not sprite.visible and not sprite.animacao.is_playing(), "Fim da morte oculta Brokk como no fluxo anterior")
	await _fechar_combate()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO BROKK VISUAL: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
