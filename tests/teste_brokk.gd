extends SceneTree
## Execute: Godot --headless --path . --script res://tests/teste_brokk.gd

const Ficha = preload("res://ficha_brokk.gd")
const Estado = preload("res://estado_combate_brokk.gd")
const Regras = preload("res://regras_combate.gd")
const Grade = preload("res://grade_combate.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const Condicoes = preload("res://condicoes_combate.gd")
const Inimigo = preload("res://estado_inimigo.gd")
const Efeitos = preload("res://efeitos_combate.gd")

var cena: Variant
var respostas_mestre: Array[bool] = []
var respostas_muralha: Array[bool] = []
var decisoes: Array[Dictionary] = []
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	Engine.time_scale = 20.0
	call_deferred("_executar")


func _process(_delta: float) -> bool:
	if is_instance_valid(cena) and cena.aguardando_decisao:
		var mestre: bool = cena.dialogo_habilidade.title == "Mestre das Armas"
		decisoes.append({"mestre": mestre, "bandido_pv": cena.vida_bandido, "muralha_usada": cena.estado_brokk.muralha_usada})
		var resposta := false
		if mestre and not respostas_mestre.is_empty():
			resposta = respostas_mestre.pop_front()
		elif not mestre and not respostas_muralha.is_empty():
			resposta = respostas_muralha.pop_front()
		cena._responder_habilidade(resposta)
	return false


func _verificar(condicao: bool, descricao: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error("FALHOU: " + descricao)


func _modelos() -> void:
	var ficha := Ficha.new()
	var totais := {"FOR": 3, "DES": 2, "CON": 3, "INT": 0, "SAB": 1, "CAR": 1}
	for atributo in totais:
		_verificar(ficha.atributo(atributo) == totais[atributo], "Total " + atributo)
	_verificar(ficha.pv_maximos() == 14, "PV base + CON")
	for natural in range(1, 7):
		_verificar(ficha.dano_ataque(natural) == (0 if natural == 1 else natural + 3 + (2 if natural == 6 else 0)), "Machado natural %d" % natural)
		_verificar(ficha.bonus_escudo(natural) == (2 if natural in [2, 3] else 0), "Escudo natural %d" % natural)
	for pv in range(15):
		_verificar(ficha.bonus_pele_rocha(pv) == (1 if pv >= 8 else 0), "Pele de Rocha PV %d" % pv)
	_verificar(ficha.vantagem_desafio_forca(true) and not ficha.vantagem_desafio_forca(false), "Físico Atlético apenas desafio puro de FOR")
	_verificar(ficha.vantagem_resistencia_doenca(), "Vantagem contra doenças preparada")
	for dado in [6, 8]:
		_verificar(ficha.regra_derrubado_por_proeza(dado) == "imune", "Firmeza d%d" % dado)
	for dado in [10, 12]:
		_verificar(ficha.regra_derrubado_por_proeza(dado) == "resistencia_com_vantagem", "Firmeza d%d" % dado)
	_verificar(ficha.regra_derrubado_por_proeza(4) == "sem_regra_especial", "Nenhuma imunidade inventada para outros dados")
	for descanso in ["curto", "longo", "nenhum"]:
		for comida in [true, false]:
			for fim_turno in [true, false]:
				_verificar(ficha.recuperacao_permitida(descanso, comida, fim_turno) == (descanso != "nenhum" and comida and fim_turno), "Condições de recuperação")
	var estado := Estado.new(ficha.pv_maximos())
	_verificar(estado.pv_atuais == 14, "Início em 14/14")
	_verificar(estado.confirmar_muralha(7, 1) == 3, "Muralha arredonda 7/2 para 3")
	_verificar(estado.pa_debito_pendente == 1 and estado.pa_debito_registrado == 0, "Custo adiado")
	_verificar(estado.confirmar_muralha(7, 1) == 7, "Muralha não pode ser reutilizada")
	_verificar(estado.iniciar_turno() == 1 and estado.pa_debito_pendente == 0, "Débito no início do próximo turno")
	_verificar(estado.iniciar_turno() == 0 and estado.pa_debito_registrado == 1, "Débito registrado uma única vez")
	_verificar(estado.confirmar_mestre_armas() and not estado.confirmar_mestre_armas(), "Mestre das Armas uma vez")
	estado.iniciar_turno()
	_verificar(estado.muralha_usada and estado.mestre_armas_usado, "Turnos não recuperam habilidades")
	print("Modelos: atributos, PV, passivas, equipamentos, usos e custo diferido conferidos.")


func _instanciar_legado() -> Node:
	# Exercita o protótipo anterior sem trocar o protagonista do fluxo principal.
	var legado: Node = load("res://Combate.tscn").instantiate()
	legado.ficha_brokk = Ficha.new()
	legado.estado_brokk = Estado.new(legado.ficha_brokk.pv_maximos())
	return legado


func _novo_combate(tres_participantes: bool = false) -> void:
	respostas_mestre.clear()
	respostas_muralha.clear()
	cena = _instanciar_legado()
	# Fixture determinística: as regressões específicas começam no turno de Brokk.
	# A iniciativa aleatória e inimigos agindo primeiro têm testes próprios.
	cena.semente_inicial = _semente_primeiro_turno()
	# Regressões isoladas do duelo; os testes de encontro usam os três vivos.
	if not tres_participantes:
		cena.inimigos["Porrete"].pv_atuais = 0
	root.add_child(cena)
	if tres_participantes:
		_verificar(cena.vida_bandido == 6 and cena.inimigos["Porrete"].pv_atuais == 8, "PV iniciais antes de qualquer ação")
		_verificar(cena.grade.posicoes["Bandido"] == Vector2i(4, 1) and cena.grade.posicoes["Porrete"] == Vector2i(4, 2), "Inimigos começam nas casas fixas B5 e C5")
		_verificar(cena.dado_iniciativa_brokk.visible and cena.dado_iniciativa_bandido.visible and cena.dado_iniciativa_porrete.visible, "Três dados aparecem juntos na iniciativa")
		var camera: Camera3D = cena.visual_dado.get_node("DadoViewport/MundoDado/Camera3D")
		var meia_largura: float = camera.size * cena.visual_dado.size.x / cena.visual_dado.size.y / 2.0
		for dado in [cena.dado_iniciativa_brokk, cena.dado_iniciativa_bandido, cena.dado_iniciativa_porrete]:
			var raio: float = 0.98 * dado.scale.x
			_verificar(absf(dado.position.x) + raio < meia_largura and raio < camera.size / 2.0, "Cubo inteiro permanece no viewport durante rotação")
	var pv_inicial_bandido: int = cena.vida_bandido
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == pv_inicial_bandido and cena.botao_atacar.disabled, "Ataque bloqueado antes da iniciativa")
	var pronto := false
	for frame in range(1500):
		await process_frame
		if cena.selecionando_posicao:
			_verificar(cena.estado_brokk.pa_atuais == 0 and cena.pa_bandido == 0, "Posicionamento precede os PA e a primeira ação")
			if tres_participantes:
				_verificar(cena.inimigos["Porrete"].pa_atuais == 0, "Segundo inimigo não recebe PA antes do posicionamento")
			_verificar(cena._confirmar_posicao(Vector2i(2, 1)), "Confirmação inicial sem custo")
		if cena.iniciativa_concluida and cena._pode_agir() and not cena.rolagem_em_andamento:
			pronto = true
			break
	_verificar(pronto, "Iniciativa e primeiro turno concluídos")
	if not pronto:
		quit(1)
		return
	# Normalização exclusiva da fixture, depois do eventual primeiro ataque inimigo.
	cena.vida_brokk = 14
	decisoes.clear()


func _fechar_combate() -> void:
	_verificar(cena.sprite_brokk.offset == Vector2.ZERO and cena.sprite_bandido.offset == Vector2.ZERO and cena.sprite_porrete.offset == Vector2.ZERO, "Feedback restaura offsets visuais dos personagens")
	_verificar(is_zero_approx(cena.escudo_visual.rotation), "Vibração devolve escudo à rotação original")
	cena.queue_free()
	await process_frame
	cena = null


func _semente(resultados: Array[int]) -> int:
	var rng := RandomNumberGenerator.new()
	for numero in range(100000):
		rng.seed = numero
		var coincide := true
		for esperado in resultados:
			if rng.randi_range(1, 6) != esperado:
				coincide = false
				break
		if coincide:
			return numero
	_verificar(false, "Semente para cenário determinístico")
	return 0

func _semente_primeiro_turno() -> int:
	var rng := RandomNumberGenerator.new()
	for valor in range(10000):
		rng.seed = valor
		var brokk := rng.randi_range(1, 20) + 1
		var arco := rng.randi_range(1, 20) + 1
		var porrete := rng.randi_range(1, 20)
		if brokk > arco and brokk > porrete and arco != porrete:
			return valor
	return -1


func _aproximar_brokk() -> void:
	# Fixture: diagonal em relação ao bandido. Machado alcança, arco não recebe Desvantagem.
	cena.grade.posicionar("Brokk", Vector2i(3, 0))
	cena._sincronizar_sprites()
	cena._atualizar_interface()


func _mestre_armas() -> void:
	await _novo_combate()
	_aproximar_brokk()
	respostas_mestre.assign([false])
	cena.gerador.seed = _semente([2, 1])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 1, "Brokk natural 2 acerta por 5")
	_verificar(cena.estado_brokk.pa_atuais == 2 and cena.turno_atual == "Brokk", "Ataque custa 3 PA e preserva o turno para outras ações")
	_verificar(not cena.estado_brokk.mestre_armas_usado and decisoes[0]["bandido_pv"] == 6, "Recusa preserva uso; decisão antes do dano")
	_verificar(cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(2)), "Dado azul corresponde ao natural 2")
	await _fechar_combate()

	await _novo_combate()
	_aproximar_brokk()
	respostas_mestre.assign([true])
	cena.gerador.seed = _semente([6, 1, 1])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 6 and cena.estado_brokk.mestre_armas_usado, "Segundo resultado 1 substitui primeiro 6, sem dano inicial")
	_verificar(cena.ultimo_ataque["bonus_arma"] == 0 and cena.ultimo_ataque["bruto"] == 0, "6 descartado pelo Mestre não ativa bônus do machado")
	_verificar(decisoes.size() == 1 and cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(1)), "Só uma repetição; número visual final 1")
	await cena._encerrar_turno()
	cena.gerador.seed = _semente([2, 1])
	await cena._ao_atacar()
	_verificar(decisoes.size() == 1 and cena.estado_brokk.mestre_armas_usado, "Uso não retorna no próximo turno")
	await _fechar_combate()

	await _novo_combate()
	_aproximar_brokk()
	respostas_mestre.assign([true])
	cena.gerador.seed = _semente([1, 2, 1])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 1, "Natural 1 também pode ser repetido; segundo natural 2 aplicado")
	await _fechar_combate()
	print("Mestre das Armas: recusa, natural 1, pior resultado obrigatório e uso único conferidos.")


