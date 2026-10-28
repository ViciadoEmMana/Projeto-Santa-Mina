extends "res://tests/teste_campanha.gd"
## Regressão dos dois golpes, sem alterar o custo ou a seleção de Vantagem.
const FeedbackFacas = preload("res://efeitos_combate.gd")
var confirmar_muralha := false


func _process(_delta: float) -> bool:
	if is_instance_valid(cena) and cena.aguardando_decisao:
		cena._responder_habilidade(confirmar_muralha and cena.dialogo_habilidade.title == "Muralha de Ferro")
	return false


func _soma_acertos(dados: Array[int]) -> int:
	var soma := 0
	for dado in dados:
		if dado != 1:
			soma += dado
	return soma


func _modelos_facas() -> void:
	var ficha := Criaturas.criar("goblin_faca")
	verificar(ficha.arma["maos"] == 2 and ficha.arma["dado"] == 4 and ficha.arma["quantidade_dados"] == 2 and ficha.arma["golpes_independentes"], "Equipamento mantém dois d4 e dois golpes")
	verificar(ficha.pa_maximos == 3 and ficha.habilidades["passo_agil"]["ativo"], "Orçamento e Passo Ágil preservados")
	verificar(ficha.pendencias.size() == 1 and ficha.pendencias[0].begins_with("FOR"), "Regra de múltiplos dados deixou de ser pendência")
	for primeiro in range(1, 5):
		for segundo in range(1, 5):
			var dados: Array[int] = [primeiro, segundo]
			var soma := _soma_acertos(dados)
			for equipado in [false, true]:
				for pele in [0, 1]:
					for defender in [0, 2]:
						var escudo := 2 if equipado and (primeiro in [2, 3] or segundo in [2, 3]) else 0
						var fontes := {"escudo": escudo, "natural": pele, "temporaria": defender}
						var ataque := Regras.ataque_golpes(dados, 0, fontes)
						var defesa: int = escudo + pele + defender
						verificar(ataque["erro"] == (soma == 0) and ataque["soma_acertos"] == soma, "Cada 1 erra apenas seu golpe: " + str(dados))
						verificar(ataque["golpes"][0]["erro"] == (primeiro == 1) and ataque["golpes"][1]["erro"] == (segundo == 1), "Naturais e erros independentes")
						verificar(ataque["bruto"] == soma and ataque["dano"] == (maxi(0, soma - defesa) if soma > 0 else 0), "Defesa centralizada aplicada uma vez")
						verificar(ataque["defesa"] == (defesa if soma > 0 else 0), "Não duplica escudo, Pele ou Defender")
						ataque["dados_selecionados"] = dados
						ataque["natural_escudo"] = primeiro if primeiro in [2, 3] else (segundo if segundo in [2, 3] else 0)
						var feedback := FeedbackFacas.planejar(Criaturas.FACAS, ataque)
						verificar(feedback["acerto"] == (soma > 0) and feedback["escudo"] == (escudo > 0 and soma > 0), "Feedback corresponde aos golpes e ao escudo")
	verificar(Regras.ataque_golpes([1, 4], 0, {})["bruto"] == 4, "Exemplo aprovado 1 e 4: só o 4 causa dano")
	verificar(Regras.ataque_golpes([1, 1], 9, {"escudo": 2})["dano"] == 0, "Dois erros não recebem bônus")
	verificar(Regras.ataque_golpes([3, 4], 1, {})["bruto"] == 8, "Bônus existente aplicado uma vez à ação")


func _semente_facas(dados: Array[int]) -> int:
	var rng := RandomNumberGenerator.new()
	for semente in range(100000):
		rng.seed = semente
		var coincide := true
		for dado in dados:
			if rng.randi_range(1, 4) != dado:
				coincide = false
				break
		if coincide:
			return semente
	verificar(false, "Encontrou semente para os d4")
	return 0


