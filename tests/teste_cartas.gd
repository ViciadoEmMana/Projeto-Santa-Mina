extends "res://tests/teste_campanha.gd"
## Reutiliza fixtures; executa só os testes novos, não duplica a suíte anterior.
const DefinicoesCartas = preload("res://cartas_basicas.gd")

func clicar(id: String) -> void:
	cena.barra_cartas.cartas[id].pressed.emit()

func escapar() -> void:
	var evento := InputEventKey.new()
	evento.keycode = KEY_ESCAPE
	evento.pressed = true
	cena._unhandled_key_input(evento)

func preparar() -> void:
	await _encontro(Sistema.new())
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(3, 1), "Porrete": Vector2i(5, 2)}
	cena.estado_brokk.mestre_armas_usado = true
	cena._sincronizar_sprites()
	cena._atualizar_interface()

func _componentes() -> void:
	await preparar()
	verificar(cena.barra_cartas.cartas.keys() == ["atacar", "defender", "mover", "correr", "vantagem"], "Cinco cartas, ordem oficial")
	verificar(cena.botao_atacar == cena.barra_cartas.cartas["atacar"] and cena.botao_vantagem == cena.barra_cartas.cartas["vantagem"], "Não há controles duplicados")
	await process_frame
	var essenciais: Array[Rect2] = [cena.apresentacao.retangulo_grade(), cena.visual_dado.get_global_rect(), cena.apresentacao.area_detalhes.get_global_rect()]
	for indicador in cena.inspecao.indicadores.values():
		essenciais.append(indicador.get_global_rect())
	var anterior := Rect2()
	for id in cena.barra_cartas.cartas:
		var carta: Button = cena.barra_cartas.cartas[id]
		verificar(carta.visible and carta.custo == Regras.CUSTOS[id] and carta.text.contains(str(Regras.CUSTOS[id])), "Carta visível com custo central: " + id)
		verificar(carta.icon != null and carta.tooltip_text.contains("PA") and not carta.definicao["descricao"].is_empty(), "Ícone local e descrição: " + id)
		verificar(carta.get_meta("categoria") == "basica_permanente", "Categoria separada: " + id)
		var retangulo := carta.get_global_rect()
		verificar(Rect2(0, 0, 1280, 960).encloses(retangulo) and retangulo.size.y >= 220, "Carta cabe na resolução original: %s %s" % [id, retangulo])
		verificar(retangulo.position.x > anterior.position.x or anterior == Rect2(), "Mão conserva ordem horizontal com leve sobreposição")
		for elemento in essenciais:
			verificar(not retangulo.intersects(elemento), "Carta não cobre tabuleiro, dados, PV ou registro")
		anterior = retangulo
	# Arte substituível; não afeta mecânicas nem definição da carta.
	var imagem := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	imagem.fill(Color.GOLD)
	var arte := ImageTexture.create_from_image(imagem)
	var dados_arte: Dictionary = cena.botao_atacar.definicao.duplicate(true)
	dados_arte["arte"] = arte
	cena.botao_atacar.configurar(dados_arte, Regras.CUSTOS["atacar"])
	verificar(cena.botao_atacar.ilustracao.texture == arte and cena.botao_atacar.custo == 3, "Arte oficial pode substituir ícone sem mudar ação")
	await _fechar()