func _bandido_e_muralha() -> void:
	await _novo_combate()
	for natural in range(1, 7):
		cena.vida_brokk = 14
		cena.turno_atual = "Bandido"
		cena.pa_bandido = 5
		cena.gerador.seed = _semente([natural])
		await cena._executar_ataque_bandido()
		var dano: int = Regras.ataque_fisico(natural, 1, {"natural": 1, "escudo": 2 if natural in [2, 3] else 0, "temporaria": 0})["dano"]
		_verificar(cena.vida_brokk == 14 - dano, "Bandido natural %d: Defesa oficial reduz dano" % natural)
		_verificar(cena.ultimo_ataque["erro"] == (natural == 1), "Somente natural 1 é erro automático")
		_verificar(not cena.estado_brokk.muralha_usada and cena.estado_brokk.pa_debito_pendente == 0, "Recusar reação não consome nem cobra")
		_verificar(cena.texto_dado.text == "D6: %d" % natural and cena.dado_bandido_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(natural)), "Dado vermelho e texto correspondem ao cálculo")
		_verificar(not cena.visual_dado.visible and not cena.dado_bandido_3d.visible and not cena.dado_3d.visible, "Dados ocultos entre ataques")
	cena.vida_brokk = 7
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([2])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 6 and not cena.ultimo_ataque["erro"], "Natural 2 causa 1 de dano com escudo e sem Pele de Rocha")
	cena.vida_brokk = 8
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([4])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 4 and cena.ultimo_ataque["defesa"] == 1 and cena.estado_brokk.bonus_defesa_natural == 0, "Defesa do ataque usa PV anteriores, mas Pele atualiza após dano")
	var pv_antes: int = cena.vida_brokk
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == pv_antes, "Bandido não ataca fora do próprio turno")

	cena.vida_brokk = 14
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	respostas_muralha.assign([true])
	var pendencias: Array[int] = []
	cena.estado_brokk.alterado.connect(func() -> void: pendencias.append(cena.estado_brokk.pa_debito_pendente))
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 11 and cena.estado_brokk.muralha_usada, "Muralha após Defesa: bruto 7 - Defesa 1 = 6; metade 3")
	_verificar(pendencias.has(1) and cena.estado_brokk.pa_debito_pendente == 0 and cena.estado_brokk.pa_debito_registrado == 1, "PA pendente vira registro somente no início de Brokk")
	_verificar(cena.estado_brokk.pa_atuais == 4, "Muralha inicia o próximo turno com 4/5 PA")
	var pv_bandido: int = cena.vida_bandido
	_aproximar_brokk()
	await cena._atacar_com_vantagem()
	_verificar(cena.vida_bandido == pv_bandido and cena.estado_brokk.pa_atuais == 4, "Vantagem bloqueada com 4 PA, sem consumir ação")
	cena.grade.posicionar("Brokk", Vector2i(2, 1))
	cena._sincronizar_sprites()
	var qtd_decisoes: int = decisoes.size()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 5 and decisoes.size() == qtd_decisoes, "Muralha não se repete")
	cena.vida_brokk = 8
	_verificar(cena.texto_passivas.text.contains("Pele de Rocha: +1 ativa") and cena.estado_brokk.bonus_defesa_natural == 1, "Pele atualiza imediatamente em 8 PV")
	cena.vida_brokk = 7
	_verificar(cena.texto_passivas.text.contains("Pele de Rocha: +0 inativa") and cena.estado_brokk.bonus_defesa_natural == 0, "Pele atualiza imediatamente em 7 PV")
	cena.vida_brokk = 1
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_bandido()
	_verificar(cena.vida_brokk == 0 and cena.botao_atacar.disabled and cena.turno_atual == "", "Derrota encerra o combate e limita PV em 0")
	await _fechar_combate()
	print("Bandido: naturais 1 a 6, reação, débito diferido, turnos, PV e derrota conferidos.")


func _interface() -> void:
	await _novo_combate()
	_aproximar_brokk()
	await process_frame
	_verificar(cena.botao_atacar.get_global_rect().end.x <= 1280, "Botão Atacar dentro da tela")
	_verificar(not cena.painel_brokk.is_visible_in_tree() and cena.apresentacao.retangulo_grade().size.x >= 792, "Resumo sai do topo e o tabuleiro fica maior")
	for botao in [cena.botao_atacar, cena.botao_vantagem, cena.botao_defender, cena.botao_mover, cena.botao_correr, cena.botao_encerrar]:
		_verificar(botao.get_global_rect().end.x <= 1280 and botao.get_global_rect().end.y <= 960, "Controle de ação cabe na janela")
	var retangulo_grade: Rect2 = cena.apresentacao.retangulo_grade()
	_verificar(not retangulo_grade.intersects(cena.visual_dado.get_global_rect()), "Dados 3D ficam fora do tabuleiro")
	_verificar(not cena.apresentacao.area_detalhes.get_global_rect().intersects(cena.visual_dado.get_global_rect()), "Inspeção não cobre dados")
	cena._abrir_ficha()
	await process_frame
	_verificar(cena.dialogo_ficha.visible and cena.dialogo_ficha.size.y <= 540, "Ficha cabe na interface")
	_verificar(cena.texto_ficha.text.contains("CON: +2 + +1 = +3"), "Ficha exibe origem dos atributos")
	cena.dialogo_ficha.hide()
	respostas_mestre.assign([false])
	cena.gerador.seed = _semente([6])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 0 and cena.turno_atual == "" and cena.botao_atacar.disabled, "Vitória encerra combate sem ataque inimigo extra")
	_verificar(cena.ultimo_ataque["bruto"] == 11 and cena.ultimo_ataque["bonus_arma"] == 2 and cena.texto_resultado.text.contains("bônus do Machado"), "Natural 6: dano bruto 11 e bônus especial identificado")
	await _fechar_combate()


func _defesa_pa_e_grade() -> void:
	var fontes := {"natural": 1, "escudo": 2, "temporaria": 2}
	_verificar(Regras.defesa_total(fontes) == 5, "Defesas somam 1 + 2 + 2, sem base implícita")
	var resultado := Regras.ataque_fisico(2, 1, fontes)
	_verificar(not resultado["erro"] and resultado["dano"] == 0, "Natural 2 acerta; escudo reduz e dano mínimo é 0")
	_verificar(Regras.ataque_fisico(3, 1, {"escudo": 2})["dano"] == 2, "Natural 3 ativa escudo e continua sendo acerto")
	_verificar(Regras.ataque_fisico(1, 100, {})["dano"] == 0, "Erro natural 1 antes dos modificadores")
	var estado := Estado.new(14)
	estado.iniciar_turno()
	_verificar(estado.pa_atuais == 5, "Começo do turno: 5 PA")
	_verificar(estado.gastar_pa(3) and estado.pa_atuais == 2, "Ataque básico custa 3 PA")
	_verificar(not estado.gastar_pa(3) and estado.pa_atuais == 2, "PA insuficiente não gasta saldo")
	_verificar(estado.defender() and estado.pa_atuais == 1 and estado.bonus_defesa_temporaria == 2, "Defender custa 1 e concede 2")
	_verificar(not estado.defender() and estado.pa_atuais == 1, "Defender não se acumula consigo mesmo")
	estado.iniciar_turno()
	_verificar(estado.pa_atuais == 5 and estado.bonus_defesa_temporaria == 0, "Defender expira no início do próximo turno")
	estado.pa_debito_pendente = 1
	estado.pa_penalidade_pendente = 1
	estado.iniciar_turno()
	_verificar(estado.pa_atuais == 3, "Débito e penalidade registrados são aplicados juntos")
	var grade := Grade.new()
	_verificar(grade.COLUNAS == 6 and grade.LINHAS == 3 and grade.TAMANHO_CASA == 88.0, "Dimensões originais do tabuleiro")
	_verificar(grade.nome_casa(Vector2i.ZERO) == "A1" and grade.nome_casa(Vector2i(5, 2)) == "C6", "Casas A1 a C6")
	for total in [9, 10, 14, 15, 22]:
		var disponiveis := grade.casas_iniciais(total)
		_verificar(disponiveis.size() == (3 if total < 10 else (6 if total < 15 else 9)), "Faixa de iniciativa %d" % total)
		for casa in disponiveis:
			_verificar(casa.x < 3 and casa.x >= (2 if total < 10 else (1 if total < 15 else 0)), "Coluna permitida pelo mesmo total de iniciativa")
	grade.posicionar("Bandido", Vector2i(1, 0))
	_verificar(Vector2i(1, 0) not in grade.casas_iniciais(15), "Posicionamento inicial rejeita casa ocupada")
	grade.posicionar("Bandido", Vector2i(3, 1))
	_verificar(grade.caminho("Brokk", Vector2i(2, 0), 1).size() == 1, "Passo ortogonal")
	_verificar(grade.caminho("Brokk", Vector2i(3, 0), 1).is_empty(), "Diagonal não é movimento de uma casa")
	_verificar(grade.caminho("Brokk", Vector2i(3, 1), 2).is_empty(), "Não ocupa casa do inimigo")
	_verificar(grade.caminho("Brokk", Vector2i(4, 1), 2).is_empty(), "Corrida não atravessa casa ocupada")
	_verificar(grade.caminho("Brokk", Vector2i(3, 0), 2).size() == 2, "Corrida pode fazer dois passos ortogonais em L")
	for fora in [Vector2i(-1, 0), Vector2i(6, 0), Vector2i(0, -1), Vector2i(0, 3)]:
		_verificar(grade.caminho("Brokk", fora, 2).is_empty(), "Não sai do tabuleiro")
	grade.posicionar("Brokk", Vector2i(2, 0))
	_verificar(grade.caminho("Brokk", Vector2i(4, 0), 2).size() == 2, "Movimento pode cruzar para o lado dos inimigos")
	grade.free()
	print("Regras: Defesa, dano mínimo, PA, dimensões, faixas e caminhos conferidos.")


