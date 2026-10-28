extends "res://tests/teste_campanha.gd"
const FichaZeno = preload("res://ficha_zeno.gd")
const EstadoZeno = preload("res://estado_combate_zeno.gd")
const SaveZeno = preload("res://salvamento_campanha.gd")
var respostas_zeno: Dictionary = {}
var perguntas_zeno: Array[String] = []

func _process(_delta: float) -> bool:
	if is_instance_valid(cena) and cena.aguardando_decisao:
		var titulo: String = cena.dialogo_habilidade.title
		perguntas_zeno.append(titulo)
		var fila: Array = respostas_zeno.get(titulo, [])
		cena._responder_habilidade(bool(fila.pop_front()) if not fila.is_empty() else false)
	return false

func _modelos_zeno() -> void:
	var ficha := FichaZeno.new()
	verificar(ficha.NOME == "Zeno" and ficha.RACA["nome"] == "Humano" and ficha.CLASSE["nome"] == "Guerreiro", "Identidade oficial de Zeno")
	var esperados := {"FOR": 3, "DES": 2, "CON": 3, "INT": 0, "SAB": 1, "CAR": 1}
	for atributo in esperados:
		verificar(ficha.atributo(atributo) == esperados[atributo], "Atributo humano: " + atributo)
	verificar(ficha.pv_maximos() == 14 and ficha.atributo_efetivo("DES") == 1, "PV 14 e DES efetiva 1 com escudo")
	verificar(ficha.arma_atual() == Equipamentos.ESPADA_FERRO and ficha.arma_atual()["maos"] == 1 and ficha.dado_ataque() == 6, "Espada de Ferro inicial 1H e d6")
	verificar(ficha.EQUIPAMENTOS["escudo"]["nome"] == "Escudo de Ferro e Madeira", "Escudo oficial")
	for pv in range(15):
		verificar(ficha.bonus_pele_rocha(pv) == 0, "Humano não herda Pele de Rocha")
	for faces in [4, 6, 8, 10, 12]:
		verificar(ficha.regra_derrubado_por_proeza(faces) == "sem_regra_especial", "Humano não herda Firmeza de Rocha")
	for natural in range(1, 7):
		verificar(ficha.dano_ataque(natural) == (0 if natural == 1 else natural + 3), "Espada sem bônus de Machado ou crítico")
	verificar(Equipamentos.permite_repetir_erro(ficha.arma_atual(), {"FOR": 2, "DES": 0}) and Equipamentos.permite_repetir_erro(ficha.arma_atual(), {"FOR": 0, "DES": 2}), "Espada aceita FOR ou DES")
	verificar(not Equipamentos.permite_repetir_erro(ficha.arma_atual(), {"FOR": 1, "DES": 1}), "Espada exige atributo mínimo")
	for faces in [4, 6, 8, 10, 12]:
		for natural in range(1, faces + 1):
			var estado := EstadoZeno.new()
			estado.iniciar_combate()
			verificar(estado.registrar_ataque(natural, faces) == (natural >= 5), "Talento usa o natural real da arma")
			verificar(estado.bonus_veterano_dano == (1 if natural >= 5 else 0), "Bônus ofensivo não depende do tamanho máximo do dado")
			verificar(estado.registrar_ataque(5, 6) == (natural < 5), "Só primeira ativação ofensiva")
			verificar(not estado.registrar_ataque(6, 6) and estado.bonus_veterano_dano == 1, "Ofensiva não acumula")
			estado.encerrar_combate()
			verificar(estado.bonus_veterano_dano == 0 and not estado.registrar_ataque(6, 6), "Ofensiva termina com o combate")
	var estado := EstadoZeno.new()
	estado.iniciar_combate()
	verificar(not estado.registrar_defesa(0, false) and not estado.registrar_defesa(1, true), "Sem defesa/esquiva ou com dano não ativa")
	verificar(estado.registrar_defesa(0, true) and estado.bonus_veterano_defesa == 1, "Defender sem dano ativa Defesa +1")
	verificar(not estado.registrar_defesa(0, true) and estado.bonus_veterano_defesa == 1, "Defesa não acumula")
	estado.encerrar_combate()
	verificar(estado.bonus_veterano_defesa == 0, "Defesa termina com o combate")
	estado.iniciar_combate()
	verificar(estado.registrar_defesa(0, false, true), "Integração de futura esquiva preparada")
	verificar(estado.confirmar_mestre_armas() and estado.confirmar_muralha(7, 1) == 3, "Habilidades de Guerreiro herdadas")
	verificar(estado.confirmar_repeticao_espada() and not estado.confirmar_repeticao_espada(), "Espada usa limite próprio")
	estado.encerrar_combate()
	estado.iniciar_combate()
	verificar(estado.bonus_veterano_defesa == 0 and estado.bonus_veterano_dano == 0 and not estado.espada_repeticao_usada, "Novo confronto renova apenas os limites por combate")
	verificar(estado.mestre_armas_usado and estado.muralha_usada and estado.pa_debito_pendente == 1, "Novo confronto preserva usos/debito de classe até descanso")