func _selecao_e_bloqueios() -> void:
	await preparar()
	var rng: int = cena.gerador.state
	for id in ["atacar", "vantagem", "mover", "correr"]:
		clicar(id)
		verificar(cena.estado_brokk.pa_atuais == 5 and cena.barra_cartas.cartas[id].selecionada, "Seleciona sem pagar: " + id)
		verificar(cena.barra_cartas.cartas[id].tooltip_text.contains("SELECIONADA"), "Seleção indicada por texto e cor")
		clicar(id)
		verificar(cena.estado_brokk.pa_atuais == 5 and not cena.barra_cartas.cartas[id].selecionada, "Mesmo clique cancela sem pagar")
		clicar(id)
		escapar()
		verificar(cena.ataque_carta == "" and cena.modo_movimento == "" and cena.grade.destinos.is_empty() and cena.grade.alvos_validos.is_empty(), "Esc limpa seleção e destaques")
	verificar(cena.gerador.state == rng, "Selecionar/cancelar não rola dados")
	clicar("atacar")
	verificar(cena.grade.alvos_validos == ["Bandido"], "Destaca apenas inimigo vivo em alcance")
	await cena._ao_clicar_casa(Vector2i(5, 2))
	verificar(cena.estado_brokk.pa_atuais == 5 and cena.ultimo_ataque.is_empty(), "Alvo fora de alcance não gasta PA")
	clicar("mover")
	verificar(cena.ataque_carta == "" and cena.modo_movimento == "mover", "Troca de carta limpa seleção anterior")
	await cena._ao_clicar_casa(Vector2i(1, 0))
	verificar(cena.estado_brokk.pa_atuais == 5 and cena.grade.posicoes["Brokk"] == Vector2i(2, 1), "Movimento diagonal inválido não gasta PA")
	await cena._ao_clicar_casa(Vector2i(3, 1))
	verificar(cena.estado_brokk.pa_atuais == 5, "Casa ocupada não gasta PA")
	escapar()
	for id in cena.barra_cartas.cartas:
		cena.estado_brokk.pa_atuais = Regras.CUSTOS[id] - 1
		var antes: int = cena.estado_brokk.pa_atuais
		clicar(id)
		verificar(cena.barra_cartas.cartas[id].disabled and cena.barra_cartas.cartas[id].tooltip_text.contains("PA insuficientes"), "Saldo insuficiente explicado: " + id)
		verificar(cena.estado_brokk.pa_atuais == antes and cena.ataque_carta == "" and cena.modo_movimento == "", "Sinal programático não ignora bloqueio")
	cena.estado_brokk.pa_atuais = 5
	cena.turno_atual = "Bandido"
	cena._atualizar_interface()
	for id in cena.barra_cartas.cartas:
		clicar(id)
		verificar(cena.barra_cartas.cartas[id].visible and cena.barra_cartas.cartas[id].disabled and cena.estado_brokk.pa_atuais == 5, "Turno inimigo bloqueia carta sem ocultar")
	cena.turno_atual = "Brokk"
	cena.rolagem_em_andamento = true
	cena._atualizar_interface()
	clicar("defender")
	verificar(cena.estado_brokk.bonus_defesa_temporaria == 0 and cena.estado_brokk.pa_atuais == 5, "Animação bloqueia novas ações")
	cena.rolagem_em_andamento = false
	await _fechar()

func _custos_e_resultados() -> void:
	for id in ["atacar", "defender", "mover", "correr", "vantagem"]:
		await preparar()
		var resolucoes: int = cena.efeitos.resolucoes
		cena.gerador.seed = _semente_dado(6, 2)
		clicar(id)
		if id in ["atacar", "vantagem"]:
			verificar(cena.vida_bandido == 6 and cena.estado_brokk.pa_atuais == 5, "Ataque aguarda confirmação do alvo")
			await cena._ao_clicar_casa(Vector2i(3, 1))
			var natural: int = cena.ultimo_ataque["natural"]
			verificar(cena.efeitos.resolucoes == resolucoes + 1, "Uma confirmação resolve um único ataque com efeitos/sons")
			verificar(cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(natural)), "Dado visual usa resultado real pela carta")
			verificar(cena.ultimo_ataque["dados"].size() == (2 if id == "vantagem" else 1), "Quantidade de dados preservada")
			if id == "vantagem":
				verificar(natural == cena.ultimo_ataque["dados"].max(), "Vantagem usa maior natural")
		elif id in ["mover", "correr"]:
			var destino := Vector2i(2, 0) if id == "mover" else Vector2i(0, 1)
			await cena._ao_clicar_casa(destino)
			verificar(cena.grade.posicoes["Brokk"] == destino, "Destino validado pela lógica antiga")
		else:
			verificar(cena.estado_brokk.bonus_defesa_temporaria == 2, "Defender aplica +2 até próximo turno")
			clicar(id)
			verificar(cena.estado_brokk.pa_atuais == 4, "Duplo clique não compra Defender duas vezes")
		verificar(cena.estado_brokk.pa_atuais == 5 - Regras.CUSTOS[id], "Custo exato pela carta: " + id)
		verificar(cena.barra_cartas.cartas.size() == 5 and cena.barra_cartas.cartas[id].visible, "Carta usada permanece na barra; sem descarte")
		await _fechar()
	await preparar()
	cena.estado_brokk.fontes_desvantagem.append("teste")
	cena._atualizar_interface()
	clicar("vantagem")
	await cena._ao_clicar_casa(Vector2i(3, 1))
	verificar(cena.estado_brokk.pa_atuais == 0 and cena.ultimo_ataque["modo"] == "normal" and cena.ultimo_ataque["dados"].size() == 1, "Vantagem anulada mantém custo 5 PA e um dado")
	await _fechar()
	await preparar()
	cena.grade.obstaculos.assign([Vector2i(1, 1), Vector2i(2, 0), Vector2i(2, 2)])
	cena._atualizar_interface()
	clicar("correr")
	await cena._ao_clicar_casa(Vector2i(0, 1))
	verificar(cena.estado_brokk.pa_atuais == 5 and cena.grade.posicoes["Brokk"] == Vector2i(2, 1), "Corrida não atravessa obstáculos ou personagens")
	await _fechar()

