extends SceneTree
const Sistema = preload("res://sistema_campanha.gd")
const Criaturas = preload("res://catalogo_criaturas.gd")
const Comidas = preload("res://catalogo_consumiveis.gd")
const Alimentos = preload("res://efeitos_alimentares.gd")
const Rolagem = preload("res://rolagem_arma.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const Regras = preload("res://regras_combate.gd")

var verificacoes := 0
var falhas := 0
var cena: Variant
var escolher_des := false

func _initialize() -> void:
	Engine.time_scale = 20
	call_deferred("_executar")

func _process(_delta: float) -> bool:
	if is_instance_valid(cena) and cena.aguardando_decisao:
		cena._responder_habilidade(escolher_des if cena.dialogo_habilidade.title.begins_with("Golpe Sujo") else false)
	return false

func verificar(condicao: bool, texto: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error("FALHOU CAMPANHA: " + texto)

func vencer(c: RefCounted) -> void:
	for inimigo in c.inimigos_atuais.values():
		inimigo.pv_atuais = 0
	verificar(c.concluir_confronto(true), "Vitória aceita após derrotar todos")

func _catalogos() -> void:
	var esperados := {"goblin_porrete": [6, 0, 1, 1, 3, 6], "goblin_sucata": [6, 2, 2, 0, 3, 4], "goblin_tiro": [5, 0, 0, 2, 3, 6], "goblin_faca": [6, 0, 0, 2, 3, 4], "tripa_seca": [13, 2, 2, 2, 4, 6]}
	for id in esperados:
		var estado: RefCounted = Criaturas.criar(id)
		var esperado: Array = esperados[id]
		for i in range(6):
			verificar([estado.pv_atuais, estado.defesa, estado.forca, estado.destreza, estado.pa_maximos, estado.arma["dado"]][i] == esperado[i], "%s campo %d" % [id, i])
		estado.iniciar_turno()
		verificar(estado.pa_atuais == estado.pa_maximos and estado.tipo == "Humanoide", "PA e tipo da criatura")
		verificar(estado.nivel == (4 if id == "tripa_seca" else 2), "Nível da ficha")
	for id in ["bandido_arqueiro", "bandido_porrete"]:
		verificar(Criaturas.criar(id).pa_maximos == 3, "Bandidos comuns têm 3 PA")
	verificar(not Equipamentos.tenta_derrubar(Criaturas.CLAVA, 6, {"FOR": 9}), "Clava não herda proeza da Maça/Porrete")
	verificar(Criaturas.criar("goblin_sucata").defesa == 2, "Tampa não soma Defesa extra")
	verificar(Criaturas.criar("goblin_tiro").bonus_ataque == -1, "Arco Podre usa dano d6-1 exato")
	for id in Criaturas.criar("tripa_seca").habilidades:
		verificar(Criaturas.criar("tripa_seca").habilidades[id]["ativo"] == (id in ["golpe_sujo", "me_protejam"]), "Apenas habilidades definidas são ativadas: " + id)
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	for modo in ["normal", "vantagem", "desvantagem"]:
		for j in range(20):
			var dados := Rolagem.sortear(Criaturas.FACAS, modo, rng)
			verificar(dados["selecionados"].size() == 2 and dados["total"] >= 2 and dados["total"] <= 8, "Ataque 2d4 preserva dois dados e soma")
			verificar(dados["total"] == Regras.selecionar_natural(dados["totais"], modo), "Vantagem/desvantagem compara conjuntos completos")
	print("Campanha/etapa 1: catálogo, PA próprios, habilidades e dados conferidos.")

func _progressao() -> void:
	var c := Sistema.new()
	verificar(c.estado_brokk.pv_atuais == 14 and c.estado_brokk.pa_maximos == 5 and c.capitulo == 0, "Campanha inicia com Brokk correto")
	c.estado_brokk.pv_atuais = 4
	c.estado_brokk.mestre_armas_usado = true
	c.estado_brokk.muralha_usada = true
	for capitulo in range(4):
		verificar(c.capitulo == capitulo and c.iniciar_confronto(), "Capítulos na ordem e início permitido")
		verificar(c.inimigos_atuais.size() == (3 if capitulo == 3 else 2), "Quantidade de inimigos do capítulo")
		var ids: Array[String] = []
		for inimigo in c.inimigos_atuais.values():
			ids.append(inimigo.ficha_id)
		verificar(ids == c.dados_capitulo()["inimigos"], "Fichas corretas carregadas")
		verificar(not c.concluir_confronto(true) and not c.conceder_recompensas(), "Não avança ou recompensa com inimigos vivos")
		verificar(not c.consumir("cafe"), "Não consome mantimentos no combate")
		vencer(c)
		var moedas: int = c.inventario.coroas
		verificar(not c.concluir_confronto(true) and not c.conceder_recompensas() and c.inventario.coroas == moedas, "Vitória/drops repetidos são bloqueados")
		verificar(c.estado_brokk.pv_atuais == 4 and c.estado_brokk.mestre_armas_usado and c.estado_brokk.muralha_usada, "PV e habilidades não se recuperam entre capítulos")
		if capitulo < 3:
			verificar(c.avancar_capitulo(), "Transição válida")
			verificar(c.localizacao == ["Acampamento Protegido", "Entrada da Caverna", "Interior da Dungeon"][capitulo], "Localização de preparação correta")
	verificar(c.fase == "final" and c.inventario.coroas == 19, "Final da campanha e 19 coroas oficiais")
	for nome in ["Espada de Ferro", "Arco Curto", "Escudo de Madeira e Ferro", "Facas Cegas", "Arco Desgastado"]:
		verificar(c.inventario.equipamentos[nome] == 1, "Drop correto: " + nome)
	verificar(c.inventario.equipamentos["Porrete Desgastado"] == 2 and c.inventario.equipamentos["Tampa de Ferro"] == 2, "Drops dos capangas repetidos em encontros distintos")
	verificar(c.inventario.especiais["Porção Comum"] == 1 and c.ficha_brokk.EQUIPAMENTOS["arma"]["nome"] == "Espada de Ferro", "Recompensa especial não altera a Espada inicial de Zeno")
	c.reiniciar()
	verificar(c.capitulo == 0 and c.estado_brokk.pv_atuais == 14 and c.inventario.coroas == 0 and c.recompensas_recebidas.is_empty(), "Reiniciar limpa progresso, recompensas e estado")
	c.iniciar_confronto()
	c.estado_brokk.pv_atuais = 0
	verificar(c.concluir_confronto(false) and c.fase == "derrota" and not c.avancar_capitulo() and not c.iniciar_confronto(), "Derrota interrompe campanha")
	print("Campanha/etapa 2: progressão, persistência, derrota e recompensas conferidas.")

func _mantimentos_e_descansos() -> void:
	for id in Comidas.ITENS:
		var c := Sistema.new()
		c.estado_brokk.pv_atuais = 4
		c.estado_brokk.mestre_armas_usado = true
		c.estado_brokk.muralha_usada = true
		verificar(not c.descansar("curto", id, "mestre_armas_usado")["ok"], "Descanso requer fim de turno")
		c.concluir_deslocamento()
		var antes: int = c.inventario.mantimentos[id]
		verificar(c.descansar("curto", id, "mestre_armas_usado")["ok"], "Qualquer comida/bebida paga descanso curto")
		verificar(c.inventario.mantimentos[id] == antes - 1 and not c.estado_brokk.mestre_armas_usado and c.estado_brokk.muralha_usada, "Consome uma unidade e recupera exatamente habilidade escolhida")
		verificar(c.estado_brokk.pv_atuais == (5 if id == "caldo_ovo" else 4), "Curto não cura diretamente; somente Caldo +1 PV")
		verificar(not c.fim_turno_exploracao, "Descanso consome a oportunidade do fim de turno")
		var longo := Sistema.new()
		longo.localizacao = "Acampamento Protegido"
		longo.estado_brokk.pv_atuais = 4
		longo.estado_brokk.mestre_armas_usado = true
		longo.estado_brokk.muralha_usada = true
		longo.concluir_deslocamento()
		verificar(longo.descansar("longo", id)["ok"] and longo.estado_brokk.pv_atuais == 14, "Qualquer mantimento paga longo e cura 10 até limite normal")
		verificar(not longo.estado_brokk.mestre_armas_usado and not longo.estado_brokk.muralha_usada, "Longo recupera todas as habilidades")
	var c := Sistema.new()
	c.localizacao = "Interior da Dungeon"
	c.concluir_deslocamento()
	verificar(not c.descansar("longo", "costela")["ok"] and c.inventario.mantimentos["costela"] == 1, "Masmorra bloqueia longo antes de consumir comida")
	verificar(not c.descansar("curto", "costela", "mestre_armas_usado")["ok"], "Curto sem habilidade gasta não é permitido")
	c.localizacao = "Acampamento Protegido"
	c.estado_brokk.pv_atuais = 4
	verificar(c.descansar("longo", "costela")["ok"] and c.alimentos.pv_temporarios() == 3, "Costela adiciona 3 temporários além do descanso")
	verificar(c.alimentos.absorver(5) == 2 and c.alimentos.pv_temporarios() == 0, "PV temporários absorvem dano sem alterar PV máximos")
	c.inventario.adicionar_comida("costela")
	c.consumir("costela")
	c.inventario.adicionar_comida("costela")
	c.consumir("costela")
	verificar(c.alimentos.pv_temporarios() == 3 and c.alimentos.ativos["costela"]["restantes"] == 3, "Mesmo alimento renova sem acumular bônus")
	c.consumir("cerveja")
	c.consumir("doce")
	verificar(c.ficha_brokk.atributo_efetivo("FOR") == 4 and c.ficha_brokk.atributo_efetivo("DES") == 2, "Atributos alimentares temporários separados da ficha base")
	c.alimentos.avancar("exploracao")
	verificar(c.alimentos.ativos["costela"]["restantes"] == 3, "Relógios de exploração e combate desacoplados por padrão")
	c.alimentos.avancar("combate")
	c.alimentos.atualizar_ficha(c.ficha_brokk)
	verificar(c.ficha_brokk.atributo_efetivo("DES") == 1 and c.ficha_brokk.atributo("FOR") == 3, "Doce expira após uma rodada sem mudar atributo permanente")
	c.alimentos.avancar("combate")
	c.alimentos.avancar("combate")
	c.alimentos.atualizar_ficha(c.ficha_brokk)
	verificar(not c.alimentos.ativos.has("costela") and c.ficha_brokk.atributo_efetivo("FOR") == 3, "Efeitos de três rodadas expiram")
	verificar(not c.inventario.adicionar_comida("inexistente") and not c.inventario.adicionar_comida("cafe", -2) and not c.inventario.adicionar_coroas(-1), "Inventário rejeita itens inválidos e quantidades negativas")
	c.consumir("galinhada")
	verificar(not c.alimentos.ativos.has("galinhada"), "Galinhada não ganha efeito inventado")
	print("Campanha/etapa 3: alimentos, relógios, inventário e descansos conferidos.")

func _encontro(c: RefCounted) -> void:
	verificar(c.iniciar_confronto(), "Prepara confronto real")
	cena = load("res://Combate.tscn").instantiate()
	cena.semente_inicial = _semente_iniciativa()
	cena.inimigos = c.inimigos_atuais
	cena.estado_brokk = c.estado_brokk
	cena.ficha_brokk = c.ficha_brokk
	cena.alimentos = c.alimentos
	root.add_child(cena)
	var pronto := false
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			cena._confirmar_posicao(Vector2i(2, 1))
		if cena._pode_agir():
			pronto = true
			break
	verificar(pronto, "Iniciativa e posicionamento funcionam na campanha")

func _fechar() -> void:
	cena.queue_free()
	await process_frame
	cena = null

func _encontros_reais() -> void:
	for capitulo in range(4):
		var c := Sistema.new()
		c.capitulo = capitulo
		await _encontro(c)
		verificar(cena.inimigos.size() == (3 if capitulo == 3 else 2) and cena.iniciativas.size() == cena.inimigos.size() + 1, "Todos entram em iniciativa real")
		for id in cena.inimigos:
			verificar(cena.encontro.sprites.has(id) and cena.encontro.vidas[id].text.contains("/%d" % cena.inimigos[id].pv_maximos), "Sprite e PV do inimigo existem")
			verificar(cena.visual_ui.pa_barras[id].max_value == cena.inimigos[id].pa_maximos, "Interface usa máximo individual")
		await process_frame
		for id in cena.visual_ui.paineis:
			verificar(not cena.visual_ui.paineis[id].is_visible_in_tree() and cena.inspecao.indicadores.has(id), "Ficha oculta e PV sobre a cabeça para cada participante")
		if capitulo == 2:
			cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(4, 1)}
			cena.turno_atual = "Porrete"
			cena.numero_rodada = 10
			cena.inimigos["Porrete"].pa_atuais = 3
			await cena._mover_inimigo("Porrete")
			verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 1) and cena.inimigos["Porrete"].pa_atuais == 3, "Passo Ágil aproxima uma casa sem gastar PA")
			verificar(cena.inimigos["Porrete"].passo_agil_rodada == 10, "Uso registrado nesta rodada")
			cena.grade.posicoes["Brokk"] = Vector2i(0, 1)
			var origem: Vector2i = cena.grade.posicoes["Porrete"]
			cena.inimigos["Porrete"].pa_atuais = 0
			await cena._mover_inimigo("Porrete")
			verificar(cena.grade.posicoes["Porrete"] == origem, "Sem segundo passo gratuito na mesma rodada")
			cena.numero_rodada = 11
			await cena._mover_inimigo("Porrete")
			verificar(cena.grade.posicoes["Porrete"] != origem and cena.inimigos["Porrete"].pa_atuais == 0, "Nova rodada renova Passo Ágil sem conceder PA ou ataque")
			cena.grade.posicoes["Porrete"] = Vector2i(3, 1)
			cena.grade.obstaculos.assign([Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2), Vector2i(4, 1)])
			cena.numero_rodada = 12
			await cena._mover_inimigo("Porrete")
			verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 1) and cena.inimigos["Porrete"].passo_agil_rodada == 11, "Obstáculos bloqueiam movimento gratuito sem consumir uso")
			cena.grade.obstaculos.clear()
			cena.grade.posicoes["Brokk"] = Vector2i(2, 1)
			cena.inimigos["Porrete"].pa_atuais = 3
			cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
			await cena._executar_ataque_inimigo("Porrete")
			verificar(cena.ultimo_ataque["dados_selecionados"].size() == 2 and cena.ultimo_ataque["natural"] == 0 and cena.texto_dado.text.contains("2d4"), "2d4 real, um ataque e descrição sem natural único inventado")
			var d: Array = cena.ultimo_ataque["dados_selecionados"]
			verificar(cena.Dados3D.resultado_visivel(cena.dado_bandido_3d) == d[0] and cena.Dados3D.resultado_visivel(cena.encontro.dado_extra) == d[1], "Dois cubos param mostrando exatamente os d4 usados")
			verificar(cena.inimigos["Porrete"].pa_atuais == 0, "2d4 custa um único ataque de 3 PA")
		if capitulo == 3:
			verificar(cena.inimigos["Bandido"].nome == "Tripa Seca" and cena.inimigos["Bandido"].pa_maximos == 4 and cena.encontro.dados.size() == 4, "Chefe com 4 PA e quatro iniciativas visuais")
			for id in cena.encontro.dados:
				var dado: Node3D = cena.encontro.dados[id]
				var raio: float = 0.98 * dado.scale.x
				verificar(absf(dado.position.x) + raio < 2.65 * cena.visual_dado.size.x / cena.visual_dado.size.y / 2.0, "Dado de iniciativa do chefe/capanga gira dentro do viewport")
				verificar(cena.Dados3D.resultado_visivel(dado) == cena.iniciativas[id]["natural"], "Quatro dados mostram os naturais efetivos de cada participante")
			cena.inimigos["Bandido"].pv_atuais = 0
			verificar(not cena._verificar_fim_combate(), "Matar chefe não encerra enquanto capangas vivem")
		for inimigo in cena.inimigos.values():
			inimigo.pv_atuais = 0
		verificar(cena._verificar_fim_combate(), "Vitória exige todos os inimigos derrotados")
		await _fechar()
	print("Campanha/etapa 4: quatro confrontos reais, UI, IA, Passo Ágil e dados conferidos.")