func _semente_zeno(dados: Array[int], faces: int = 6) -> int:
	var rng := RandomNumberGenerator.new()
	for numero in range(100000):
		rng.seed = numero
		var correto := true
		for dado in dados:
			if rng.randi_range(1, faces) != dado:
				correto = false
				break
		if correto:
			return numero
	verificar(false, "Semente dos cenários Zeno")
	return 0

func _caso_zeno(dados: Array[int]) -> int:
	cena.estado_brokk.iniciar_combate()
	cena.estado_brokk.mestre_armas_usado = false
	cena.estado_brokk.muralha_usada = false
	cena.estado_brokk.pa_atuais = 5
	cena.estado_brokk.pa_debito_pendente = 0
	cena.estado_brokk.condicoes.derrubado = false
	cena.estado_brokk.condicoes.penalidade_pendente = 0
	cena.vida_brokk = 14
	cena.turno_atual = "Brokk"
	# Alvo resistente exclusivamente para comparar vários ataques da fixture.
	cena.inimigos["Bandido"].pv_maximos = 60
	cena.inimigos["Bandido"].pv_atuais = 60
	cena.alvo_selecionado = "Bandido"
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(3, 1), "Porrete": Vector2i(5, 2)}
	cena.estado_brokk.fontes_vantagem.clear()
	cena.estado_brokk.fontes_desvantagem.clear()
	respostas_zeno.clear()
	perguntas_zeno.clear()
	cena.efeitos.eventos.clear()
	cena.gerador.seed = _semente_zeno(dados)
	var rng := RandomNumberGenerator.new()
	rng.seed = cena.gerador.seed
	for valor in dados:
		rng.randi_range(1, 6)
	cena._sincronizar_sprites()
	cena._atualizar_interface()
	return rng.state