func _acoes_e_posicionamento() -> void:
	await _novo_combate()
	_verificar(cena.estado_brokk.pa_atuais == 5 and cena.posicionamento_concluido, "Primeiro turno só começa após escolher posição")
	var casa_antes: Vector2i = cena.grade.posicoes["Brokk"]
	var pa_antes: int = cena.estado_brokk.pa_atuais
	var invalido: bool = await cena._mover_para(casa_antes + Vector2i(1, 1))
	_verificar(not invalido and cena.estado_brokk.pa_atuais == pa_antes, "Movimento diagonal inválido não gasta PA")
	_verificar(await cena._mover_para(Vector2i(2, 0)), "Move de B3 para A3")
	_verificar(cena.estado_brokk.pa_atuais == 3, "Movimento custa 2 PA")
	_verificar(cena.sprite_brokk.position.is_equal_approx(cena.grade.position + cena.grade.centro(Vector2i(2, 0))), "Sprite acompanha a posição lógica")
	_verificar(await cena._mover_para(Vector2i(4, 0), true), "Corrida A3 para A5 pelo tabuleiro inteiro")
	_verificar(cena.estado_brokk.pa_atuais == 0, "Corrida custa 3 PA")
	var pv_alvo: int = cena.vida_bandido
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == pv_alvo and cena.texto_resultado.text.contains("PA insuficientes"), "Ataque sem PA é bloqueado com mensagem")
	cena.gerador.seed = _semente([1])
	await cena._encerrar_turno()
	_verificar(cena.estado_brokk.pa_atuais == 5 and cena.turno_atual == "Brokk", "Encerrar com 0 PA permite novo turno de 5")
	cena._defender()
	_verificar(cena.estado_brokk.pa_atuais == 4 and cena.estado_brokk.bonus_defesa_temporaria == 2, "Ação Defender na cena")
	cena.vida_brokk = 14
	cena.gerador.seed = _semente([3, 3])
	await cena._encerrar_turno()
	_verificar(cena.ultimo_ataque["defesa"] == 5 and cena.ultimo_ataque["dano_recebido"] == 0 and not cena.ultimo_ataque["erro"], "Pele + escudo + Defender absorvem acerto natural 3")
	_verificar(cena.estado_brokk.bonus_defesa_temporaria == 0, "Defender durou no turno inimigo e expirou no próximo Brokk")
	await _fechar_combate()

	await _novo_combate()
	cena._defender()
	respostas_muralha.assign([true])
	cena.gerador.seed = _semente([4])
	await cena._encerrar_turno()
	_verificar(cena.ultimo_ataque["bruto"] == 5 and cena.ultimo_ataque["defesa"] == 3 and cena.ultimo_ataque["dano"] == 2, "Pele + Defender são subtraídos uma única vez antes da reação")
	_verificar(cena.vida_brokk == 13 and cena.ultimo_ataque["dano_recebido"] == 1, "Muralha reduz o restante 2 para 1, sem reduzir o bruto novamente")
	_verificar(cena.estado_brokk.pa_atuais == 4 and cena.estado_brokk.bonus_defesa_temporaria == 0, "No próximo turno desconta reação e expira Defender")
	await _fechar_combate()

	await _novo_combate()
	_aproximar_brokk()
	respostas_mestre.assign([false])
	cena.gerador.seed = _semente([2, 4])
	await cena._atacar_com_vantagem()
	_verificar(cena.estado_brokk.pa_atuais == 0 and cena.vida_bandido == 0, "Vantagem custa 5 e usa o maior: 4 + 3 = 7")
	_verificar(cena.ultimo_ataque["natural"] == 4 and cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(4)), "Visual usa o mesmo resultado da Vantagem")
	await _fechar_combate()

	await _novo_combate()
	_aproximar_brokk()
	respostas_mestre.assign([true])
	cena.gerador.seed = _semente([6, 2, 1])
	await cena._atacar_com_vantagem()
	_verificar(cena.ultimos_dados_brokk == [1, 2] and cena.vida_bandido == 1, "Mestre repete somente o maior; novo 1 substitui 6 e maior restante é 2")
	_verificar(cena.estado_brokk.mestre_armas_usado and cena.estado_brokk.pa_atuais == 0, "Mestre continua gratuito e limitado a um uso na Vantagem")
	await _fechar_combate()
	print("Cena: movimento, corrida, PA, Defender, encerramento e Vantagem conferidos.")


func _iniciativa_e_posicao() -> void:
	await _novo_combate()
	var rng := RandomNumberGenerator.new()
	var semente := -1
	var naturais: Array[int] = []
	for candidato in range(10000):
		rng.seed = candidato
		naturais.assign([rng.randi_range(1, 20), rng.randi_range(1, 20), rng.randi_range(1, 20), rng.randi_range(1, 20)])
		if naturais[0] + 1 == naturais[1] + 1 and naturais[2] + 1 > naturais[3] + 1:
			semente = candidato
			break
	_verificar(semente >= 0, "Cenário de empate seguido de desempate")
	cena.gerador.seed = semente
	cena.iniciativa_concluida = false
	cena.posicionamento_concluido = false
	cena.turno_atual = ""
	cena.estado_brokk.pa_atuais = 0
	cena.pa_bandido = 0
	cena.visual_dado.visible = true
	cena.dado_iniciativa_brokk.visible = true
	cena.dado_iniciativa_bandido.visible = true
	await cena._rolar_iniciativa()
	_verificar(cena.total_iniciativa_brokk == naturais[2] + 1 and cena.primeiro_a_agir == "Brokk", "Empate descarta ambos e iniciativa usa DES efetiva +1")
	_verificar(cena.texto_iniciativa_brokk.text.contains("DES efetiva 1"), "Interface identifica o bônus efetivo de iniciativa")
	_verificar(cena.Dados3D.resultado_visivel(cena.dado_iniciativa_brokk) == naturais[2] and cena.Dados3D.resultado_visivel(cena.dado_iniciativa_bandido) == naturais[3], "Números 3D da iniciativa são os naturais realmente usados")
	_verificar(cena.selecionando_posicao and cena.estado_brokk.pa_atuais == 0 and cena.pa_bandido == 0, "Nenhuma ação acontece antes de confirmar posicionamento")
	for caso in [{"total": 9, "invalida": Vector2i(1, 0), "valida": Vector2i(2, 2)}, {"total": 10, "invalida": Vector2i(0, 0), "valida": Vector2i(1, 0)}, {"total": 15, "invalida": Vector2i(3, 0), "valida": Vector2i(0, 2)}]:
		cena.formacao.iniciar(cena.ordem_turnos, ["Brokk"])
		cena.grade.nao_posicionados.assign(cena.ordem_turnos)
		cena.total_iniciativa_brokk = caso["total"]
		cena.selecionando_posicao = true
		cena.posicionamento_concluido = false
		cena.turno_atual = ""
		cena.estado_brokk.pa_atuais = 0
		_verificar(not cena._confirmar_posicao(caso["invalida"]) and cena.estado_brokk.pa_atuais == 0, "Controlador bloqueia coluna inicial inválida")
		_verificar(cena._confirmar_posicao(caso["valida"]) and cena.estado_brokk.pa_atuais == 5, "Posicionamento não consome PA do primeiro turno")
		_verificar(cena.grade.posicoes["Bandido"].x == 4 and cena.grade.posicoes["Bandido"].y == caso["valida"].y, "Arqueiro mantém fileira configurada e considera escolha confirmada do herói")
	await _fechar_combate()
	print("Iniciativa: empate, naturais visuais, bloqueio inicial e seleção de posição conferidos.")