func _fluxo_interface() -> void:
	var tela = load("res://Campanha.tscn").instantiate()
	root.add_child(tela)
	tela.campanha.consumir("cafe")
	tela.campanha.consumir("rabada")
	tela.campanha.consumir("cuscuz")
	tela.iniciar_combate(_semente_iniciativa())
	cena = tela.combate
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			cena._confirmar_posicao(Vector2i(2, 1))
		if cena._pode_agir():
			break
	verificar(cena.iniciativas["Brokk"]["alimento"] == 1, "Café aplicado na iniciativa real")
	verificar(cena._passos_brokk(false) == 2 and cena._passos_brokk(true) == 3, "Cuscuz integra as distâncias sem alterar custos")
	verificar(cena._bonus_alimentar("dano_armas") == 1, "Rabada disponível no ataque real")
	cena.grade.posicoes["Brokk"] = Vector2i(3, 0)
	cena._sincronizar_sprites()
	cena.estado_brokk.mestre_armas_usado = true
	# Busca um 2 natural para testar bônus sem derrotar o arqueiro antes da transição.
	var rng := RandomNumberGenerator.new()
	for seed_atual in range(100):
		rng.seed = seed_atual
		if rng.randi_range(1, 6) == 2:
			cena.gerador.seed = seed_atual
			break
	await cena._ao_atacar()
	verificar(cena.ultimo_ataque["natural"] == 2 and cena.ultimo_ataque["bruto"] == 6 and cena.ultimo_ataque["bonus_alimento"] == 1, "Rabada acrescenta exatamente +1, sem bônus de Machado no 2")
	cena.vida_brokk = 4
	cena.estado_brokk.muralha_usada = true
	for inimigo in cena.inimigos.values():
		inimigo.pv_atuais = 0
	cena._verificar_fim_combate()
	for i in range(3):
		await process_frame
	cena = null
	verificar(tela.campanha.fase == "vitoria" and tela.tela.visible and tela.campanha.estado_brokk.pv_atuais == 4, "Sinal real retorna à narrativa e preserva PV")
	tela._continuar()
	verificar(tela.campanha.localizacao == "Acampamento Protegido" and tela.campanha.estado_brokk.mestre_armas_usado and tela.campanha.estado_brokk.muralha_usada, "Transição da interface preserva usos até descanso")
	tela._deslocar()
	for indice in range(tela.selecao_comida.item_count):
		if tela.selecao_comida.get_item_metadata(indice) == "costela":
			tela.selecao_comida.select(indice)
	tela._descansar("longo")
	verificar(tela.campanha.estado_brokk.pv_atuais == 14 and tela.campanha.alimentos.pv_temporarios() == 3 and not tela.campanha.estado_brokk.muralha_usada, "Descanso Longo funcional pela interface, cura e PV temporários")
	for capitulo in range(1, 4):
		tela.iniciar_combate(_semente_iniciativa())
		cena = tela.combate
		verificar(cena.estado_brokk == tela.campanha.estado_brokk and cena.estado_brokk.pa_atuais == 0, "Combate reutiliza estado e aguarda turno para distribuir PA")
		for i in range(2000):
			await process_frame
			if cena.selecionando_posicao:
				cena._confirmar_posicao(Vector2i(2, 1))
			if cena._pode_agir():
				break
		# Asserções de integração usam uma vitória controlada; as rolagens/IA
		# são exercitadas separadamente pelos testes de encontro e regressão.
		verificar(cena._pode_agir(), "Confronto da interface chega ao turno do jogador")
		for inimigo in cena.inimigos.values():
			inimigo.pv_atuais = 0
		cena._verificar_fim_combate()
		for i in range(3):
			await process_frame
		cena = null
		if capitulo < 3:
			tela._continuar()
			verificar(tela.campanha.fase == "exploracao" and tela.campanha.estado_brokk.pv_atuais <= 14, "Próximo capítulo não restaura PV automaticamente")
	verificar(tela.campanha.fase == "final" and tela.campanha.inventario.coroas == 19 and tela.narrativa.text.contains("RECOMPENSAS"), "Quatro capítulos completos pela interface exibem vitória final e recompensas")
	var pv: int = tela.campanha.estado_brokk.pv_atuais
	tela.iniciar_original()
	cena = tela.combate
	verificar(cena.alimentos == null and cena.inimigos["Bandido"].nome == "Bandido Arqueiro" and cena.estado_brokk != tela.campanha.estado_brokk, "Acesso ao combate original usa estados independentes")
	# Fecha a cena sem esperar uma iniciativa pendente para evitar corrotinas órfãs.
	for i in range(2000):
		await process_frame
		if cena.selecionando_posicao:
			break
	cena.queue_free()
	await process_frame
	tela.combate = null
	cena = null
	verificar(tela.campanha.estado_brokk.pv_atuais == pv and tela.campanha.inventario.coroas == 19, "Teste do original não contamina campanha")
	tela.queue_free()
	await process_frame
	print("Campanha/UI: narrativa, confronto, alimento, descanso, transições e original independentes conferidos.")


