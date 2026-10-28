extends SceneTree
const Sistema = preload("res://sistema_campanha.gd")
const Save = preload("res://salvamento_campanha.gd")

var verificacoes := 0
var falhas := 0
var pasta: String
var slot: RefCounted

func _initialize() -> void:
	Engine.time_scale = 20
	# Fixtures isoladas: nunca toca no slot real do jogador.
	pasta = OS.get_environment("TEMP").path_join("santa_mina_save_%d" % OS.get_process_id())
	DirAccess.make_dir_recursive_absolute(pasta)
	slot = Save.new(pasta.path_join("campanha.json"))
	call_deferred("_executar")

func verificar(condicao: bool, texto: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error("FALHOU SAVE: " + texto)

func documento(c: RefCounted) -> Dictionary:
	var d := Save.criar_documento(c)
	d.erase("salvo_em")
	return d

func escrever(caminho: String, texto: String) -> void:
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	verificar(arquivo != null, "Fixture pode gravar seu próprio arquivo temporário")
	if arquivo != null:
		arquivo.store_string(texto)
		arquivo.close()

func vencer(c: RefCounted) -> void:
	verificar(c.iniciar_confronto(), "Confronto inicia no capítulo a salvar")
	for inimigo in c.inimigos_atuais.values():
		inimigo.pv_atuais = 0
	verificar(c.concluir_confronto(true), "Vitória registra recompensas uma vez")

func ida_e_volta(c: RefCounted, nome: String) -> RefCounted:
	var antes := documento(c)
	var resultado: Dictionary = slot.salvar(c)
	verificar(resultado["ok"], nome + ": gravação real no disco")
	resultado = slot.carregar()
	verificar(resultado["ok"], nome + ": leitura real do disco")
	if not resultado["ok"]:
		return c
	var restaurada: RefCounted = resultado["campanha"]
	verificar(not resultado["backup"], nome + ": slot principal carregado")
	verificar(documento(restaurada) == antes, nome + ": todos os dados persistidos")
	verificar(documento(c) == antes, nome + ": original preservado")
	verificar(restaurada != c and restaurada.inventario != c.inventario and restaurada.estado_brokk != c.estado_brokk, nome + ": instâncias independentes")
	verificar(restaurada.estado_brokk.pv_maximos == 14 and restaurada.estado_brokk.pa_maximos == 5, nome + ": limites oficiais")
	for estoque in [restaurada.inventario.mantimentos, restaurada.inventario.equipamentos, restaurada.inventario.especiais]:
		for quantidade in estoque.values():
			verificar(quantidade is int, nome + ": quantidades inteiras")
	return restaurada

func _progressao() -> void:
	verificar(not slot.existe(), "Nenhum slot inventado ao iniciar")
	verificar(not slot.carregar()["ok"], "Arquivo ausente retorna erro legível")
	var c := Sistema.new()
	c = ida_e_volta(c, "Nova campanha")
	for capitulo in range(4):
		c.estado_brokk.pv_atuais = 8 + capitulo
		c.estado_brokk.mestre_armas_usado = true
		c.estado_brokk.muralha_usada = true
		c.estado_brokk.pa_debito_pendente = 1
		c.estado_brokk.pa_debito_registrado = capitulo
		c.estado_brokk.pa_penalidade_pendente = 1
		c.estado_brokk.condicoes.derrubado = true
		c.estado_brokk.condicoes.penalidade_pendente = 1
		c.estado_brokk.fontes_vantagem.assign(["fonte persistida"])
		c.estado_brokk.fontes_desvantagem.assign(["fonte oposta"])
		c.estado_brokk.bonus_defesa_temporaria = 2
		c.estado_brokk.ultimo_dado_inimigo = 3
		verificar(c.concluir_deslocamento(), "Deslocamento real antes do save")
		c = ida_e_volta(c, "Preparação capítulo %d" % (capitulo + 1))
		verificar(c.estado_brokk.mestre_armas_usado and c.estado_brokk.muralha_usada and c.estado_brokk.pa_debito_pendente == 1, "Carga não restaura usos nem apaga débito")
		verificar(c.estado_brokk.condicoes.derrubado and c.estado_brokk.condicoes.penalidade_pendente == 1, "Condição e penalidade preservadas")
		verificar(c.estado_brokk.bonus_defesa_natural == 0 and c.estado_brokk.bonus_defesa_escudo == 2, "Defesas derivadas recalculadas")
		vencer(c)
		var coroas: int = c.inventario.coroas
		c = ida_e_volta(c, "Vitória capítulo %d" % (capitulo + 1))
		verificar(not c.conceder_recompensas() and not c.concluir_confronto(true), "Carga não reaplica recompensas")
		verificar(c.inventario.coroas == coroas and c.recompensas_recebidas.has(capitulo), "Histórico com chaves inteiras")
		if capitulo < 3:
			verificar(c.avancar_capitulo() and not c.avancar_capitulo(), "Avança uma única vez após carregar")
	verificar(c.fase == "final" and c.inventario.coroas == 19, "Final salvo preserva 19 coroas")
	verificar(c.inventario.especiais.get("Porção Comum") == 1 and c.inventario.equipamentos.get("Espada de Ferro") == 1, "Loot final não duplicado")
	var derrota := Sistema.new()
	derrota.iniciar_confronto()
	derrota.estado_brokk.pv_atuais = 0
	derrota.concluir_confronto(false)
	derrota = ida_e_volta(derrota, "Derrota")
	verificar(not derrota.iniciar_confronto() and derrota.estado_brokk.pv_atuais == 0 and derrota.inventario.coroas == 0, "Derrota não cura nem recompensa")

func _alimentos_e_equipamentos() -> void:
	var c := Sistema.new()
	c.estado_brokk.pv_atuais = 7
	for id in ["pao_queijo", "costela", "cerveja", "doce"]:
		c.consumir(id)
	c.alimentos.absorver(3)
	c.alimentos.avancar("combate")
	c.alimentos.atualizar_ficha(c.ficha_brokk)
	c.alimentos.relogio = "compartilhado"
	c.alimentos.movimento_por_acao = false
	c = ida_e_volta(c, "Efeitos parcialmente consumidos")
	verificar(c.alimentos.pv_temporarios() == 2 and c.alimentos.ativos["costela"]["restantes"] == 2, "PV temporários e duração exatos")
	verificar(not c.alimentos.ativos.has("doce") and c.ficha_brokk.atributo_efetivo("DES") == 1 and c.ficha_brokk.atributo_efetivo("FOR") == 4, "Efeito expirado não volta; atributos do catálogo")
	verificar(c.estado_brokk.bonus_defesa_natural == 0, "Pele de Rocha inativa em 7 PV")
	c.alimentos.avancar("exploracao")
	verificar(c.alimentos.ativos["cerveja"]["restantes"] == 1, "Relógio compartilhado continua")
	for id in Save.ARMAS:
		c.ficha_brokk.arma_equipada = Save.ARMAS[id].duplicate(true)
		c.ficha_brokk.escudo_equipado = false
		c = ida_e_volta(c, "Equipamento " + id)
		verificar(c.ficha_brokk.arma_equipada == Save.ARMAS[id] and not c.ficha_brokk.escudo_equipado, "Arma canônica e escudo preservados")
	c = Sistema.new()
	c.capitulo = 1
	c.localizacao = c.dados_capitulo()["preparacao"]
	c.recompensas_recebidas = {0: true}
	c.estado_brokk.mestre_armas_usado = true
	c.estado_brokk.muralha_usada = true
	c.concluir_deslocamento()
	c = ida_e_volta(c, "Descanso pendente")
	var comida: int = c.inventario.mantimentos["galinhada"]
	verificar(c.descansar("curto", "galinhada", "mestre_armas_usado")["ok"], "Descanso curto funciona após carregar")
	verificar(not c.estado_brokk.mestre_armas_usado and c.estado_brokk.muralha_usada and c.inventario.mantimentos["galinhada"] == comida - 1, "Só descanso paga comida e recupera a habilidade escolhida")

func _rejeicoes() -> void:
	var c := Sistema.new()
	var original := Save.criar_documento(c)
	for caminho in [
		["jogo"], ["versao"], ["salvo_em"], ["progresso"], ["heroi"], ["inventario"], ["alimentos"],
		["progresso", "capitulo"], ["progresso", "fase"], ["progresso", "local"], ["progresso", "turno"],
		["progresso", "fim_turno"], ["progresso", "recompensas"], ["progresso", "ultima_recompensa"], ["progresso", "batalha_vencida"],
		["heroi", "pv"], ["heroi", "escudo"], ["heroi", "arma"], ["heroi", "mestre_armas_usado"], ["heroi", "muralha_usada"],
		["heroi", "pa_atuais"], ["heroi", "pa_debito_pendente"], ["heroi", "pa_debito_registrado"], ["heroi", "pa_debitado_neste_turno"],
		["heroi", "pa_penalidade_pendente"], ["heroi", "ultimo_dado_inimigo"], ["heroi", "defesa_temporaria"],
		["heroi", "derrubado"], ["heroi", "penalidade_condicao"], ["heroi", "vantagens"], ["heroi", "desvantagens"],
		["inventario", "mantimentos"], ["inventario", "equipamentos"], ["inventario", "especiais"], ["inventario", "coroas"],
		["alimentos", "relogio"], ["alimentos", "movimento_por_acao"], ["alimentos", "ativos"],
	]:
		for valor in [null, [], {}, "inválido", true, -1, 0.5]:
			var adulterado := original.duplicate(true)
			var secao: Dictionary = adulterado if caminho.size() == 1 else adulterado[caminho[0]]
			secao[caminho[-1]] = valor
			# Algumas substituições são valores legítimos do próprio campo.
			var anterior: Variant = original[caminho[0]] if caminho.size() == 1 else original[caminho[0]][caminho[-1]]
			if typeof(valor) == typeof(anterior) and valor == anterior:
				continue
			if caminho[-1] in ["fim_turno", "batalha_vencida", "escudo", "mestre_armas_usado", "muralha_usada", "derrubado", "movimento_por_acao"] and valor is bool:
				continue
			if caminho[-1] in ["vantagens", "desvantagens", "recompensas"] and valor is Array:
				continue
			if caminho[-1] in ["mantimentos", "equipamentos", "especiais", "ativos"] and valor is Dictionary:
				continue
			if caminho[-1] == "ultima_recompensa" and valor is String:
				continue
			verificar(not Save.restaurar(adulterado)["ok"], "Rejeita tipo/valor em " + "/".join(caminho))
	for caso in [
		["progresso", "capitulo", 4], ["progresso", "fase", "combate"], ["progresso", "fase", "final"],
		["progresso", "recompensas", [0]], ["heroi", "pv", 15], ["heroi", "pv", 0], ["heroi", "pa_atuais", 6],
		["heroi", "defesa_temporaria", 1], ["heroi", "vantagens", [7]], ["heroi", "arma", "res://Combate.gd"],
		["inventario", "coroas", 1.5], ["inventario", "mantimentos", {"desconhecido": 1}],
		["inventario", "equipamentos", {"Porrete": -2}], ["inventario", "especiais", {"Porção Comum": 0.5}],
		["alimentos", "ativos", {"cerveja": {"restantes": 4, "temporarios_restantes": 0}}],
		["alimentos", "ativos", {"costela": {"restantes": 3, "temporarios_restantes": 4}}],
		["alimentos", "ativos", {"doce": {"restantes": 0, "temporarios_restantes": 0}}],
		["alimentos", "ativos", {"galinhada": {"restantes": -1, "temporarios_restantes": 0}}],
		["alimentos", "ativos", {"caldo_ovo": {"restantes": -1, "temporarios_restantes": 0}}],
		["alimentos", "ativos", {"pao_queijo": {"restantes": 1, "temporarios_restantes": 2}}],
	]:
		var adulterado := original.duplicate(true)
		adulterado[caso[0]][caso[1]] = caso[2]
		verificar(not Save.restaurar(adulterado)["ok"], "Rejeita estado incompatível: " + str(caso))
	original.erase("salvo_em")
	verificar(documento(c) == original, "Validação inválida não modifica a campanha")
	c.consumir("cerveja")
	var d := Save.criar_documento(c)
	d["alimentos"]["ativos"]["cerveja"]["FOR"] = 999
	var carregada: RefCounted = Save.restaurar(d)["campanha"]
	verificar(carregada.ficha_brokk.atributo_efetivo("FOR") == 4, "Campo extra não injeta atributo")

func _arquivos() -> void:
	var isolado := Save.new(pasta.path_join("seguranca.json"))
	var c := Sistema.new()
	verificar(isolado.salvar(c)["ok"], "Primeira gravação segura")
	c.estado_brokk.pv_atuais = 9
	verificar(isolado.salvar(c)["ok"] and FileAccess.file_exists(isolado.caminho + ".bak"), "Sobrescrita cria backup válido")
	verificar(isolado.carregar()["campanha"].estado_brokk.pv_atuais == 9, "Principal tem gravação recente")
	escrever(isolado.caminho, "{arquivo interrompido")
	var recuperado: Dictionary = isolado.carregar()
	verificar(recuperado["ok"] and recuperado["backup"] and recuperado["campanha"].estado_brokk.pv_atuais == 14, "Corrupção recupera backup com aviso")
	verificar(isolado.salvar(c)["ok"] and isolado.carregar()["campanha"].estado_brokk.pv_atuais == 9, "Save explícito repara principal sem copiar corrupção")
	escrever(isolado.caminho, "[]")
	escrever(isolado.caminho + ".bak", "null")
	verificar(not isolado.carregar()["ok"], "Principal e backup inválidos não carregam")
	var sem_pasta := Save.new(pasta.path_join("pasta_inexistente/slot.json"))
	verificar(not sem_pasta.salvar(c)["ok"], "Falha de abertura não afirma sucesso")
	var grande := Save.new(pasta.path_join("grande.json"))
	escrever(grande.caminho, " ".repeat(Save.LIMITE_BYTES + 1))
	verificar(not grande.carregar()["ok"], "Arquivo grande rejeitado antes do parse")
	verificar(slot.salvar(c)["ok"], "Save de referência antes do combate")
	var anterior := FileAccess.get_file_as_string(slot.caminho)
	c.iniciar_confronto()
	verificar(not slot.salvar(c)["ok"] and FileAccess.get_file_as_string(slot.caminho) == anterior, "Salvar em combate preserva arquivo byte a byte")
	verificar(not Save.restaurar(Save.criar_documento(c))["ok"], "Carga de fase combate bloqueada")

func _clique(controle: Control) -> void:
	var ponto := controle.get_global_rect().get_center()
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

func _interface() -> void:
	var tela = load("res://Campanha.tscn").instantiate()
	tela.salvamento = Save.new(pasta.path_join("ui.json"))
	root.add_child(tela)
	await process_frame
	verificar(tela.botao_carregar.disabled and not tela.botao_salvar.disabled, "UI: Carregar ausente desabilitado")
	tela.campanha.estado_brokk.pv_atuais = 8
	tela.campanha.consumir("cerveja")
	tela.campanha.estado_brokk.mestre_armas_usado = true
	tela.atualizar()
	await _clique(tela.botao_salvar)
	verificar(tela.salvamento.existe() and not tela.botao_carregar.disabled and tela.mensagem.text.begins_with("Campanha salva"), "Clique real em Salvar grava")
	var salvo: Dictionary = documento(tela.campanha)
	tela._reiniciar()
	verificar(tela.campanha.estado_brokk.pv_atuais == 14 and tela.salvamento.existe(), "Reiniciar memória preserva slot")
	await _clique(tela.botao_carregar)
	verificar(documento(tela.campanha) == salvo and tela.estatisticas.text.contains("PV 8/14"), "Clique real em Carregar restaura ficha")
	var independente = load("res://Campanha.tscn").instantiate()
	independente.salvamento = tela.salvamento
	root.add_child(independente)
	await process_frame
	verificar(independente.campanha.estado_brokk.pv_atuais == 14 and not independente.botao_carregar.disabled, "Reabrir cena não carrega nem sobrescreve automaticamente")
	independente.queue_free()
	await process_frame
	var mesma: RefCounted = tela.campanha
	escrever(tela.salvamento.caminho, "null")
	await _clique(tela.botao_carregar)
	verificar(tela.campanha == mesma and documento(tela.campanha) == salvo and tela.mensagem.text.contains("preservada"), "UI preserva partida se carga falhar")
	# Guardas também protegem o combate original independente.
	tela.combate = Node.new()
	tela.add_child(tela.combate)
	tela.atualizar_botoes()
	verificar(tela.botao_salvar.disabled and tela.botao_carregar.disabled, "UI bloqueia persistência com encontro ativo")
	tela._carregar()
	tela._salvar()
	verificar(tela.campanha == mesma and documento(tela.campanha) == salvo and FileAccess.get_file_as_string(tela.salvamento.caminho) == "null", "Callbacks não alteram slot ou partida durante encontro")
	tela.combate.queue_free()
	tela.combate = null
	tela.queue_free()
	await process_frame

func _executar() -> void:
	_progressao()
	_alimentos_e_equipamentos()
	_rejeicoes()
	_arquivos()
	await _interface()
	await _combate_retomado()
	print("RESULTADO SALVAMENTO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)

func _semente(faces: int, natural: int) -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(100000):
		rng.seed = candidato
		if rng.randi_range(1, faces) == natural:
			return candidato
	return -1

func _semente_iniciativa() -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(100000):
		rng.seed = candidato
		var brokk := rng.randi_range(1, 20)
		var primeiro := rng.randi_range(1, 20)
		var segundo := rng.randi_range(1, 20)
		if brokk >= 18 and primeiro <= 5 and segundo <= 5 and absi(primeiro - segundo) >= 3:
			return candidato
	return -1

func _combate_retomado() -> void:
	var tela = load("res://Campanha.tscn").instantiate()
	tela.salvamento = Save.new(pasta.path_join("retomada.json"))
	root.add_child(tela)
	vencer(tela.campanha)
	tela.campanha.avancar_capitulo()
	tela.campanha.estado_brokk.pv_atuais = 9
	tela.campanha.estado_brokk.muralha_usada = true
	tela.campanha.estado_brokk.mestre_armas_usado = true
	tela.campanha.estado_brokk.pa_debito_pendente = 1
	tela.campanha.consumir("cerveja")
	tela._salvar()
	var persistencia: RefCounted = tela.salvamento
	tela.queue_free()
	await process_frame
	tela = load("res://Campanha.tscn").instantiate()
	tela.salvamento = persistencia
	root.add_child(tela)
	await process_frame
	tela._carregar()
	verificar(tela.campanha.capitulo == 1 and tela.campanha.estado_brokk.pv_atuais == 9, "Retomada após recriar cena mantém capítulo e PV")
	tela.iniciar_combate(_semente_iniciativa())
	var combate: Node = tela.combate
	for i in range(3000):
		await process_frame
		if combate.selecionando_posicao:
			combate._confirmar_posicao(Vector2i(2, 1))
		if combate._pode_agir():
			break
	verificar(combate._pode_agir() and combate.turno_atual == "Brokk", "Combate retomado conclui iniciativa e posicionamento")
	verificar(combate.estado_brokk == tela.campanha.estado_brokk and combate.ficha_brokk == tela.campanha.ficha_brokk and combate.alimentos == tela.campanha.alimentos, "Combate usa as instâncias restauradas")
	verificar(combate.estado_brokk.pa_atuais == 4 and combate.estado_brokk.pa_debito_pendente == 0 and combate.estado_brokk.pa_debito_registrado == 1, "Débito salvo descontado exatamente uma vez no primeiro turno")
	verificar(combate.estado_brokk.muralha_usada and combate.estado_brokk.mestre_armas_usado, "Combate não renova habilidades gastas ao carregar")
	var antes := FileAccess.get_file_as_string(persistencia.caminho)
	tela._salvar()
	tela._carregar()
	verificar(tela.combate == combate and FileAccess.get_file_as_string(persistencia.caminho) == antes, "Confronto real bloqueia salvar e carregar sem alterar slot")
	# Aproxima o alvo como fixture; ataque, custo, Defesa e dado são os reais.
	combate.grade.posicoes["Porrete"] = Vector2i(3, 1)
	combate._sincronizar_sprites()
	combate._selecionar_alvo("Porrete")
	combate.gerador.seed = _semente(6, 2)
	await combate._ao_atacar()
	verificar(combate.ultimo_ataque["natural"] == 2 and combate.Dados3D.resultado_visivel(combate.dado_3d) == 2, "Dado visual coincide com ataque após carregar")
	verificar(combate.ultimo_ataque["dano"] == 4 and combate.inimigos["Porrete"].pv_atuais == 2 and combate.estado_brokk.pa_atuais == 1, "Ataque retomado: d6 2 + FOR 4 − Defesa 2 = 4; custo 3 PA")
	verificar(combate.inimigos["Porrete"].nome == "Goblin Sucata" and combate.sprite_porrete.scene_file_path == "res://scenes/characters/GoblinSucata.tscn", "Encontro retomado conserva ficha e apresentação original")
	combate.queue_free()
	tela.combate = null
	await process_frame
	tela.queue_free()
	await process_frame