func _semente_erros() -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(100000):
		rng.seed = candidato
		var todos := true
		for i in range(4):
			if rng.randi_range(1, 6) != 1:
				todos = false
		if todos:
			return candidato
	return 0

func _chefe_pelas_cartas() -> void:
	var c := Sistema.new()
	c.capitulo = 3
	await _encontro(c)
	cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(4, 2), "Sucata": Vector2i(5, 0)}
	cena.inimigos["Bandido"].pv_atuais = 3
	cena.estado_brokk.mestre_armas_usado = true
	cena._sincronizar_sprites()
	cena._atualizar_interface()
	cena.gerador.seed = _semente_dado(20, 1)
	clicar("atacar")
	await cena._ao_clicar_casa(Vector2i(4, 1))
	verificar(cena.inimigos["Bandido"].golpe_sujo_usado and cena.ultimo_ataque["erro"] and cena.estado_brokk.pa_atuais == 2, "Carta confirma Golpe Sujo e mantém custo na falha")
	verificar(cena.inimigos["Bandido"].pv_atuais == 3 and cena.inimigos["Porrete"].pv_atuais == 6, "Falha de Golpe Sujo não aciona transferência")
	# Fixture de orçamento para isolar o segundo ataque; a partida abaixo usa turnos reais.
	cena.estado_brokk.pa_atuais = 5
	cena._atualizar_interface()
	cena.gerador.seed = _semente_dado(6, 3)
	clicar("atacar")
	await cena._ao_clicar_casa(Vector2i(4, 1))
	verificar(cena.ultimo_ataque["me_protejam"] and cena.ultimo_ataque["alvo_dano"] == "Porrete" and cena.inimigos["Porrete"].pv_atuais == 2 and cena.inimigos["Bandido"].pv_atuais == 3, "Me Protejam! preservado ao confirmar alvo pela carta")
	verificar(cena.estado_brokk.pa_atuais == 2 and cena.barra_cartas.cartas.size() == 5, "Reações não duplicam custo nem consomem carta")
	await _fechar()

func _partida_pelas_cinco_cartas() -> void:
	await _encontro(Sistema.new())
	var usadas: Dictionary = {}
	var erros := _semente_erros()
	for turno in range(30):
		if cena._inimigos_vivos().is_empty() or cena.vida_brokk <= 0:
			break
		for id in ["defender", "mover", "correr"]:
			if usadas.has(id) or cena.barra_cartas.cartas[id].disabled:
				continue
			clicar(id)
			if id != "defender":
				var destinos: Array = cena.grade.destinos.duplicate()
				if not destinos.is_empty():
					await cena._ao_clicar_casa(destinos[0])
			usadas[id] = true
		var acao := "atacar" if not usadas.has("atacar") or usadas.has("vantagem") else "vantagem"
		if cena.barra_cartas.cartas[acao].disabled and cena._alvos_cartas_ataque().is_empty() and not cena.botao_mover.disabled:
			# Menor caminho até uma casa de ataque: usa apenas a carta Mover.
			var melhor: Array[Vector2i] = []
			for y in range(3):
				for x in range(6):
					var casa := Vector2i(x, y)
					for alvo in cena._inimigos_vivos():
						if not Equipamentos.avaliar_alcance(cena.ficha_brokk.EQUIPAMENTOS["arma"], casa, cena.grade.posicoes[alvo], Vector2i(6, 3))["permitido"]:
							continue
						var caminho: Array[Vector2i] = cena.grade.caminho("Brokk", casa, 18)
						if not caminho.is_empty() and (melhor.is_empty() or caminho.size() < melhor.size()):
							melhor = caminho
			if not melhor.is_empty():
				clicar("mover")
				await cena._ao_clicar_casa(melhor[0])
		if not cena.barra_cartas.cartas[acao].disabled:
			var alvo: String = cena._alvos_cartas_ataque()[0]
			cena.gerador.seed = _semente_dado(6, 2)
			clicar(acao)
			await cena._ao_clicar_casa(cena.grade.posicoes[alvo])
			usadas[acao] = true
		if cena._inimigos_vivos().is_empty():
			break
		cena.gerador.seed = erros
		await cena._encerrar_turno()
	verificar(usadas.size() == 5, "Combate real usa as cinco cartas sem conceder PA, curar ou alterar PV")
	verificar(cena._inimigos_vivos().is_empty() and cena.vida_brokk > 0 and cena.finalizacao_emitida, "Combate original vencido por cartas com IA e turnos reais")
	verificar(cena.barra_cartas.cartas.size() == 5, "Nenhuma carta consumida durante partida completa")
	await _fechar()