func _ataques_zeno() -> void:
	await _encontro(Sistema.new())
	verificar(cena.ficha_brokk.NOME == "Zeno" and cena._nome_participante("Brokk") == "Zeno", "Campanha usa Zeno com ID legado interno")
	verificar(cena.sprite_brokk.animacao.sprite_frames.get_meta("protagonista", "") == "zeno", "Sprite atual é humano Zeno")
	verificar(cena._resumo_ficha().contains("Humano") and not cena._resumo_ficha().contains("Pele de Rocha"), "Ficha humana não exibe passivas de Anão")
	for natural in range(1, 7):
		var rng := _caso_zeno([natural])
		await cena._ao_atacar()
		var dano := 0 if natural == 1 else natural + 3 + (1 if natural >= 5 else 0)
		verificar(cena.ultimo_ataque["dano"] == dano and cena.inimigos["Bandido"].pv_atuais == 60 - dano, "Dano correto, inclusive ativação no próprio ataque")
		verificar(cena.Dados3D.resultado_visivel(cena.dado_3d) == natural and cena.gerador.state == rng, "Dado visual usado no cálculo; sem sorteio extra")
		verificar(cena.estado_brokk.bonus_veterano_dano == (1 if natural >= 5 else 0), "Estado ofensivo no combate")
		verificar(cena.efeitos.eventos.count("veterano:dano") == (1 if natural >= 5 else 0), "Efeito ofensivo dispara uma vez")
		verificar(cena.texto_passivas.text.contains("Dano +%d" % (1 if natural >= 5 else 0)), "Talento indicado na inspeção")
	_caso_zeno([1, 4])
	respostas_zeno["Espada de Ferro"] = [true]
	await cena._ao_atacar()
	verificar(cena.ultimo_ataque["natural"] == 4 and cena.ultimo_ataque["dano"] == 7 and cena.estado_brokk.espada_repeticao_usada and not cena.estado_brokk.mestre_armas_usado, "Espada repete erro sem consumir Mestre")
	verificar(cena.estado_brokk.pa_atuais == 2, "Repetição da Espada não cobra ataque extra")
	cena.estado_brokk.pa_atuais = 5
	cena.gerador.seed = _semente_zeno([1, 5])
	respostas_zeno["Mestre das Armas"] = [true]
	await cena._ao_atacar()
	verificar(cena.estado_brokk.mestre_armas_usado and cena.ultimo_ataque["natural"] == 5 and cena.ultimo_ataque["dano"] == 9, "Mestre continua independente da Espada e ativa talento")
	_caso_zeno([5, 1])
	respostas_zeno["Mestre das Armas"] = [true]
	await cena._ao_atacar()
	verificar(cena.ultimo_ataque["natural"] == 1 and cena.ultimo_ataque["dano"] == 0 and cena.estado_brokk.bonus_veterano_dano == 0, "Mestre substitui o 5: natural descartado não ativa talento")
	_caso_zeno([2, 6, 3])
	respostas_zeno["Mestre das Armas"] = [true]
	await cena._atacar_com_vantagem()
	verificar(cena.ultimo_ataque["dados"] == [2, 3] and cena.ultimo_ataque["natural"] == 3 and cena.estado_brokk.bonus_veterano_dano == 0, "Vantagem: Mestre repete só maior; 6 descartado não ativa")
	for caso in [{"dados": [1, 1, 2, 5], "modo": "vantagem", "natural": 5, "dano": 9},
		{"dados": [1, 6, 4, 5], "modo": "desvantagem", "natural": 4, "dano": 7}]:
		var dados: Array[int] = []
		dados.assign(caso["dados"])
		var rng := _caso_zeno(dados)
		respostas_zeno["Espada de Ferro"] = [true]
		if caso["modo"] == "desvantagem":
			cena.estado_brokk.fontes_desvantagem.assign(["teste"])
		await cena._ataque_brokk(caso["modo"] == "vantagem")
		verificar(cena.ultimo_ataque["natural"] == caso["natural"] and cena.ultimo_ataque["dano"] == caso["dano"], "Espada repete o ataque completo mantendo " + caso["modo"])
		verificar(cena.gerador.state == rng and cena.estado_brokk.espada_repeticao_usada, "Repetição usa exatamente a nova rolagem")
	# Bônus continua no próximo ataque, sem reapresentar efeito.
	_caso_zeno([5])
	await cena._ao_atacar()
	cena.estado_brokk.pa_atuais = 5
	cena.gerador.seed = _semente_zeno([2])
	await cena._ao_atacar()
	verificar(cena.ultimo_ataque["dano"] == 6 and cena.efeitos.eventos.count("veterano:dano") == 1, "Dano +1 permanece sem acumular ou repetir efeito")
	for inimigo in cena.inimigos.values():
		inimigo.pv_atuais = 0
	cena._verificar_fim_combate()
	verificar(cena.estado_brokk.bonus_veterano_dano == 0 and cena.apresentacao.texto_pa.text.contains("DANO +0"), "Vitória remove bônus também da interface")
	await _fechar()