func _equipamentos_e_alcance() -> void:
	var ficha := Ficha.new()
	var machado: Dictionary = ficha.EQUIPAMENTOS["arma"]
	_verificar(machado["nome"] == "Machado de Ferro" and machado["maos"] == 1 and machado["dado"] == 6, "Machado de Ferro 1H substitui a espada")
	_verificar(Equipamentos.ARCO_CURTO["maos"] == 2 and Equipamentos.ESCUDO_MADEIRA_FERRO["maos"] == 1, "Mãos dos equipamentos")
	_verificar(ficha.atributo("DES") == 2 and ficha.atributo_efetivo("DES") == 1, "Escudo modifica apenas a DES efetiva")
	ficha.escudo_equipado = false
	_verificar(ficha.atributo_efetivo("DES") == 2 and ficha.bonus_escudo(2) == 0, "Penalidade e bônus cessam sem escudo")
	ficha.escudo_equipado = true
	_verificar(ficha.atributo("DES") == 2 and ficha.atributo_efetivo("DES") == 1, "Reequipar não acumula penalidade nem muda atributo base")
	for natural in range(1, 7):
		_verificar(ficha.bonus_arma(natural) == (2 if natural == 6 else 0), "Machado ativa bônus só no natural 6")
	_verificar(Equipamentos.bonus_dano(machado, 6, {"FOR": 1}) == 0, "Machado exige pelo menos FOR 2")
	_verificar(Equipamentos.bonus_dano(machado, 6, {"FOR": 2}) == 2, "Machado ativa exatamente no limiar FOR 2")
	_verificar(Regras.ataque_fisico(1, 3, {}, 2)["bruto"] == 0, "Natural 1 ignora bônus da arma")
	var tamanho := Vector2i(6, 3)
	var origem := Vector2i(2, 1)
	for y in range(3):
		for x in range(6):
			var alvo := Vector2i(x, y)
			var perto := alvo != origem and maxi(absi(x - origem.x), absi(y - origem.y)) == 1
			_verificar(Equipamentos.avaliar_alcance(machado, origem, alvo, tamanho)["permitido"] == perto, "Alcance corpo a corpo em todas as casas")
			_verificar(Equipamentos.avaliar_alcance(Equipamentos.ARCO_CURTO, origem, alvo, tamanho)["permitido"] == (alvo != origem), "Arco alcança qualquer outra casa válida")
	for fora in [Vector2i(-1, 0), Vector2i(6, 0), Vector2i(0, 3)]:
		_verificar(not Equipamentos.avaliar_alcance(Equipamentos.ARCO_CURTO, origem, fora, tamanho)["permitido"], "Arco não atinge fora da grade")
	var estendida := {"alcance": Equipamentos.ALCANCE_ESTENDIDO_PENDENTE}
	_verificar(not Equipamentos.avaliar_alcance(estendida, origem, Vector2i(4, 1), tamanho)["permitido"], "Alcance estendido sem definição não inventa distância")
	for deslocamento in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(2, 0)]:
		var inimigos: Array[Vector2i] = [origem + deslocamento]
		var ortogonal: bool = deslocamento in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		_verificar(Equipamentos.desvantagem_por_proximidade(Equipamentos.ARCO_CURTO, origem, inimigos) == ortogonal, "Somente proximidade ortogonal impõe Desvantagem ao arco")
		_verificar(not Equipamentos.desvantagem_por_proximidade(machado, origem, inimigos), "Machado não herda a penalidade específica do arco")
	_verificar(Regras.selecionar_natural([2, 6], "vantagem") == 6, "Vantagem usa maior")
	_verificar(Regras.selecionar_natural([6, 2], "desvantagem") == 2, "Desvantagem usa menor")
	_verificar(Regras.selecionar_natural([1, 6], "desvantagem") == 1, "1 usado pela Desvantagem é erro natural")
	_verificar(Regras.modo_rolagem(true, true) == "normal" and Regras.quantidade_dados("normal") == 1, "Vantagem e Desvantagem se anulam em um dado")
	print("Equipamentos: atributos base/efetivos, bônus, alcance e modos de rolagem conferidos.")


func _alcance_e_arco_na_cena() -> void:
	await _novo_combate()
	var pa_antes: int = cena.estado_brokk.pa_atuais
	var rng_antes: int = cena.gerador.state
	await cena._ao_atacar()
	await cena._atacar_com_vantagem()
	_verificar(cena.estado_brokk.pa_atuais == pa_antes and cena.vida_bandido == 6 and cena.gerador.state == rng_antes, "Fora do alcance bloqueia ataques normal e com Vantagem antes de PA e RNG")
	_verificar(cena.texto_resultado.text.contains("Fora do alcance") and not cena.estado_brokk.mestre_armas_usado and decisoes.is_empty(), "Fora do alcance informa motivo e não oferece/consome habilidade")
	_verificar(await cena._mover_para(Vector2i(3, 1)), "Brokk aproxima-se ortogonalmente de B3 para B4")
	_verificar(cena.estado_brokk.pa_atuais == 3 and cena.ficha_brokk.atributo_efetivo("DES") == 1, "Escudo não aumenta custo de movimento")
	_verificar(cena._modo_ataque_bandido() == "desvantagem" and cena.texto_arma_bandido.text.contains("Desvantagem"), "Movimento atualiza condição do Arco Curto na interface")
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 1 and cena.estado_brokk.pa_atuais == 0, "Após mover, Machado alcança e custa os mesmos 3 PA")
	cena.gerador.seed = _semente([6, 2])
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	await cena._executar_ataque_bandido()
	_verificar(cena.ultimos_dados_bandido == [6, 2] and cena.ultimo_ataque["natural"] == 2 and not cena.ultimo_ataque["erro"], "Arco ortogonal usa o menor de 6 e 2")
	_verificar(cena.ultimo_ataque["fontes"]["escudo"] == 2 and cena.vida_brokk == 14, "Escudo usa o natural selecionado 2; com Pele absorve dano")
	_verificar(cena.texto_dado.text.contains("6 e 2") and cena.texto_dado.text.contains("usado: 2") and cena.dado_bandido_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(2)), "Texto mostra ambos e o cubo para no natural utilizado")
	for casa in [Vector2i(4, 0), Vector2i(4, 2), Vector2i(3, 1), Vector2i(5, 1)]:
		cena.grade.posicionar("Brokk", casa)
		cena._sincronizar_sprites()
		cena.vida_brokk = 14
		cena.turno_atual = "Bandido"
		cena.pa_bandido = 5
		cena.gerador.seed = _semente([5, 1])
		await cena._executar_ataque_bandido()
		_verificar(cena.ultimo_ataque["modo"] == "desvantagem" and cena.ultimo_ataque["erro"] and cena.ultimo_ataque["natural"] == 1, "Desvantagem ortogonal em todas as quatro direções")
		_verificar(cena.vida_brokk == 14 and cena.ultimo_ataque["bruto"] == 0, "Natural 1 escolhido erra antes de bônus e Defesa")
	for casa in [Vector2i(3, 0), Vector2i(3, 2), Vector2i(5, 0), Vector2i(5, 2), Vector2i(0, 0)]:
		cena.grade.posicionar("Brokk", casa)
		cena._sincronizar_sprites()
		cena.vida_brokk = 14
		cena.turno_atual = "Bandido"
		cena.pa_bandido = 5
		cena.gerador.seed = _semente([4, 1])
		await cena._executar_ataque_bandido()
		_verificar(cena.ultimo_ataque["modo"] == "normal" and cena.ultimos_dados_bandido == [4] and cena.vida_brokk == 10, "Diagonal ou distante: arco usa só um dado e alcança Brokk")
		_verificar(cena.texto_dado.text == "D6: 4" and cena.dado_bandido_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(4)), "Arco normal mantém o resultado visual sincronizado")
	cena.grade.posicionar("Brokk", Vector2i(3, 1))
	_verificar(cena._modo_ataque_bandido(true) == "normal", "Vantagem de outra origem anula proximidade do arco")
	await _fechar_combate()

	await _novo_combate()
	_aproximar_brokk()
	cena.gerador.seed = _semente([1, 6])
	await cena._atacar_com_vantagem()
	_verificar(cena.ultimo_ataque["natural"] == 6 and cena.ultimo_ataque["bonus_arma"] == 2 and cena.ultimo_ataque["bruto"] == 11, "Maior dado da Vantagem ativa o bônus do Machado no resultado final")
	_verificar(cena.estado_brokk.pa_atuais == 0 and cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(6)), "Vantagem mantém custo e cubo final")
	await _fechar_combate()
	print("Cena: alcance antes do custo, proximidade dinâmica, Desvantagem e bônus final conferidos.")