func _campanha_jogada() -> void:
	# Partida determinística: usa os comandos reais, sem zerar PV dos inimigos.
	# Somente as sementes são fixadas, como nos testes anteriores de ataque.
	var rng := RandomNumberGenerator.new()
	var acerto := 0
	var erros := 0
	for candidato in range(100000):
		rng.seed = candidato
		if rng.randi_range(1, 6) == 6:
			acerto = candidato
			break
	for candidato in range(100000):
		rng.seed = candidato
		var todos := true
		for j in range(4):
			if rng.randi_range(1, 6) != 1:
				todos = false
		if todos:
			erros = candidato
			break
	var tela = load("res://Campanha.tscn").instantiate()
	root.add_child(tela)
	tela.campanha.consumir("pao_queijo")
	for capitulo in range(4):
		if capitulo == 1:
			tela.campanha.concluir_deslocamento()
			verificar(tela.campanha.descansar("longo", "costela")["ok"], "Partida: longo válido no Acampamento após capítulo I")
		if capitulo == 2:
			tela.campanha.consumir("caldo_ovo")
		if capitulo == 3:
			for id in ["cerveja", "rabada", "cafe", "salada", "cuscuz"]:
				tela.campanha.consumir(id)
		tela.iniciar_combate(_semente_iniciativa())
		cena = tela.combate
		for i in range(2000):
			await process_frame
			if cena.selecionando_posicao:
				cena._confirmar_posicao(Vector2i(2, 1))
			if cena._pode_agir():
				break
		var turnos := 0
		while is_instance_valid(cena) and cena.vida_brokk > 0 and not cena._inimigos_vivos().is_empty() and turnos < 40:
			turnos += 1
			var em_alcance := ""
			for id in cena._inimigos_vivos():
				if Equipamentos.avaliar_alcance(cena.ficha_brokk.EQUIPAMENTOS["arma"], cena.grade.posicoes["Brokk"], cena.grade.posicoes[id], Vector2i(6, 3))["permitido"]:
					em_alcance = id
					break
			if em_alcance == "":
				var destino := Vector2i(-1, -1)
				var melhor := 999
				for casa in cena.grade.casas_movimento("Brokk", cena._passos_brokk(false)):
					for id in cena._inimigos_vivos():
						var distancia: int = absi(casa.x - cena.grade.posicoes[id].x) + absi(casa.y - cena.grade.posicoes[id].y)
						if distancia < melhor:
							melhor = distancia
							destino = casa
				if destino.x >= 0:
					await cena._mover_para(destino)
				for id in cena._inimigos_vivos():
					if Equipamentos.avaliar_alcance(cena.ficha_brokk.EQUIPAMENTOS["arma"], cena.grade.posicoes["Brokk"], cena.grade.posicoes[id], Vector2i(6, 3))["permitido"]:
						em_alcance = id
						break
			if em_alcance != "" and cena.estado_brokk.pa_atuais >= 3:
				cena._selecionar_alvo(em_alcance)
				cena.gerador.seed = acerto
				await cena._ao_atacar()
			if not is_instance_valid(cena) or cena._inimigos_vivos().is_empty():
				break
			if cena.estado_brokk.pa_atuais >= 1:
				cena._defender()
			cena.gerador.seed = erros
			await cena._encerrar_turno()
		verificar(is_instance_valid(cena) and cena.vida_brokk > 0 and cena._inimigos_vivos().is_empty(), "Capítulo %d vencido por movimento e dano reais" % (capitulo + 1))
		for j in range(3):
			await process_frame
		cena = null
		if tela.campanha.fase not in ["vitoria", "final"]:
			break
		if capitulo < 3:
			tela._continuar()
	verificar(tela.campanha.fase == "final" and tela.campanha.inventario.coroas == 19, "Minicampanha inteira jogável até o final com as ações existentes")
	tela.queue_free()
	await process_frame
	print("Partida determinística: quatro vitórias por ataques reais, movimento, PA e transições.")