func _defesas_zeno() -> void:
	await _encontro(Sistema.new())
	_caso_zeno([3])
	cena.grade.posicoes["Bandido"] = Vector2i(3, 2) # Diagonal: arco sem Desvantagem.
	cena.ordem_turnos.assign(["Brokk", "Bandido"])
	cena._sincronizar_sprites()
	cena._defender()
	verificar(cena.estado_brokk.pa_atuais == 4, "Ação Defender mantém custo de 1 PA")
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	await cena._executar_ataque_inimigo("Bandido")
	verificar(cena.ultimo_ataque["dano"] == 0 and cena.vida_brokk == 14 and cena.estado_brokk.bonus_veterano_defesa == 1, "Bloqueio sem dano ativa Veterano defensivo")
	verificar(cena.estado_brokk.bonus_defesa_temporaria == 0 and cena._fontes_defesa_brokk(4)["veterano"] == 1, "Veterano persiste quando Defender expira")
	verificar(cena.efeitos.eventos.count("veterano:defesa") == 1 and cena.efeitos.eventos.count("som:escudo") == 2, "Ativação defensiva tem feedback e som, além do bloqueio")
	verificar(cena.apresentacao.texto_pa.text.contains("DEF +1") and cena.texto_passivas.text.contains("Defesa +1 (ativa)"), "Bônus defensivo claramente identificado na UI")
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente_zeno([4])
	await cena._executar_ataque_inimigo("Bandido")
	verificar(cena.ultimo_ataque["bruto"] == 5 and cena.ultimo_ataque["defesa"] == 1 and cena.ultimo_ataque["dano"] == 4 and cena.vida_brokk == 10, "Veterano reduz ataque seguinte pelo cálculo central")
	cena._defender()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	cena.gerador.seed = _semente_zeno([2])
	await cena._executar_ataque_inimigo("Bandido")
	verificar(cena.ultimo_ataque["dano"] == 0 and cena.efeitos.eventos.count("veterano:defesa") == 1 and cena.estado_brokk.bonus_veterano_defesa == 1, "Novo bloqueio não acumula nem repete ativação")
	_caso_zeno([6])
	cena.grade.posicoes["Bandido"] = Vector2i(3, 2)
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 3
	respostas_zeno["Muralha de Ferro"] = [true]
	await cena._executar_ataque_inimigo("Bandido")
	verificar(cena.ultimo_ataque["dano"] == 7 and cena.ultimo_ataque["dano_recebido"] == 3 and cena.vida_brokk == 11, "Muralha mantém metade para baixo com Zeno")
	verificar(cena.estado_brokk.muralha_usada and cena.estado_brokk.pa_atuais == 4, "Muralha mantém débito diferido de 1 PA")
	_caso_zeno([6])
	cena.ordem_turnos.assign(["Brokk", "Porrete"])
	cena.grade.posicoes["Porrete"] = Vector2i(3, 2)
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 3
	await cena._executar_ataque_inimigo("Porrete")
	verificar(cena.ultimo_ataque["derrubado"] == "aplicado" and cena.estado_brokk.pa_atuais == 4, "Zeno recebe Derrubado; não herda imunidade anã")
	verificar(cena.ultimo_ataque["defesa"] == 0 and cena.vida_brokk == 6, "PV altos não concedem Pele de Rocha ao humano")
	cena.estado_brokk.registrar_defesa(0, true)
	for inimigo in cena.inimigos.values():
		inimigo.pv_atuais = 0
	cena._verificar_fim_combate()
	verificar(cena.estado_brokk.bonus_veterano_defesa == 0 and cena.apresentacao.texto_pa.text.contains("DEF +0"), "Fim do combate limpa defesa na regra e na interface")
	await _fechar()