func _lancas_e_anulacao() -> void:
	_verificar(Regras.resolver_fontes_rolagem(["habilidade"], ["proximidade"]) == "normal", "Origens diferentes se anulam")
	_verificar(Regras.resolver_fontes_rolagem(["classe", "raca"], ["condicao"]) == "normal", "Fontes não acumulam para superar anulação")
	_verificar(Regras.resolver_fontes_rolagem(["desafio_FOR"], []) == "vantagem", "Resolvedor reutilizável em desafios")
	_verificar(Regras.resolver_fontes_rolagem([], ["resistencia"]) == "desvantagem", "Resolvedor reutilizável em resistências")
	_verificar(Regras.quantidade_dados("vantagem") == 2 and Regras.quantidade_dados("desvantagem") == 2, "Efeitos isolados usam dois dados")
	_verificar(Regras.selecionar_natural([3], "normal") == 3 and Regras.selecionar_natural([3, 6], "normal") == 0, "Anulação exige somente um dado")
	var grade := Grade.new()
	grade.obstaculos.append(Vector2i(3, 1))
	_verificar(grade.caminho("Brokk", Vector2i(4, 1), 2).is_empty(), "Corrida não atravessa obstáculos")
	_verificar(not grade.posicionar("Brokk", Vector2i(3, 1)), "Não posiciona sobre obstáculo")
	_verificar(Vector2i(3, 1) not in grade.casas_movimento("Brokk", 2), "Obstáculo não aparece como destino")
	grade.obstaculos.append(Vector2i(1, 0))
	_verificar(Vector2i(1, 0) not in grade.casas_iniciais(15), "Posicionamento inicial respeita obstáculos")
	for arma in [Equipamentos.LANCA_FERRO_GRANDE, Equipamentos.LANCA_ACO_IMPERIAL]:
		_verificar(arma["maos"] == 2 and arma["tipo"] == "corpo_a_corpo" and arma["tipo_dano"] == "fisico", "Lança física de duas mãos")
		var ferro: bool = arma["dado"] == 6
		_verificar(arma["valor_coroas"] == (5 if ferro else 10) and arma["categoria"] == ("comum" if ferro else "rara"), "Valor e categoria da lança")
		for y in range(3):
			for x in range(6):
				var alvo := Vector2i(x, y)
				var distancia := maxi(absi(x - 2), absi(y - 1))
				_verificar(Equipamentos.avaliar_alcance(arma, Vector2i(2, 1), alvo, Vector2i(6, 3))["permitido"] == (distancia > 0 and distancia <= 2), "Lança usa maior diferença de linha e coluna")
		for alvo in [Vector2i(4, 0), Vector2i(4, 1), Vector2i(4, 2)]:
			_verificar(Equipamentos.avaliar_alcance(arma, grade.posicoes["Brokk"], alvo, Vector2i(6, 3))["permitido"], "B3 alcança A5/B5/C5 apesar de obstáculo intermediário")
		grade.posicoes["Intermediario"] = Vector2i(3, 1)
		_verificar(Equipamentos.avaliar_alcance(arma, grade.posicoes["Brokk"], grade.posicoes["Bandido"], Vector2i(6, 3))["permitido"], "Lança alcança através de personagem intermediário")
		_verificar(not Equipamentos.avaliar_alcance(arma, Vector2i(2, 1), Vector2i(6, 1), Vector2i(6, 3))["permitido"], "Lança respeita limites da grade")
		for natural in range(1, int(arma["dado"]) + 2):
			var ativa: bool = natural >= 6 and natural <= int(arma["dado"])
			_verificar(Equipamentos.ignora_defesa(arma, natural, {"FOR": 3, "DES": 0}) == ativa, "Lança exige natural válido e FOR 3")
			_verificar(Equipamentos.ignora_defesa(arma, natural, {"FOR": 0, "DES": 3}) == ativa, "DES 3 também habilita efeito")
			_verificar(not Equipamentos.ignora_defesa(arma, natural, {"FOR": 2, "DES": 2}), "FOR/DES abaixo de 3 nunca ignoram Defesa")
		var fontes := {"natural": 1, "escudo": 2, "temporaria": 2}
		var ignorar := Equipamentos.ignora_defesa(arma, 6, {"FOR": 3})
		var ataque := Regras.ataque_fisico(6, 3, fontes, 0, ignorar)
		_verificar(ataque["dano"] == 9 and ataque["defesa"] == 0 and ataque["defesa_calculada"] == 5 and ataque["defesa_ignorada"], "Efeito preparado ignora Defesa apenas neste ataque")
		_verificar(Regras.ataque_fisico(5, 3, fontes)["dano"] == 3 and fontes == {"natural": 1, "escudo": 2, "temporaria": 2}, "Defesas do alvo não são removidas permanentemente")
		_verificar(Regras.ataque_fisico(1, 3, fontes, 0, true)["erro"], "Ignorar Defesa não transforma erro natural em acerto")
		_verificar(arma["alcance"]["alvo_unico"] and not ataque.has("alvos") and not ataque.has("critico") and not ataque.has("pa_extra"), "Resultado individual, sem dano em área ou críticos")
	grade.free()
	_verificar(not Equipamentos.ignora_defesa(Equipamentos.MACHADO_FERRO, 6, {"FOR": 3}), "Machado não herda efeito de lança nem crítico")
	print("Lanças: cadastro, alcance, bloqueios de movimento e efeito reutilizável conferidos.")


func _anulacao_na_cena() -> void:
	await _novo_combate()
	_aproximar_brokk()
	cena.estado_brokk.fontes_desvantagem.assign(["condicao_externa"])
	cena.gerador.seed = _semente([2, 6])
	var rng := RandomNumberGenerator.new()
	rng.seed = cena.gerador.seed
	rng.randi_range(1, 6)
	await cena._atacar_com_vantagem()
	_verificar(cena.ultimo_ataque["modo"] == "normal" and cena.ultimos_dados_brokk == [2] and cena.gerador.state == rng.state, "Vantagem comprada anulada gera exatamente um dado")
	_verificar(cena.estado_brokk.pa_atuais == 0 and cena.vida_bandido == 1, "Anulação mantém custo de 5 PA e dano do natural único")
	_verificar(not cena.estado_brokk.mestre_armas_usado and not cena.estado_brokk.muralha_usada, "Anulação não consome usos de habilidades")
	_verificar(cena.texto_dado.text == "D6: 2" and cena.dado_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(2)), "Dado azul normal sincronizado após anulação")
	_verificar(cena.ficha_brokk.EQUIPAMENTOS["arma"] == Equipamentos.MACHADO_FERRO and cena.ARMA_BANDIDO == Equipamentos.ARCO_CURTO, "Lanças cadastradas não substituem equipamento atual")
	await _fechar_combate()
	await _novo_combate()
	cena.grade.posicionar("Brokk", Vector2i(3, 1))
	cena._sincronizar_sprites()
	cena.fontes_vantagem_bandido.assign(["habilidade_externa"])
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([4, 1])
	rng.seed = cena.gerador.seed
	rng.randi_range(1, 6)
	await cena._executar_ataque_bandido()
	_verificar(cena.ultimo_ataque["modo"] == "normal" and cena.ultimos_dados_bandido == [4] and cena.gerador.state == rng.state, "Habilidade externa anula Desvantagem do arco e consome só um dado")
	_verificar(cena.vida_brokk == 10 and cena.pa_bandido == 2, "Arco anulado mantém dano, Defesa e custo básico de 3 PA")
	_verificar(cena.texto_dado.text == "D6: 4" and cena.dado_bandido_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(4)), "Dado vermelho sincronizado após anulação")
	_verificar(cena.fontes_vantagem_bandido == ["habilidade_externa"], "Resolvedor não remove nem consome fonte do efeito")
	cena.fontes_vantagem_bandido.clear()
	_verificar(cena._modo_ataque_bandido() == "desvantagem", "Sem Vantagem externa, proximidade volta a impor Desvantagem")
	await _fechar_combate()
	print("Anulação na cena: um dado, animações, PA e equipamentos preservados.")


func _porrete_e_condicoes() -> void:
	var porrete := Inimigo.new("Bandido do Porrete", 8, 2, 0, Equipamentos.PORRETE)
	_verificar(porrete.pv_atuais == 8 and porrete.pv_maximos == 8 and porrete.forca == 2 and porrete.destreza == 0 and porrete.defesa == 0, "Ficha independente do Porrete")
	_verificar(porrete.arma["maos"] == 1 and porrete.arma["categoria"] == "comum" and porrete.arma["dado"] == 6 and porrete.arma["tipo_dano"] == "fisico", "Porrete comum 1H físico d6")
	for natural in range(1, 7):
		_verificar(Equipamentos.tenta_derrubar(Equipamentos.PORRETE, natural, {"FOR": 2}) == (natural == 6), "Somente natural 6 tenta Derrubado")
		_verificar(Regras.ataque_fisico(natural, 2, {})["dano"] == (0 if natural == 1 else natural + 2), "Porrete: natural 1 erra; demais somam FOR")
	_verificar(not Equipamentos.tenta_derrubar(Equipamentos.PORRETE, 6, {"FOR": 1}), "Porrete exige FOR 2")
	_verificar(not Equipamentos.tenta_derrubar(Equipamentos.MACHADO_FERRO, 6, {"FOR": 3}), "Machado não recebe Derrubado do porrete")
	for y in range(3):
		for x in range(6):
			var distancia := maxi(absi(x - 2), absi(y - 1))
			_verificar(Equipamentos.avaliar_alcance(Equipamentos.PORRETE, Vector2i(2, 1), Vector2i(x, y), Vector2i(6, 3))["permitido"] == (distancia == 1), "Porrete alcança adjacência inclusive diagonal, nunca além")
	var condicao := Condicoes.new()
	_verificar(condicao.aplicar_derrubado() == "aplicado" and condicao.derrubado, "Alvo não imune recebe Derrubado")
	_verificar(condicao.iniciar_turno() == 1 and not condicao.derrubado and condicao.iniciar_turno() == 0, "Derrubado cobra uma vez e termina no próximo turno")
	condicao.aplicar_derrubado()
	condicao.aplicar_derrubado()
	_verificar(condicao.iniciar_turno() == 2 and condicao.iniciar_turno() == 0, "Cada aplicação tem uma única cobrança")
	_verificar(condicao.aplicar_derrubado("imune") == "imune" and not condicao.derrubado and condicao.penalidade_pendente == 0, "Imunidade não registra condição nem penalidade")
	_verificar(condicao.aplicar_derrubado("resistencia_com_vantagem") == "resistencia_pendente" and not condicao.derrubado, "Armas pesadas aguardam futura resistência sem inventar teste")
	porrete.condicoes.aplicar_derrubado()
	porrete.iniciar_turno()
	_verificar(porrete.pa_atuais == 2 and not porrete.condicoes.derrubado, "Inimigo comum Derrubado começa com 2/3 PA")
	porrete.iniciar_turno()
	_verificar(porrete.pa_atuais == 3, "Penalidade não reaparece em turnos seguintes")
	var brokk := Estado.new(14)
	brokk.condicoes.aplicar_derrubado()
	brokk.pa_debito_pendente = 1
	brokk.iniciar_turno()
	_verificar(brokk.pa_atuais == 3 and not brokk.condicoes.derrubado, "Débito de reação e Derrubado são independentes")
	print("Porrete e condições: alcance, FOR, imunidade e cobrança única conferidos.")