func _executar() -> void:
	await _componentes()
	await _selecao_e_bloqueios()
	await _custos_e_resultados()
	await _chefe_pelas_cartas()
	await _redesign_visual()
	await _partida_pelas_cinco_cartas()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO CARTAS: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)

func _redesign_visual() -> void:
	var logico_anterior := root.content_scale_size
	await preparar()
	verificar(root.content_scale_size == Vector2i(1280, 960) and root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_KEEP, "Área lógica de combate adapta a mão sem alterar outras cenas")
	var rng: int = cena.gerador.state
	var pa: int = cena.estado_brokk.pa_atuais
	var cores: Array[Color] = []
	for carta in cena.barra_cartas.cartas.values():
		verificar(is_equal_approx(carta.size.x / carta.size.y, 2.0 / 3.0), "Proporção vertical 2:3")
		verificar(carta.ilustracao is TextureRect and carta.ilustracao.size.y >= carta.size.y * 0.4 and carta.ilustracao.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Ilustração grande preserva proporção")
		verificar(carta.custo_texto.position.y < 14 and carta.custo_texto.position.x < 14 and carta.custo_texto.text == str(carta.custo), "Custo no medalhão superior")
		verificar(carta.descricao.text == carta.definicao["efeito"] and carta.rodape.text.contains("BÁSICA"), "Efeito e categoria visíveis na carta")
		verificar(carta.cor not in cores, "Paleta distinta por ação")
		cores.append(carta.cor)
		var origem: Vector2 = carta.posicao_mao
		carta._foco(true)
		await create_timer(0.15, true, false, true).timeout
		await process_frame # O timer pode vencer antes do processamento dos tweens.
		verificar(carta.position.y < origem.y and carta.scale.x > carta.escala_mao and carta.z_index == 20, "Hover sobe, amplia suavemente e passa à frente")
		var retangulo: Rect2 = carta.get_global_rect()
		verificar(retangulo.position.y > cena.apresentacao.retangulo_grade().end.y and retangulo.end.y <= 960, "Hover não cobre tabuleiro ampliado ou sai da área de combate")
		carta._foco(false)
		await create_timer(0.15, true, false, true).timeout
		await process_frame
		verificar(carta.position.is_equal_approx(carta.posicao_mao) and is_equal_approx(carta.scale.x, carta.escala_mao), "Saída de hover retorna sem acumular deslocamento")
	clicar("atacar")
	await create_timer(0.15, true, false, true).timeout
	await process_frame
	verificar(cena.botao_atacar.position.y < cena.botao_atacar.posicao_mao.y and cena.botao_atacar.selecionada, "Seleção mantém carta elevada")
	escapar()
	await create_timer(0.15, true, false, true).timeout
	await process_frame
	verificar(cena.botao_atacar.position.is_equal_approx(cena.botao_atacar.posicao_mao), "Esc restaura apresentação")
	verificar(cena.gerador.state == rng and cena.estado_brokk.pa_atuais == pa, "Animações não consomem PA nem RNG de combate")
	cena.estado_brokk.pa_atuais = 0
	cena._atualizar_interface()
	verificar(cena.botao_atacar.modulate.r < 1 and cena.botao_atacar.custo_texto.visible and cena.botao_atacar.rodape.text.contains("INDISPONÍVEL"), "Bloqueio escurece carta preservando custo e indicação")
	await _fechar()
	verificar(root.content_scale_size == logico_anterior, "Sair do combate restaura resolução lógica anterior")