func _preparar_facas(dados: Array[int], pv: int = 14, escudo: bool = true, defender: int = 0) -> int:
	cena.estado_brokk.iniciar_combate() # Cenários independentes do talento humano.
	cena.vida_brokk = pv
	cena.ficha_brokk.escudo_equipado = escudo
	cena.estado_brokk.bonus_defesa_temporaria = defender
	cena.estado_brokk.muralha_usada = false
	cena.estado_brokk.pa_debito_pendente = 0
	cena.estado_brokk.pa_debito_registrado = 0
	cena.inimigos["Porrete"].pa_atuais = 3
	cena.turno_atual = "Porrete"
	cena.ordem_turnos.assign(["Brokk", "Porrete"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(3, 1)}
	cena._sincronizar_sprites()
	cena._atualizar_interface()
	cena.efeitos.eventos.clear()
	cena.gerador.seed = _semente_facas(dados)
	var rng := RandomNumberGenerator.new()
	rng.seed = cena.gerador.seed
	for valor in dados:
		rng.randi_range(1, 4)
	return rng.state


func _ataques_reais_facas() -> void:
	var campanha := Sistema.new()
	campanha.capitulo = 2
	await _encontro(campanha)
	for primeiro in range(1, 5):
		for segundo in range(1, 5):
			var dados: Array[int] = [primeiro, segundo]
			var estado_rng := _preparar_facas(dados)
			var soma := _soma_acertos(dados)
			var escudo := 2 if primeiro in [2, 3] or segundo in [2, 3] else 0
			var dano := maxi(0, soma - escudo)
			await cena._executar_ataque_inimigo("Porrete")
			verificar(cena.ultimo_ataque["dados_selecionados"] == dados and cena.ultimo_ataque["soma_acertos"] == soma, "Cena resolve os dois naturais reais: " + str(dados))
			verificar(cena.ultimo_ataque["dano"] == dano and cena.vida_brokk == 14 - dano, "PV correspondem aos golpes válidos e à Defesa")
			verificar(cena.ultimo_ataque["fontes"].get("escudo", 0) == escudo and cena.estado_brokk.bonus_defesa_escudo == escudo, "Escudo no cálculo e na interface, sem acumular")
			verificar(cena.efeitos.eventos.count("escudo") == (1 if escudo > 0 else 0), "Som e efeito de escudo uma única vez")
			verificar(cena.Dados3D.resultado_visivel(cena.dado_bandido_3d) == primeiro and cena.Dados3D.resultado_visivel(cena.encontro.dado_extra) == segundo, "Dados 3D mantêm cada resultado natural")
			verificar(cena.texto_dado.text == "2d4: %d e %d • acertos: %d" % [primeiro, segundo, soma], "Texto distingue resultados naturais da soma dos acertos")
			var mensagens := "\n".join(cena.visual_ui.mensagens)
			verificar(mensagens.contains("Golpe 1: d4 %d (%s)" % [primeiro, "erro" if primeiro == 1 else "acerto"]) and mensagens.contains("Golpe 2: d4 %d (%s)" % [segundo, "erro" if segundo == 1 else "acerto"]), "Registro identifica acerto/erro de cada golpe")
			verificar(cena.gerador.state == estado_rng and cena.inimigos["Porrete"].pa_atuais == 0, "Exatamente dois d4 e um custo de 3 PA")
			verificar(cena.turno_atual == "Brokk" and not cena.visual_dado.visible and not cena.encontro.dado_extra.visible, "Turno avança e dados se escondem")
			verificar(not cena.estado_brokk.muralha_usada, "Recusar reação não consome Muralha")
	# Estados defensivos existentes: Pele inativa, escudo removido e Defender.
	for caso in [{"dados": [2, 3], "pv": 7, "escudo": true, "defender": 0, "dano": 3},
		{"dados": [2, 3], "pv": 14, "escudo": false, "defender": 0, "dano": 5},
		{"dados": [2, 3], "pv": 14, "escudo": true, "defender": 2, "dano": 1}]:
		var dados: Array[int] = []
		dados.assign(caso["dados"])
		_preparar_facas(dados, caso["pv"], caso["escudo"], caso["defender"])
		await cena._executar_ataque_inimigo("Porrete")
		verificar(cena.ultimo_ataque["dano"] == caso["dano"] and cena.vida_brokk == caso["pv"] - caso["dano"], "Integra Pele, equipamento e Defender sem redução dupla")
	# Vantagem/desvantagem continuam escolhendo o conjunto completo pela soma.
	for modo in ["vantagem", "desvantagem"]:
		var estado_rng := _preparar_facas([1, 4, 2, 2])
		cena.inimigos["Porrete"].fontes_vantagem.assign(["teste"] if modo == "vantagem" else [])
		cena.inimigos["Porrete"].fontes_desvantagem.assign(["teste"] if modo == "desvantagem" else [])
		await cena._executar_ataque_inimigo("Porrete")
		var esperado: Array[int] = []
		esperado.assign([1, 4] if modo == "vantagem" else [2, 2])
		verificar(cena.ultimo_ataque["dados_selecionados"] == esperado and cena.ultimo_ataque["modo"] == modo, "Preserva escolha de conjuntos por " + modo)
		verificar(cena.ultimo_ataque["fontes"].get("escudo", 0) == (0 if modo == "vantagem" else 2), "Dados descartados não ativam o escudo")
		verificar(cena.gerador.state == estado_rng, "Modo de rolagem não cria dados extras")
	cena.inimigos["Porrete"].fontes_vantagem.clear()
	cena.inimigos["Porrete"].fontes_desvantagem.clear()
	_preparar_facas([4, 4])
	confirmar_muralha = true
	await cena._executar_ataque_inimigo("Porrete")
	confirmar_muralha = false
	verificar(cena.ultimo_ataque["dano"] == 8 and cena.ultimo_ataque["dano_recebido"] == 4 and cena.vida_brokk == 10, "Muralha reduz dano final combinado de 8 para 4 em Zeno")
	verificar(cena.estado_brokk.muralha_usada and cena.estado_brokk.pa_debito_registrado == 1 and cena.estado_brokk.pa_atuais == 4, "Muralha cobra 1 PA uma vez no próximo turno")
	_preparar_facas([4, 4])
	# Fixture do efeito que normalmente é recebido antes do combate.
	campanha.alimentos.aplicar("costela", campanha.estado_brokk)
	verificar(campanha.alimentos.pv_temporarios() == 3, "Fixture prepara PV temporários")
	await cena._executar_ataque_inimigo("Porrete")
	verificar(cena.ultimo_ataque["absorvido_temporarios"] == 3 and cena.vida_brokk == 9, "PV temporários absorvem após a Defesa")
	# Tentativa inválida não rola, não cobra PA e não altera resultado.
	_preparar_facas([2, 3])
	cena.inimigos["Porrete"].pa_atuais = 2
	var rng_antes: int = cena.gerador.state
	var resultado_antes: Dictionary = cena.ultimo_ataque.duplicate(true)
	await cena._executar_ataque_inimigo("Porrete")
	verificar(cena.gerador.state == rng_antes and cena.inimigos["Porrete"].pa_atuais == 2 and cena.ultimo_ataque == resultado_antes, "Sem PA suficientes não existe ataque gratuito")
	_preparar_facas([4, 4], 2)
	await cena._executar_ataque_inimigo("Porrete")
	verificar(cena.vida_brokk == 0 and cena.finalizacao_emitida and cena.turno_atual == "", "Dano fatal encerra combate normalmente")
	await _fechar()


func _executar() -> void:
	_modelos_facas()
	await _ataques_reais_facas()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO FACA CEGA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