func _tres_participantes() -> void:
	await _novo_combate(true)
	_verificar(cena.inimigos["Bandido"].pv_maximos == 6 and cena.vida_bandido == 6 and cena.inimigos["Porrete"].pv_atuais == 8, "Dois inimigos vivos: arqueiro 6 e porrete 8 PV")
	_verificar(cena.ordem_turnos.size() == 3 and cena.iniciativas.size() == 3, "Três participantes na iniciativa")
	_verificar(cena.iniciativas["Brokk"]["destreza"] == 1 and cena.iniciativas["Bandido"]["destreza"] == 1 and cena.iniciativas["Porrete"]["destreza"] == 0, "Iniciativa respeita DES efetiva com escudo e DES individuais dos inimigos")
	for id in ["Brokk", "Bandido", "Porrete"]:
		_verificar(cena.ordem_turnos.count(id) == 1 and cena.iniciativas.has(id), "Cada participante entra uma única vez na ordem")
		var iniciativa: Dictionary = cena.iniciativas[id]
		_verificar(iniciativa["total"] == iniciativa["natural"] + iniciativa["destreza"], "Iniciativa usa o próprio d20 + DES efetiva")
	for i in range(2):
		_verificar(cena.iniciativas[cena.ordem_turnos[i]]["total"] > cena.iniciativas[cena.ordem_turnos[i + 1]]["total"], "Ordem decrescente sem empates")
	_verificar(cena.Dados3D.resultado_visivel(cena.dado_iniciativa_porrete) == cena.iniciativas["Porrete"]["natural"], "Novo dado de iniciativa mostra natural próprio")
	_verificar(not cena.dado_iniciativa_porrete.visible and not cena.visual_dado.visible, "Dados de iniciativa ocultos após apresentação")
	_verificar(cena.grade.posicoes["Porrete"] != cena.grade.posicoes["Bandido"], "Inimigos em casas distintas")
	_verificar(cena.escudo_visual.get_parent() == cena.sprite_brokk and cena.porrete_visual.get_parent() == cena.sprite_porrete, "Escudo e porrete acompanham os respectivos sprites")
	await process_frame
	var paineis := [cena.inspecao.indicadores["Brokk"], cena.inspecao.indicadores["Bandido"], cena.inspecao.indicadores["Porrete"]]
	for i in range(3):
		var retangulo: Rect2 = paineis[i].get_global_rect()
		_verificar(Rect2(0, 0, 1280, 960).encloses(retangulo) and not retangulo.intersects(cena.visual_dado.get_global_rect()), "PV sobre a cabeça cabe e não cobre dados")
		for j in range(i + 1, 3):
			_verificar(not retangulo.intersects(paineis[j].get_global_rect()), "Indicadores de PV não se sobrepõem")
	# Ordem controlada para testar a alternância completa sem depender do sorteio.
	cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
	cena.historico_turnos.clear()
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 1), "Porrete": Vector2i(4, 2)}
	cena._sincronizar_sprites()
	cena._iniciar_turno_brokk()
	cena.gerador.seed = _semente([1, 1])
	await cena._encerrar_turno()
	_verificar(cena.historico_turnos == ["Brokk", "Bandido", "Porrete", "Brokk"], "Turnos seguem a ordem dos três e retornam ao jogador")
	_verificar(cena.pa_bandido == 0 and cena.inimigos["Porrete"].pa_atuais == 1 and cena.estado_brokk.pa_atuais == 5, "PA independentes: arqueiro ataca por 3, porrete move por 2 sem ataque gratuito, Brokk renova")
	_verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 2), "Porrete aproxima uma casa para atacar na diagonal")
	_verificar(cena.texto_turno.text.contains("Brokk") and cena.texto_vida_porrete.text.contains("8/8"), "Interface identifica turno e PV do segundo inimigo")
	# Empate entre quaisquer participantes descarta a rodada e repete os três.
	var rng := RandomNumberGenerator.new()
	var naturais: Array[int] = []
	var semente := -1
	for candidato in range(10000):
		rng.seed = candidato
		naturais.clear()
		for i in range(6):
			naturais.append(rng.randi_range(1, 20))
		var empate: bool = naturais[0] + 1 == naturais[1] + 1 or naturais[0] + 1 == naturais[2] or naturais[1] + 1 == naturais[2]
		if empate and naturais[3] + 1 > naturais[4] + 1 and naturais[3] + 1 > naturais[5] and naturais[4] + 1 != naturais[5]:
			semente = candidato
			break
	_verificar(semente >= 0, "Semente de empate e desempate entre três")
	cena.gerador.seed = semente
	cena.posicionamento_concluido = false
	cena.turno_atual = ""
	cena.estado_brokk.pa_atuais = 0
	for id in cena.inimigos:
		cena.inimigos[id].pa_atuais = 0
	await cena._rolar_iniciativa()
	_verificar(cena.iniciativas["Brokk"]["natural"] == naturais[3] and cena.iniciativas["Bandido"]["natural"] == naturais[4] and cena.iniciativas["Porrete"]["natural"] == naturais[5], "Empate repete os três dados sem conservar valores antigos")
	_verificar(cena.primeiro_a_agir == "Brokk" and cena.selecionando_posicao and cena.estado_brokk.pa_atuais == 0 and cena.inimigos["Porrete"].pa_atuais == 0, "Desempate preserva bloqueio até posicionamento inicial")
	await _fechar_combate()
	print("Três participantes: iniciativa, turnos, PA e interface conferidos.")


func _porrete_na_cena() -> void:
	await _novo_combate(true)
	cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(3, 2)}
	cena._sincronizar_sprites()
	for natural in range(1, 7):
		cena.vida_brokk = 14
		cena.turno_atual = "Porrete"
		cena.inimigos["Porrete"].pa_atuais = 5
		cena.gerador.seed = _semente([natural])
		await cena._executar_ataque_inimigo("Porrete")
		var esperado: int = Regras.ataque_fisico(natural, 2, {"natural": 1, "escudo": 2 if natural in [2, 3] else 0})["dano"]
		_verificar(cena.vida_brokk == 14 - esperado and cena.ultimo_ataque["atacante"] == "Porrete", "Dano do porrete mantém Defesa dinâmica")
		_verificar(cena.ultimo_ataque["natural"] == natural and cena.dado_bandido_3d.rotation.is_equal_approx(cena._orientacao_do_resultado(natural)), "Porrete usa o valor visual do dado vermelho")
		_verificar(not cena.estado_brokk.condicoes.derrubado and cena.estado_brokk.pa_atuais == 5, "Porrete não derruba Brokk nem desconta PA pela tentativa")
		if natural == 6:
			_verificar(cena.ultimo_ataque["derrubado"] == "imune" and cena.texto_resultado.text.contains("Firmeza de Rocha"), "Natural 6 anuncia imunidade ao Derrubado")
			_verificar(cena.vida_brokk == 7 and cena.ultimo_ataque["dano_recebido"] == 7, "Imunidade preserva o dano normal 8 menos Defesa 1")
	cena.vida_brokk = 14
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 5
	respostas_muralha.assign([true])
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(cena.vida_brokk == 11 and cena.estado_brokk.pa_atuais == 4 and cena.estado_brokk.muralha_usada, "Muralha funciona contra porrete: dano 7 reduzido a 3 e débito de 1 PA")
	cena.grade.posicoes["Porrete"] = Vector2i(5, 2)
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 5
	var rng: int = cena.gerador.state
	var pv: int = cena.vida_brokk
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(cena.vida_brokk == pv and cena.gerador.state == rng and cena.inimigos["Porrete"].pa_atuais == 5, "Porrete fora do alcance não rola nem causa dano ou gasta PA de ataque")
	cena.grade.posicoes["Porrete"] = Vector2i(3, 2)
	cena.inimigos["Porrete"].condicoes.aplicar_derrubado()
	cena.gerador.seed = _semente([1])
	await cena._iniciar_turno_inimigo("Porrete")
	_verificar(cena.inimigos["Porrete"].pa_atuais == 2 and not cena.inimigos["Porrete"].condicoes.derrubado, "Turno real do alvo Derrubado: 2/3 PA, insuficientes para atacar")
	await _fechar_combate()
	print("Porrete na cena: ataque, dado, Muralha, dano e imunidade conferidos.")


func _alvos_e_vitoria() -> void:
	await _novo_combate(true)
	cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
	cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(4, 2)}
	cena._sincronizar_sprites()
	_verificar(not cena._selecionar_alvo("Brokk") and not cena._selecionar_alvo("inexistente"), "Não seleciona aliado nem alvo inválido")
	cena._ao_clicar_casa(Vector2i(4, 2))
	_verificar(cena.alvo_selecionado == "Porrete", "Clique na grade seleciona o porrete")
	cena.inimigos["Porrete"].condicoes.aplicar_derrubado()
	_verificar(cena._modo_ataque_brokk() == "vantagem", "Alvo Derrubado concede Vantagem ao ataque")
	cena.estado_brokk.fontes_desvantagem.assign(["efeito_externo"])
	_verificar(cena._modo_ataque_brokk() == "normal", "Derrubado e Desvantagem de outra origem se anulam")
	cena.gerador.seed = _semente([2, 6])
	await cena._ao_atacar()
	_verificar(cena.ultimo_ataque["natural"] == 2 and cena.ultimos_dados_brokk == [2] and cena.inimigos["Porrete"].pv_atuais == 3 and cena.vida_bandido == 6, "Só o alvo escolhido recebe dano; anulação rola um dado")
	cena.estado_brokk.fontes_desvantagem.clear()
	cena._iniciar_turno_brokk()
	cena.gerador.seed = _semente([1, 2])
	await cena._ao_atacar()
	_verificar(cena.ultimo_ataque["modo"] == "vantagem" and cena.ultimo_ataque["natural"] == 2 and cena.inimigos["Porrete"].pv_atuais == 0, "Vantagem real contra Derrubado usa maior e pode derrotar alvo")
	_verificar(cena.turno_atual == "Brokk" and cena._pode_agir() and cena.vida_bandido == 6, "Combate continua quando somente um inimigo morre")
	_verificar(not cena._selecionar_alvo("Porrete") and cena.alvo_selecionado == "Bandido", "Alvo morto bloqueado; seleção passa para inimigo vivo")
	var rng: int = cena.gerador.state
	cena.turno_atual = "Porrete"
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(cena.gerador.state == rng, "Inimigo morto não executa ataque")
	cena._iniciar_turno_brokk()
	cena.historico_turnos.clear()
	cena.gerador.seed = _semente([1])
	await cena._encerrar_turno()
	_verificar(not cena.historico_turnos.has("Porrete") and cena.historico_turnos == ["Bandido", "Brokk"], "Ordem pula inimigo morto e mantém alternância dos vivos")
	cena.grade.posicoes["Bandido"] = Vector2i(4, 1)
	cena._sincronizar_sprites()
	cena.gerador.seed = _semente([6])
	await cena._ao_atacar()
	_verificar(cena.vida_bandido == 0 and cena.inimigos["Porrete"].pv_atuais == 0 and cena.turno_atual == "" and cena.botao_atacar.disabled, "Vitória somente após derrotar os dois inimigos")
	await _fechar_combate()
	print("Alvos: seleção, Derrubado, vantagem, mortos e vitória conjunta conferidos.")


