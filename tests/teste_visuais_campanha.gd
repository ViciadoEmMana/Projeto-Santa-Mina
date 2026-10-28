extends "res://tests/teste_brokk.gd"
const SistemaCampanha = preload("res://sistema_campanha.gd")

func _abrir_capitulo(indice: int) -> void:
	var campanha := SistemaCampanha.new()
	campanha.capitulo = indice
	campanha.iniciar_confronto()
	cena = load("res://Combate.tscn").instantiate()
	cena.inimigos = campanha.inimigos_atuais
	cena.ambiente = campanha.dados_capitulo()["local"]
	cena.semente_inicial = 17
	root.add_child(cena)
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			break
	_verificar(cena.selecionando_posicao, "Capítulo aguarda posicionamento sem perder input")
	# Ordem controlada somente nesta fixture visual; a iniciativa real tem regressões.
	var ordem: Array[String] = ["Brokk"]
	ordem.append_array(cena._inimigos_vivos())
	cena.ordem_turnos.assign(ordem)
	_verificar(cena._confirmar_posicao(Vector2i(2, 1)), "Posição confirmada na grade original")
	for i in range(200):
		await process_frame
		if cena._pode_agir():
			break
	_verificar(cena._pode_agir(), "Brokk pode usar as ações depois da formação")

func _executar() -> void:
	var vistos: Dictionary = {}
	for capitulo in range(4):
		await _abrir_capitulo(capitulo)
		_verificar(cena.cenario.ambiente == cena.ambiente and cena.cenario.position == cena.grade.position, "Cenário correto acompanha a grade sem deslocar cliques")
		_verificar(cena.cenario.z_index == cena.grade.z_index and cena.cenario.get_parent() == cena.grade.get_parent() and cena.cenario.get_index() < cena.grade.get_index(), "Cenário aparece sobre o fundo da cena e atrás da grade na arena")
		_verificar(cena.grade.COLUNAS == 6 and cena.grade.LINHAS == 3 and cena.grade.opacidade_piso < 1, "Grade continua 3×6, com piso visível")
		for camada in [cena.cenario.fundo, cena.cenario.piso]:
			_verificar(camada.texture != null and camada.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Camadas decorativas não capturam input")
		for carta in cena.barra_cartas.cartas.values():
			_verificar(carta.ilustracao.texture != null and carta.custo == Regras.CUSTOS[carta.definicao["id"]], "Ilustração original preserva ação e custo")
		var estado_rng: int = cena.gerador.state
		cena.sonoridade.passo()
		cena.sonoridade.carta()
		cena.sonoridade.rolar()
		_verificar(cena.gerador.state == estado_rng and cena.sonoridade.externo == (capitulo < 2), "Áudio de ambiente não interfere no RNG")
		for id in cena.inimigos:
			var sprite: Sprite2D = cena.encontro.sprites[id]
			var ficha: RefCounted = cena.inimigos[id]
			_verificar(sprite.texture == null and sprite.has_method("definir_vivo"), "Visual original ativo: " + ficha.nome)
			_verificar(sprite == (cena.sprite_bandido if id == "Bandido" else (cena.sprite_porrete if id == "Porrete" else cena.encontro.sprites[id])), "Referência única para " + id)
			if ficha.nome == "Bandido Arqueiro":
				vistos[ficha.nome] = true
				continue # Arqueiro aprovado conserva seu atlas e teste específicos.
			var quadros: SpriteFrames = sprite.animacao.sprite_frames
			var contagens := {&"idle": 4, &"caminhar": 4, &"ataque": 8 if ficha.nome == "Bandido do Porrete" else 4, &"dano": 4, &"morte": 8}
			if quadros.has_animation(&"reacao"):
				contagens[&"reacao"] = 4
			for animacao in contagens:
				_verificar(quadros.get_frame_count(animacao) == contagens[animacao], "Quadros de " + ficha.nome + ": " + animacao)
				for i in range(contagens[animacao]):
					var atlas: AtlasTexture = quadros.get_frame_texture(animacao, i)
					_verificar(atlas.atlas.resource_path.begins_with("res://assets/enemies/") and not "32" in atlas.atlas.resource_path, "PNG próprio no recurso")
					_verificar(atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0 and atlas.get_size() == Vector2(640, 640), "Atlas íntegro e tela virtual estável")
					_verificar(is_equal_approx(atlas.margin.position.y + atlas.region.size.y, 560), "Pés no mesmo chão durante " + animacao)
			var rng: int = cena.gerador.state
			var pa: int = ficha.pa_atuais
			sprite.iniciar_deslocamento(false, Vector2.RIGHT)
			_verificar(sprite.animacao.flip_h and sprite.em_movimento, "Caminhada vira somente a arte")
			sprite.parar_deslocamento()
			sprite.olhar_para(Vector2.LEFT)
			var impacto_anterior: int = cena.efeitos.resolucoes
			await sprite.animar_golpe_ate_impacto()
			_verificar(sprite.animacao.frame == int(quadros.get_meta("quadro_impacto", 4)), "Evento de golpe usa quadro de contato configurado")
			_verificar(cena.gerador.state == rng and ficha.pa_atuais == pa and cena.efeitos.resolucoes == impacto_anterior, "Apresentação sozinha não rola, cobra ou aplica ataque")
			await sprite.animacao.animation_finished
			_verificar(not sprite.em_ataque and sprite.animacao.animation == &"idle", "Recuperação libera animação")
			sprite.reagir_impacto(false, 1)
			_verificar(sprite.animacao.animation == &"dano", "Dano apresenta reação própria")
			await sprite.animacao.animation_finished
			vistos[ficha.nome] = true
		# Verifica o caminho real de Defesa e reação visual de Sucata nos dois capítulos.
		if capitulo in [1, 3]:
			var alvo := "Porrete" if capitulo == 1 else "Sucata"
			cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(3, 1)}
			if capitulo == 3:
				cena.grade.posicoes["Porrete"] = Vector2i(5, 2)
				cena.grade.posicoes["Sucata"] = Vector2i(3, 1)
			cena._sincronizar_sprites()
			cena._selecionar_alvo(alvo)
			cena.gerador.seed = _semente([4])
			await cena._ao_atacar()
			_verificar(cena.ultimo_ataque["bruto"] == 7 and cena.ultimo_ataque["defesa"] == 2 and cena.inimigos[alvo].pv_atuais == 1, "Sucata: 7 − 2 = 5 nos capítulos II e IV")
			var sucata: Sprite2D = cena.encontro.sprites[alvo]
			cena.estado_brokk.iniciar_turno()
			cena.gerador.seed = _semente([2])
			await cena._ao_atacar()
			_verificar(cena.inimigos[alvo].pv_atuais == 0 and sucata.animacao.frame == 7 and not sucata.animacao.is_playing(), "Morte real mantém quadro final")
			cena._sincronizar_sprites()
			_verificar(sucata.rotation == 0 and sucata.modulate == Color.WHITE and sucata.reproducoes.get(&"morte", 0) == 1, "Sincronizar não colore, gira ou repete morte original")
		if capitulo == 3:
			await _reacoes_reais_chefe()
		await _fechar_combate()
	_verificar(vistos.size() == 7, "Os sete inimigos têm apresentação original distinta")
	var fonte_cena := FileAccess.get_file_as_string("res://Combate.tscn")
	_verificar(not fonte_cena.contains("32 rogues"), "Combate não carrega mais a textura legada")
	for nome in ["passo_pedra", "passo_terra", "carta", "dados", "vento_caverna", "vento_floresta"]:
		var wav: AudioStreamWAV = load("res://audio/ambiente/" + nome + ".wav")
		_verificar(wav != null and wav.get_length() > 0.1 and not wav.stereo, "WAV próprio válido: " + nome)
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO VISUAIS CAMPANHA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)