func _visuais_zeno() -> void:
	var quadros: SpriteFrames = load("res://assets/characters/zeno/zeno_animacoes.tres")
	for nome in [&"idle", &"caminhar", &"correr", &"ataque", &"defesa", &"dano", &"morte"]:
		verificar(quadros.get_frame_count(nome) == 8 and quadros.get_animation_speed(nome) > 0, "Oito quadros por animação de Zeno: " + nome)
		verificar(quadros.get_animation_loop(nome) == (nome in [&"idle", &"caminhar", &"correr"]), "Loop só nas animações contínuas")
		for indice in range(8):
			var atlas: AtlasTexture = quadros.get_frame_texture(nome, indice)
			verificar(atlas.atlas.resource_path.begins_with("res://assets/characters/zeno/"), "Fonte própria do humano Zeno")
			verificar(Rect2(Vector2.ZERO, atlas.atlas.get_size()).encloses(atlas.region), "Nenhum quadro ultrapassa a imagem")
			verificar(atlas.get_size() == Vector2(384, 384) and atlas.margin.position.x >= 0 and atlas.margin.position.y >= 0, "Tela lógica e margens válidas")
			verificar(is_equal_approx(atlas.margin.position.y + atlas.region.size.y, 352), "Pés alinhados durante animações")
	var sprite: Sprite2D = load("res://scenes/characters/Zeno.tscn").instantiate()
	sprite.ocultar_apos_morte = false
	root.add_child(sprite)
	verificar(sprite.animacao.sprite_frames.get_meta("protagonista", "") == "zeno" and sprite.animacao.animation == &"idle", "Cena própria de Zeno abre em idle")
	sprite.olhar_para(Vector2.LEFT)
	verificar(sprite.animacao.flip_h, "Zeno olha para ambos os lados sem inverter a raiz")
	await sprite.animar_ataque_ate_impacto()
	verificar(sprite.animacao.frame == 4 and sprite.ataques_apresentados == 1, "Espada sinaliza contato no quinto quadro")
	await sprite.animacao.animation_finished
	verificar(not sprite.em_ataque and sprite.animacao.animation == &"idle", "Recuperação do ataque retorna a idle")
	sprite.definir_vivo(false)
	await sprite.morte_finalizada
	verificar(sprite.animacao.animation == &"morte" and sprite.animacao.frame == 7 and not sprite.animacao.is_playing(), "Morte termina no quadro final sem repetir")
	sprite.queue_free()
	await process_frame


func _save_zeno() -> void:
	var campanha := Sistema.new()
	campanha.estado_brokk.mestre_armas_usado = true
	campanha.estado_brokk.pa_debito_pendente = 1
	var documento := SaveZeno.criar_documento(campanha)
	verificar(documento["versao"] == 2 and documento["heroi"]["nome"] == "Zeno" and not documento.has("brokk"), "Save v2 identifica Zeno")
	var resultado := SaveZeno.restaurar(documento)
	verificar(resultado["ok"] and resultado["campanha"].ficha_brokk.arma_atual() == Equipamentos.ESPADA_FERRO, "Save restaura Espada padrão")
	var legado := documento.duplicate(true)
	legado["versao"] = 1
	legado["brokk"] = legado["heroi"]
	legado.erase("heroi")
	for campo in ["id", "nome", "raca", "classe", "espada_repeticao_usada"]:
		legado["brokk"].erase(campo)
	resultado = SaveZeno.restaurar(legado)
	verificar(resultado["ok"] and resultado["campanha"].ficha_brokk.NOME == "Zeno", "Migra save v1 para protagonista oficial")
	verificar(resultado["campanha"].estado_brokk.mestre_armas_usado and resultado["campanha"].estado_brokk.pa_debito_pendente == 1, "Migração não recupera usos nem apaga dívida")
	verificar(legado.has("brokk") and legado["versao"] == 1, "Migração não modifica documento de origem")
	campanha.estado_brokk.espada_repeticao_usada = true
	campanha.ficha_brokk.arma_equipada = Equipamentos.ESPADA_FERRO.duplicate(true)
	resultado = SaveZeno.restaurar(SaveZeno.criar_documento(campanha))
	verificar(resultado["ok"] and resultado["campanha"].estado_brokk.espada_repeticao_usada, "Save v2 preserva registro de uso da Espada")
	verificar(not resultado["campanha"].estado_brokk.combate_ativo and resultado["campanha"].estado_brokk.bonus_veterano_defesa == 0 and resultado["campanha"].estado_brokk.bonus_veterano_dano == 0, "Save entre confrontos não ressuscita bônus de Veterano")
	var explicito := legado.duplicate(true)
	explicito["brokk"]["arma"] = "machado_ferro"
	resultado = SaveZeno.restaurar(explicito)
	verificar(resultado["ok"] and resultado["campanha"].ficha_brokk.arma_atual() == Equipamentos.MACHADO_FERRO, "Migração preserva arma explicitamente equipada")

func _executar() -> void:
	_modelos_zeno()
	_save_zeno()
	await _ataques_zeno()
	await _defesas_zeno()
	await _visuais_zeno()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO ZENO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