func _ia_e_obstaculos() -> void:
	await _novo_combate(true)
	cena.grade.posicoes = {"Brokk": Vector2i(3, 1), "Bandido": Vector2i(4, 1), "Porrete": Vector2i(5, 2)}
	cena._sincronizar_sprites()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	await cena._mover_inimigo("Bandido")
	_verificar(cena.grade.posicoes["Bandido"] == Vector2i(4, 1) and cena.pa_bandido == 5 and cena._modo_ataque_bandido() == "desvantagem", "Arqueiro prioriza ataque disponível e preserva Desvantagem ortogonal")
	cena.grade.posicoes["Bandido"] = Vector2i(4, 1)
	cena.grade.obstaculos.assign([Vector2i(4, 0), Vector2i(4, 2), Vector2i(5, 1)])
	cena.pa_bandido = 5
	await cena._mover_inimigo("Bandido")
	_verificar(cena.grade.posicoes["Bandido"] == Vector2i(4, 1) and cena.pa_bandido == 5 and cena._modo_ataque_bandido() == "desvantagem", "Arqueiro cercado não atravessa Brokk nem obstáculos")
	cena.grade.obstaculos.clear()
	cena.grade.posicoes = {"Brokk": Vector2i(0, 0), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(5, 2)}
	cena._sincronizar_sprites()
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 5
	var origem: Vector2i = cena.grade.posicoes["Porrete"]
	await cena._mover_inimigo("Porrete")
	_verificar(cena.inimigos["Porrete"].pa_atuais == 2 and cena.grade.caminho("Porrete", origem, 2).size() == 2, "Porrete distante corre dois passos por 3 PA")
	cena.grade.posicoes["Porrete"] = Vector2i(5, 2)
	cena.grade.obstaculos.assign([Vector2i(4, 2), Vector2i(5, 1)])
	cena.inimigos["Porrete"].pa_atuais = 5
	await cena._mover_inimigo("Porrete")
	_verificar(cena.grade.posicoes["Porrete"] == Vector2i(5, 2) and cena.inimigos["Porrete"].pa_atuais == 5, "Porrete bloqueado não gasta PA nem atravessa obstáculos")
	cena.grade.obstaculos.clear()
	cena.grade.posicoes["Porrete"] = Vector2i(3, 2)
	cena.grade.posicoes["Brokk"] = Vector2i(2, 0)
	cena.inimigos["Porrete"].pa_atuais = 1
	await cena._mover_inimigo("Porrete")
	_verificar(cena.grade.posicoes["Porrete"] == Vector2i(3, 2) and cena.inimigos["Porrete"].pa_atuais == 1, "IA sem PA suficiente não se move")
	cena.estado_brokk.condicoes.aplicar_derrubado()
	cena.grade.posicoes["Brokk"] = Vector2i(4, 0)
	_verificar(cena._modo_ataque_bandido() == "normal", "Derrubado do alvo anula Desvantagem do arco")
	cena.grade.posicoes["Brokk"] = Vector2i(2, 0)
	_verificar(cena._modo_ataque_inimigo("Porrete") == "vantagem", "Vantagem contra Derrubado reutilizável por qualquer atacante")
	await _fechar_combate()
	print("IA: aproximação, corrida, prioridade de ataque, PA, ocupação e obstáculos conferidos.")


func _regras_feedback() -> void:
	for arma in [Equipamentos.MACHADO_FERRO, Equipamentos.PORRETE, Equipamentos.ARCO_CURTO, Equipamentos.LANCA_FERRO_GRANDE]:
		for natural in range(1, 7):
			var ataque := Regras.ataque_fisico(natural, 3, {"natural": 1, "escudo": 2 if natural in [2, 3] else 0}, 2 if natural == 6 else 0)
			var copia := ataque.duplicate(true)
			var plano := Efeitos.planejar(arma, ataque)
			_verificar(plano["categoria"] == arma["categoria_efeito"], "Categoria audiovisual independente da raridade da arma")
			_verificar(plano["forte"] == (natural in [5, 6]), "Somente naturais selecionados 5/6 ativam efeito forte d6")
			_verificar(plano["escudo"] == (natural in [2, 3]), "Feedback exige Defesa condicional do escudo aplicada")
			_verificar(plano["acerto"] == (natural != 1) and ataque == copia, "Planejamento visual não modifica ataque nem transforma erro em acerto")
	var sem_escudo := Regras.ataque_fisico(2, 1, {"natural": 1})
	_verificar(not Efeitos.planejar(Equipamentos.ARCO_CURTO, sem_escudo)["escudo"], "Possuir escudo visual não basta para ativar bloqueio")
	var ignorado := Regras.ataque_fisico(3, 1, {"escudo": 2}, 0, true)
	_verificar(not Efeitos.planejar(Equipamentos.PORRETE, ignorado)["escudo"], "Defesa ignorada não gera bloqueio")
	for natural in [0, 7]:
		var invalido := {"natural": natural, "erro": false}
		var plano := Efeitos.planejar(Equipamentos.ARCO_CURTO, invalido)
		_verificar(not plano["acerto"] and not plano["forte"] and not plano["disparo"], "Natural inválido não gera disparo ou acerto")
	_verificar(not Efeitos.planejar(Equipamentos.LANCA_ACO_IMPERIAL, Regras.ataque_fisico(6, 3, {}))["forte"], "Efeito forte d6 não é inventado para d8")
	for modo in ["vantagem", "desvantagem"]:
		var selecionado := Regras.selecionar_natural([6, 2], modo)
		var plano := Efeitos.planejar(Equipamentos.MACHADO_FERRO, Regras.ataque_fisico(selecionado, 3, {}))
		_verificar(plano["forte"] == (modo == "vantagem"), "Feedback usa dado selecionado, não dado descartado nem soma")
	print("Feedback: categorias, natural selecionado, erros e bloqueio condicional conferidos.")


func _feedback_na_cena() -> void:
	await _novo_combate()
	for som in Efeitos.SONS:
		var stream: AudioStream = cena.efeitos.sons[som]
		_verificar(stream != null and stream.get_length() > 0.10 and stream.get_length() < 0.30, "WAV real carregado: " + som)
		cena.efeitos._tocar(som, "impacto")
		_verificar(cena.efeitos.canais["impacto"].stream == stream and cena.efeitos.canais["impacto"].playing, "AudioStreamPlayer reproduz recurso: " + som)
	cena.efeitos.eventos.clear()
	var quantidade: int = cena.efeitos.resolucoes
	await cena._ao_atacar()
	_verificar(cena.efeitos.resolucoes == quantidade and cena.efeitos.eventos.is_empty(), "Ataque fora de alcance não reproduz feedback")
	_aproximar_brokk()
	# O 6 inicial descartado pelo Mestre nunca chega ao feedback.
	respostas_mestre.assign([true])
	cena.gerador.seed = _semente([6, 1])
	await cena._ao_atacar()
	_verificar(cena.efeitos.ultimo_feedback["acerto"] == false and not cena.efeitos.eventos.has("som:corte_forte") and cena.vida_bandido == 6, "Mestre 6 para 1 não produz acerto forte nem dano")
	cena._iniciar_turno_brokk()
	cena.efeitos.eventos.clear()
	cena.gerador.seed = _semente([5])
	var posicoes: Dictionary = cena.grade.posicoes.duplicate()
	var ordem: Array = cena.ordem_turnos.duplicate()
	await cena._ao_atacar()
	_verificar(cena.efeitos.eventos.count("som:corte_forte") == 1 and cena.efeitos.eventos.has("impacto:cortante:forte"), "Machado 5 gera um corte forte e um único som")
	_verificar(cena.ultimo_ataque["bruto"] == 8 and cena.ultimo_ataque["bonus_arma"] == 0 and cena.estado_brokk.pa_atuais == 2, "Forte visual não aumenta dano ou PA nem ativa bônus do Machado no 5")
	_verificar(cena.grade.posicoes == posicoes and cena.ordem_turnos == ordem, "Feedback não desloca casas nem muda iniciativa")
	await _fechar_combate()

	await _novo_combate()
	cena.efeitos.eventos.clear()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([2])
	var snapshots: Array[Dictionary] = []
	var resolucoes_antes: int = cena.efeitos.resolucoes
	# Durante o feedback, PV ainda são os anteriores ao impacto.
	var observar := func() -> void:
		if cena.efeitos.resolucoes > resolucoes_antes and cena.rolagem_em_andamento:
			snapshots.append({"pv": cena.vida_brokk, "natural": cena.ultimo_ataque.get("natural", 0)})
	process_frame.connect(observar)
	await cena._executar_ataque_bandido()
	process_frame.disconnect(observar)
	_verificar(cena.efeitos.eventos.count("som:escudo") == 1 and cena.efeitos.eventos.count("escudo") == 1, "Defesa real do escudo gera um único feedback metálico")
	_verificar(cena.efeitos.eventos.count("som:disparo_arco") == 1 and cena.efeitos.eventos.count("som:impacto_flecha") == 1, "Arco normal possui disparo e impacto locais separados")
	_verificar(cena.vida_brokk == 14 and cena.ultimo_ataque["defesa"] == 3 and cena.pa_bandido == 2, "Bloqueio audiovisual preserva Defesa, dano e PA")
	_verificar(not snapshots.is_empty() and snapshots[0]["pv"] == 14 and snapshots[0]["natural"] == 2, "Feedback recebe natural final antes da atualização de PV")
	cena.efeitos.eventos.clear()
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_bandido()
	_verificar(cena.efeitos.eventos.has("som:impacto_flecha_forte") and not cena.efeitos.eventos.has("escudo") and cena.vida_brokk == 8, "Flecha forte usa som distinto sem alterar dano 6")
	cena.vida_brokk = 14
	cena.ficha_brokk.escudo_equipado = false
	cena.turno_atual = "Bandido"
	cena.pa_bandido = 5
	cena.efeitos.eventos.clear()
	cena.gerador.seed = _semente([3])
	await cena._executar_ataque_bandido()
	_verificar(not cena.efeitos.eventos.has("escudo") and not cena.efeitos.eventos.has("som:escudo"), "Escudo desequipado não produz efeito apesar do natural 3")
	await _fechar_combate()

	await _novo_combate(true)
	cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
	cena.grade.posicoes = {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(5, 0), "Porrete": Vector2i(3, 2)}
	cena._sincronizar_sprites()
	cena.turno_atual = "Porrete"
	cena.inimigos["Porrete"].pa_atuais = 5
	cena.efeitos.eventos.clear()
	cena.gerador.seed = _semente([6])
	await cena._executar_ataque_inimigo("Porrete")
	_verificar(cena.efeitos.eventos.count("som:pancada_forte") == 1 and cena.efeitos.eventos.has("impacto:contundente:forte"), "Porrete usa pancada forte, não corte ou crítico")
	_verificar(cena.ultimo_ataque["derrubado"] == "imune" and cena.ultimo_ataque["dano_recebido"] == 7 and cena.vida_brokk == 7 and not cena.estado_brokk.condicoes.derrubado, "Feedback preserva dano, proeza do porrete e Firmeza de Rocha")
	await _fechar_combate()
	print("Áudio e efeitos na cena: WAVs reais, sincronização, descarte de dados e regras preservadas.")