func _semente_iniciativa() -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(10000):
		rng.seed = candidato
		var valores: Array[int] = []
		for j in range(4):
			valores.append(rng.randi_range(1, 20))
		if valores[0] + 1 > maxi(valores[1], maxi(valores[2], valores[3])) + 2 and absi(valores[1] - valores[2]) > 2 and absi(valores[1] - valores[3]) > 2 and absi(valores[2] - valores[3]) > 2:
			return candidato
	verificar(false, "Semente de iniciativa reproduzível")
	return 0


func _semente_dado(faces: int, natural: int) -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(10000):
		rng.seed = candidato
		if rng.randi_range(1, faces) == natural:
			return candidato
	return -1


func _ia_e_defesa() -> void:
	var c := Sistema.new()
	await _encontro(c)
	cena.ordem_turnos.assign(["Brokk", "Bandido"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(3, 1), "Porrete": Vector2i(5, 2)}
	await cena._iniciar_turno_inimigo("Bandido")
	verificar(cena.grade.posicoes["Bandido"] == Vector2i(3, 1) and cena.pa_bandido == 0, "Arqueiro ataca adjacente com 3 PA sem recuar")
	verificar(cena.ultimo_ataque["atacante"] == "Bandido" and cena.ultimo_ataque["modo"] == "desvantagem", "Arco preserva Desvantagem ortogonal")
	cena.ordem_turnos.assign(["Brokk", "Porrete"])
	cena.grade.posicoes["Porrete"] = Vector2i(3, 2)
	await cena._iniciar_turno_inimigo("Porrete")
	verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 2) and cena.inimigos["Porrete"].pa_atuais == 0 and cena.ultimo_ataque["atacante"] == "Porrete", "Corpo a corpo ataca diagonal sem movimento")
	cena.turno_atual = "Porrete"
	cena.grade.posicoes = {"Brokk": Vector2i(0, 0), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(5, 2)}
	cena.grade.obstaculos.assign([Vector2i(4, 2), Vector2i(3, 1)])
	var caminho: Array = cena._caminho_para_ataque("Porrete")
	verificar(not caminho.is_empty() and caminho[0] == Vector2i(5, 1), "Busca contorna obstáculo para casa real de ataque")
	for casa in caminho:
		verificar(casa not in cena.grade.obstaculos and not cena.grade.ocupada(casa, "Porrete"), "Plano não atravessa personagens ou obstáculos")
	var tamanho_anterior := caminho.size()
	cena.inimigos["Porrete"].pa_atuais = 3
	await cena._mover_inimigo("Porrete")
	verificar(cena._caminho_para_ataque("Porrete").size() == tamanho_anterior - 2 and cena.inimigos["Porrete"].pa_atuais == 0, "Corrida reduz caminho real em duas casas por 3 PA")
	var origem: Vector2i = cena.grade.posicoes["Porrete"]
	await cena._mover_inimigo("Porrete")
	verificar(cena.grade.posicoes["Porrete"] == origem, "Sem PA não repete movimento nem volta à origem")
	verificar(not cena._pode_atacar_inimigo("inexistente"), "IA rejeita identificador inválido")
	cena.grade.obstaculos.clear()
	cena.grade.posicoes["Brokk"] = Vector2i(0, 0)
	cena.grade.posicoes["Porrete"] = Vector2i(1, 1)
	cena.inimigos["Porrete"].pa_atuais = 3
	verificar(cena._pode_atacar_inimigo("Porrete"), "Ataque diagonal válido")
	cena.inimigos["Porrete"].pv_atuais = 0
	verificar(not cena._pode_atacar_inimigo("Porrete"), "Morto não ataca")
	cena.inimigos["Porrete"].pv_atuais = 8
	cena.vida_brokk = 0
	verificar(not cena._pode_atacar_inimigo("Porrete"), "Não ataca alvo morto")
	await _fechar()
	# Sucata ocupa slots distintos nos capítulos II e IV: testar dano real nos dois.
	for capitulo in [1, 3]:
		c = Sistema.new()
		c.capitulo = capitulo
		await _encontro(c)
		var alvo := "Porrete" if capitulo == 1 else "Sucata"
		cena.grade.posicoes["Brokk"] = Vector2i(2, 1)
		cena.grade.posicoes[alvo] = Vector2i(3, 1)
		cena.alvo_selecionado = alvo
		cena.estado_brokk.mestre_armas_usado = true
		for natural in range(1, 7):
			cena.alvo_selecionado = alvo
			cena.inimigos[alvo].pv_atuais = 6
			cena.estado_brokk.pa_atuais = 5
			cena.gerador.seed = _semente_dado(6, natural)
			await cena._ao_atacar()
			var dano := 0 if natural == 1 else natural + 3 + (1 if natural >= 5 else 0) - 2
			verificar(cena.ultimo_ataque["dano"] == dano and cena.inimigos[alvo].pv_atuais == maxi(0, 6 - dano), "Sucata: dano real reduz Defesa 2 uma vez, capítulo %d, natural %d" % [capitulo + 1, natural])
			verificar(cena.ultimo_ataque["natural"] == natural and cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(natural)), "Dado visual coincide com cálculo contra Sucata")
			if natural != 1:
				verificar(cena.ultimo_ataque["defesa"] == 2 and cena.ultimo_ataque["fontes"]["base"] == 2, "Sucata usa cálculo centralizado sem duplicar tampa")
		cena.inimigos[alvo].pv_atuais = 6
		cena._atualizar_interface()
		verificar(cena.visual_ui.condicoes[alvo].text.contains("Defesa 2"), "Defesa real visível no cartão")
		await _fechar()
	c = Sistema.new()
	c.capitulo = 2
	await _encontro(c)
	cena.ordem_turnos.assign(["Brokk", "Porrete"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(4, 1)}
	await cena._iniciar_turno_inimigo("Porrete")
	verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 1) and cena.inimigos["Porrete"].pa_atuais == 0 and cena.ultimo_ataque["atacante"] == "Porrete", "Faca usa passo grátis e paga ataque 3 PA no turno real")
	cena.inimigos["Porrete"].passo_agil_rodada = -1
	var origem_faca: Vector2i = cena.grade.posicoes["Porrete"]
	await cena._iniciar_turno_inimigo("Porrete")
	verificar(cena.grade.posicoes["Porrete"] == origem_faca and cena.inimigos["Porrete"].passo_agil_rodada == -1 and cena.inimigos["Porrete"].pa_atuais == 0, "Faca adjacente ataca sem desperdiçar passo gratuito")
	await _fechar()
	verificar(Regras.ataque_fisico(4, 3, {"base": 2})["dano"] == 5, "Exemplo oficial: bruto 7 menos Defesa 2 igual a 5")
	print("IA ofensiva e Defesa Sucata: decisões reais, custos, caminhos, dados e dois capítulos conferidos.")