func _reacoes_reais_chefe() -> void:
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(3, 1), "Porrete": Vector2i(4, 1), "Sucata": Vector2i(4, 2)}
	cena._sincronizar_sprites()
	cena._selecionar_alvo("Bandido")
	var posicoes: Dictionary = cena.grade.posicoes.duplicate()
	var chefe: Sprite2D = cena.encontro.sprites["Bandido"]
	var copia := RandomNumberGenerator.new()
	var semente_sucesso := -1
	for semente in range(100000):
		copia.seed = semente
		var d20 := copia.randi_range(1, 20)
		if d20 + cena.ficha_brokk.atributo_efetivo("SAB") >= 12 and copia.randi_range(1, 6) == 4:
			semente_sucesso = semente
			break
	_verificar(semente_sucesso >= 0, "Fixture reproduz resistência bem-sucedida e ataque 4")
	cena.estado_brokk.iniciar_turno()
	cena.gerador.seed = semente_sucesso
	copia.seed = semente_sucesso
	copia.randi_range(1, 20)
	copia.randi_range(1, 6)
	await cena._ao_atacar()
	_verificar(cena.inimigos["Bandido"].pv_atuais == 13 and cena.inimigos["Porrete"].pv_atuais == 1, "Me Protejam visual transfere 5, sem recalcular Defesa")
	_verificar(cena.estado_brokk.pa_atuais == 2 and cena.gerador.state == copia.state, "Duas reações visuais não cobram PA nem sorteiam dados extras")
	_verificar(chefe.reproducoes.get(&"reacao", 0) == 2 and cena.inimigos["Bandido"].golpe_sujo_usado, "Golpe Sujo e Me Protejam apresentam os dois gestos")
	_verificar(cena.efeitos.eventos.count("reacao:golpe_sujo") == 1 and cena.efeitos.eventos.count("reacao:me_protejam") == 1, "Efeitos identificam a reação sem duplicar resolução")
	_verificar(cena.grade.posicoes == posicoes, "Reação não move chefe ou protetor")
	cena.estado_brokk.iniciar_turno()
	cena.gerador.seed = _semente([4])
	await cena._ao_atacar()
	_verificar(cena.inimigos["Porrete"].pv_atuais == 0 and cena.inimigos["Bandido"].pv_atuais == 13, "Nova transferência pode derrotar protetor")
	_verificar(chefe.reproducoes.get(&"reacao", 0) == 3 and cena.efeitos.eventos.count("reacao:golpe_sujo") == 1, "Só Me Protejam repete; Golpe Sujo continua gasto")
	cena.estado_brokk.iniciar_turno()
	cena.gerador.seed = _semente([4])
	await cena._ao_atacar()
	_verificar(cena.inimigos["Bandido"].pv_atuais == 8 and chefe.reproducoes.get(&"reacao", 0) == 3, "Sem protetor vivo não inventa reação, Defesa ou imunidade")