func _interface_moderna() -> void:
	await _novo_combate(true)
	var ui: RefCounted = cena.visual_ui
	_verificar(cena.numero_rodada >= 1 and ui.ordem_visivel == cena.ordem_turnos, "Ordem visível corresponde aos três participantes vivos")
	_verificar(cena.texto_turno.text.contains("Rodada") and cena.texto_turno.text.contains("Brokk"), "Cabeçalho informa rodada real e turno do jogador")
	for id in ["Brokk", "Bandido", "Porrete"]:
		var pv: int = cena.vida_brokk if id == "Brokk" else cena.inimigos[id].pv_atuais
		var pa: int = cena.estado_brokk.pa_atuais if id == "Brokk" else cena.inimigos[id].pa_atuais
		var rotulo: Label = cena.texto_vida_brokk if id == "Brokk" else (cena.texto_vida_bandido if id == "Bandido" else cena.texto_vida_porrete)
		var barra: ProgressBar = cena.barra_vida_brokk if id == "Brokk" else (cena.barra_vida_bandido if id == "Bandido" else cena.barra_vida_porrete)
		_verificar(rotulo.text.contains("PV %d/" % pv) and rotulo.text.contains("PA %d/" % pa) and barra.value == pv and ui.pa_barras[id].value == pa, "PV/PA reais no painel de " + id)
	_verificar(cena.botao_atacar.disabled == cena._alvos_cartas_ataque().is_empty() and cena.botao_atacar.tooltip_text.contains("alcance"), "Carta permite selecionar qualquer alvo em alcance; sem alvo válido fica indisponível")
	for botao in [cena.botao_atacar, cena.botao_vantagem, cena.botao_defender, cena.botao_mover, cena.botao_correr]:
		_verificar(botao.text.contains(str(Regras.CUSTOS[botao.get_meta("acao")])) and botao.icon != null, "Ações exibem custo real e ícone local")
	_verificar(cena.botao_vantagem.tooltip_text.contains("mesmo quando"), "Interface explica custo da Vantagem anulada")
	cena.inimigos["Bandido"].pv_atuais = 3
	_verificar(cena.barra_vida_bandido.value == 3 and cena.texto_vida_bandido.text.contains("PV 3/6"), "Dano do arqueiro atualiza painel por sinal")
	cena.inimigos["Bandido"].pv_atuais = 6
	_verificar(cena.barra_vida_bandido.value == 6, "Cura do arqueiro atualiza barra imediatamente")
	cena.inimigos["Porrete"].pv_atuais = 4
	_verificar(cena.barra_vida_porrete.value == 4 and cena.texto_vida_porrete.text.contains("4/8"), "PV do porrete independentes na interface")
	cena.inimigos["Porrete"].pa_atuais = 2
	_verificar(ui.pa_barras["Porrete"].value == 2 and cena.texto_vida_porrete.text.contains("PA 2/3"), "PA inimigos atualizam por sinal")
	cena.inimigos["Porrete"].condicoes.aplicar_derrubado()
	_verificar(ui.condicoes["Porrete"].text.contains("Derrubado"), "Indicador de condição aparece na aplicação")
	cena.inimigos["Porrete"].iniciar_turno()
	_verificar(not ui.condicoes["Porrete"].text.contains("Derrubado") and ui.condicoes["Porrete"].text.contains("Defesa 0") and ui.pa_barras["Porrete"].value == 2, "Indicador desaparece ao cobrar Derrubado")
	cena._defender()
	_verificar(ui.condicoes["Brokk"].text.contains("Defender +2") and cena.botao_defender.disabled, "Defender ativo tem indicador e impede compra duplicada")
	cena._iniciar_turno_brokk()
	_verificar(not ui.condicoes["Brokk"].text.contains("Defender") and not cena.botao_defender.disabled, "Defender expira na mesma hora que seu indicador")
	cena.estado_brokk.gastar_pa(4)
	_verificar(cena.botao_mover.disabled and cena.botao_correr.disabled and cena.botao_atacar.disabled and not cena.botao_encerrar.disabled, "Disponibilidade reflete saldo real sem impedir encerrar turno")
	cena._iniciar_turno_brokk()
	_aproximar_brokk()
	cena._selecionar_alvo("Porrete")
	_verificar(cena.grade.alvo_destacado == "Porrete" and cena.visual_ui.texto_alvo.text.contains("Porrete") and cena.grade.alvo_no_alcance == cena._alvo_no_alcance(), "Seleção visual e alcance correspondem à lógica")
	cena._selecionar_alvo("Bandido")
	_verificar(cena.grade.alvo_destacado == "Bandido" and not cena.botao_atacar.disabled, "Alvo adjacente permite ataque sem alterar regras")
	var posicoes: Dictionary = cena.grade.posicoes.duplicate()
	var rng: int = cena.gerador.state
	var ataque := Regras.ataque_fisico(6, 3, {"escudo": 2}, 2)
	for j in range(3):
		cena._atualizar_interface()
	_verificar(cena.grade.posicoes == posicoes and cena.gerador.state == rng and ataque == Regras.ataque_fisico(6, 3, {"escudo": 2}, 2), "Atualização visual não move, não rola dados e não modifica cálculos")
	ui.registrar("Evento único de teste")
	var tamanho: int = ui.mensagens.size()
	ui.registrar("Evento único de teste")
	_verificar(ui.mensagens.size() == tamanho and ui.registro.text.contains("Evento único"), "Registro recebe mensagem sem duplicação consecutiva")
	for j in range(100):
		ui.registrar("Evento %d" % j)
	_verificar(ui.mensagens.size() == 80 and ui.mensagens[0] == "Evento 20" and ui.mensagens.back() == "Evento 99", "Registro limitado, em ordem cronológica")
	cena.inimigos["Bandido"].pv_atuais = 0
	_verificar(ui.condicoes["Bandido"].text == "DERROTADO" and "Bandido" not in ui.ordem_visivel and not cena._selecionar_alvo("Bandido"), "Derrotado desativado no painel, na iniciativa e na seleção")
	cena.ordem_turnos.assign(["Brokk", "Bandido", "Porrete"])
	cena.participantes_rodada.clear()
	cena.numero_rodada = 0
	cena._registrar_turno("Brokk")
	cena._registrar_turno("Porrete")
	_verificar(cena.numero_rodada == 1, "Rodada não aumenta em cada turno individual")
	cena._registrar_turno("Brokk")
	_verificar(cena.numero_rodada == 2, "Rodada acompanha o início do novo ciclo de participantes vivos")
	cena._atualizar_interface()
	_verificar(ui.proximo == "Porrete", "Próximo participante ignora inimigo morto")
	await process_frame
	var tabuleiro: Rect2 = cena.apresentacao.retangulo_grade()
	for painel in [cena.painel_brokk, cena.painel_bandido, cena.painel_porrete, ui.painel_registro]:
		_verificar(not painel.is_visible_in_tree() or not painel.get_global_rect().intersects(tabuleiro), "Painéis visíveis não cobrem casas")
	_verificar(not ui.painel_registro.get_global_rect().intersects(cena.visual_dado.get_global_rect()), "Registro não cobre dados 3D")
	_verificar(cena.botao_ficha.get_global_rect().end.y < tabuleiro.position.y - 20, "Ficha no cabeçalho não cobre os números das colunas")
	await _fechar_combate()
	print("Interface: valores reais, condições, ações, seleção, rodada, iniciativa e registro conferidos.")


func _executar() -> void:
	_modelos()
	_regras_feedback()
	_equipamentos_e_alcance()
	_lancas_e_anulacao()
	_porrete_e_condicoes()
	_defesa_pa_e_grade()
	await _mestre_armas()
	await _bandido_e_muralha()
	await _acoes_e_posicionamento()
	await _iniciativa_e_posicao()
	await _interface()
	await _alcance_e_arco_na_cena()
	await _anulacao_na_cena()
	await _tres_participantes()
	await _porrete_na_cena()
	await _alvos_e_vitoria()
	await _ia_e_obstaculos()
	await _feedback_na_cena()
	await _interface_moderna()
	# Deixa o servidor de áudio liberar o último playback, mesmo com time_scale 20.
	await create_timer(0.08, true, false, true).timeout
	print("RESULTADO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