func _golpe_sujo() -> void:
	for atributo in ["DES", "SAB"]:
		for natural in [1, 10, 11, 20]:
			var c := Sistema.new()
			c.capitulo = 3
			await _encontro(c)
			cena.grade.posicoes["Brokk"] = Vector2i(3, 1)
			cena.grade.posicoes["Bandido"] = Vector2i(4, 1)
			cena.alvo_selecionado = "Bandido"
			cena.estado_brokk.mestre_armas_usado = true
			var chefe: RefCounted = cena.inimigos["Bandido"]
			escolher_des = atributo == "DES"
			cena.estado_brokk.pa_atuais = 2
			await cena._ao_atacar()
			verificar(not chefe.golpe_sujo_usado and cena.estado_brokk.pa_atuais == 2, "PA insuficientes não disparam Golpe Sujo")
			cena.estado_brokk.pa_atuais = 5
			cena.grade.posicoes["Brokk"] = Vector2i(0, 0)
			await cena._ao_atacar()
			verificar(not chefe.golpe_sujo_usado and cena.estado_brokk.pa_atuais == 5, "Ataque fora de alcance não dispara reação")
			verificar(not chefe.pode_usar_golpe_sujo(Equipamentos.ARCO_CURTO), "Reação não dispara contra arma à distância")
			cena.grade.posicoes["Brokk"] = Vector2i(3, 1)
			var pa_chefe: int = chefe.pa_atuais
			cena.gerador.seed = _semente_dado(20, natural)
			await cena._ao_atacar()
			var teste: Dictionary = cena.ultimo_ataque["golpe_sujo"]
			var bonus: int = cena.ficha_brokk.atributo_efetivo(atributo)
			verificar(teste["natural"] == natural and teste["atributo"] == atributo and teste["bonus"] == bonus and teste["total"] == natural + bonus, "Teste usa atributo escolhido e natural real")
			verificar(teste["sucesso"] == (natural + bonus >= 12) and chefe.golpe_sujo_usado, "CD 12 inclusiva, uso consumido mesmo no sucesso")
			verificar(cena.estado_brokk.pa_atuais == 2 and chefe.pa_atuais == pa_chefe, "Reação gratuita para chefe; ataque custa 3 PA")
			for numero in cena.numeros_iniciativa_brokk:
				verificar(int(numero.text) >= 1 and int(numero.text) <= 20 and cena.Dados3D.resultado_visivel(cena.dado_iniciativa_brokk) == natural, "Visual d20 mostra natural do teste")
			if not teste["sucesso"]:
				verificar(chefe.pv_atuais == 13 and cena.ultimo_ataque["dano"] == 0 and cena.ultimo_ataque["erro"], "Falha impede dano e rolagem de ataque")
			else:
				verificar(cena.ultimo_ataque["dados"].size() == 1, "Sucesso permite dado normal de ataque")
			verificar(not chefe.pode_usar_golpe_sujo(cena.ficha_brokk.EQUIPAMENTOS["arma"]), "Não pode repetir reação nesta batalha")
			chefe.iniciar_turno()
			verificar(chefe.golpe_sujo_usado, "Início de turno não recupera reação")
			cena.estado_brokk.pa_atuais = 5
			cena.gerador.seed = _semente_dado(6, 2)
			await cena._ao_atacar()
			verificar(cena.ultimo_ataque["golpe_sujo"].is_empty() and cena.ultimo_ataque["natural"] == 2, "Segundo ataque não repete teste defensivo")
			await _fechar()
	var c := Sistema.new()
	c.capitulo = 3
	await _encontro(c)
	cena.alvo_selecionado = "Bandido"
	cena.grade.posicoes["Brokk"] = Vector2i(3, 1)
	cena.grade.posicoes["Bandido"] = Vector2i(4, 1)
	cena.gerador.seed = _semente_dado(20, 1)
	await cena._atacar_com_vantagem()
	verificar(cena.estado_brokk.pa_atuais == 0 and cena.ultimo_ataque["erro"] and cena.inimigos["Bandido"].pv_atuais == 13, "Falha mantém custo completo de 5 PA da Vantagem")
	verificar(not cena.estado_brokk.mestre_armas_usado, "Não gasta Mestre em erro automático sem rolagem")
	await _fechar()
	escolher_des = false
	print("Golpe Sujo: escolha, CD, falha/sucesso, invalidez, uso e custos conferidos.")


func _me_protejam() -> void:
	var c := Sistema.new()
	c.capitulo = 3
	await _encontro(c)
	var chefe: RefCounted = cena.inimigos["Bandido"]
	cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(4, 2), "Sucata": Vector2i(5, 0)}
	for pv in range(1, 14):
		chefe.pv_atuais = pv
		for dano in range(0, 15):
			var esperado := "Porrete" if dano > 0 and (dano >= 5 or dano >= pv) else ""
			verificar(cena._protetor_me_protejam("Bandido", dano) == esperado, "Gatilho usa dano final 5+ OU fatal; empate de PV é estável")
	verificar(cena._protetor_me_protejam("Porrete", 20) == "" and cena._protetor_me_protejam("inexistente", 20) == "", "Somente chefe com habilidade transfere dano")
	chefe.pv_atuais = 13
	cena.inimigos["Porrete"].pv_atuais = 2
	verificar(cena._protetor_me_protejam("Bandido", 5) == "Sucata", "Prefere maior PV atual")
	cena.inimigos["Sucata"].pv_atuais = 0
	verificar(cena._protetor_me_protejam("Bandido", 5) == "Porrete", "Não escolhe goblin morto")
	cena.grade.posicoes["Porrete"] = Vector2i(0, 0)
	verificar(cena._protetor_me_protejam("Bandido", 5) == "", "Goblin distante não protege")
	cena.grade.posicoes["Porrete"] = Vector2i(5, 2)
	verificar(cena._protetor_me_protejam("Bandido", 5) == "Porrete", "Alcance inclui diagonal")
	cena.inimigos["Porrete"].ficha_id = "bandido_porrete"
	verificar(cena._protetor_me_protejam("Bandido", 5) == "", "Aliado não goblin não serve de escudo")
	await _fechar()
	# Casos de aplicação: natural, PV chefe, PV Porrete, PV Sucata, distante, destinatário.
	for caso in [[4, 13, 6, 6, false, "Porrete"], [4, 13, 1, 6, false, "Sucata"], [3, 13, 6, 6, false, "Bandido"], [3, 3, 6, 6, false, "Porrete"], [6, 13, 0, 6, false, "Sucata"], [6, 13, 0, 0, false, "Bandido"], [6, 8, 6, 6, true, "Bandido"]]:
		c = Sistema.new()
		c.capitulo = 3
		await _encontro(c)
		chefe = cena.inimigos["Bandido"]
		chefe.golpe_sujo_usado = true
		chefe.pv_atuais = caso[1]
		cena.inimigos["Porrete"].pv_atuais = caso[2]
		cena.inimigos["Sucata"].pv_atuais = caso[3]
		cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(0, 0) if caso[4] else Vector2i(4, 2), "Sucata": Vector2i(0, 2) if caso[4] else Vector2i(5, 0)}
		cena._sincronizar_sprites()
		var posicoes: Dictionary = cena.grade.posicoes.duplicate()
		cena.alvo_selecionado = "Bandido"
		cena.estado_brokk.mestre_armas_usado = true
		var pa_chefe: int = chefe.pa_atuais
		cena.gerador.seed = _semente_dado(6, caso[0])
		await cena._ao_atacar()
		var dano: int = caso[0] + 3 + (1 if caso[0] >= 5 else 0) - 2
		var destino: String = caso[5]
		verificar(cena.ultimo_ataque["alvo_dano"] == destino and cena.ultimo_ataque["me_protejam"] == (destino != "Bandido"), "Transferência escolhe exatamente um destinatário elegível")
		verificar(cena.ultimo_ataque["defesa"] == 2 and cena.ultimo_ataque["dano"] == dano, "Dano mantém Defesa do chefe; não recalcula Defesa Sucata")
		var antes := {"Bandido": caso[1], "Porrete": caso[2], "Sucata": caso[3]}
		for id in antes:
			verificar(cena.inimigos[id].pv_atuais == maxi(0, int(antes[id]) - (dano if id == destino else 0)), "PV só do destinatário são alterados: " + id)
		verificar(cena.grade.posicoes == posicoes and chefe.pa_atuais == pa_chefe and cena.estado_brokk.pa_atuais == 2, "Não move ninguém nem cobra PA da reação")
		if destino != "Bandido":
			verificar("TRIPA SECA: ME PROTEJAM, SEUS INÚTEIS!" in cena.visual_ui.mensagens and cena.ultimo_ataque["dano_alvo_original"] == 0, "Mensagem oficial e chefe recebe zero")
			if cena.inimigos[destino].pv_atuais == 0:
				verificar(destino in cena.grade.derrotados, "Goblin morto libera casa normalmente")
		await _fechar()
	# Uso repetível em ataques diferentes, sem reset ou cura de goblins.
	c = Sistema.new()
	c.capitulo = 3
	await _encontro(c)
	cena.inimigos["Bandido"].golpe_sujo_usado = true
	cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(4, 2), "Sucata": Vector2i(5, 0)}
	cena.alvo_selecionado = "Bandido"
	cena.estado_brokk.mestre_armas_usado = true
	for destino in ["Porrete", "Sucata"]:
		cena.estado_brokk.pa_atuais = 5 # Fixture: próximo ataque, orçamento explicitamente fornecido.
		cena.gerador.seed = _semente_dado(6, 4)
		await cena._ao_atacar()
		verificar(cena.ultimo_ataque["alvo_dano"] == destino and cena.inimigos["Bandido"].pv_atuais == 13, "Reação repetível escolhe goblin com mais PV a cada ataque")
	verificar(cena.inimigos["Porrete"].pv_atuais == 1 and cena.inimigos["Sucata"].pv_atuais == 1, "Cada ataque transfere só uma vez; sem Defesa adicional")
	await _fechar()
	print("Me Protejam!: limiares, fatalidade, aliados, empate, transferência, mortes e repetição conferidos.")


func _executar() -> void:
	_catalogos()
	_progressao()
	_mantimentos_e_descansos()
	await _encontros_reais()
	await _ia_e_defesa()
	await _golpe_sujo()
	await _me_protejam()
	await _fluxo_interface()
	await _campanha_jogada()
	var tela = load("res://Campanha.tscn").instantiate()
	root.add_child(tela)
	await process_frame
	verificar(tela.titulo.text.contains("CARREGAMENTO") and tela.selecao_comida.item_count == 14, "Tela inicial carrega narrativa e mantimentos")
	tela.queue_free()
	await process_frame
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO CAMPANHA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
