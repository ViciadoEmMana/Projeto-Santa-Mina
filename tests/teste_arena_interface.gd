extends "res://tests/teste_brokk.gd"
## Eventos reais de mouse; inspeção nunca decide ações ou modifica a ficha.
const SistemaArena = preload("res://sistema_campanha.gd")

func _mouse(ponto: Vector2) -> void:
	var evento := InputEventMouseMotion.new()
	evento.position = ponto
	evento.global_position = ponto
	root.push_input(evento, true)
	await process_frame
	await process_frame

func _clique(ponto: Vector2) -> void:
	await _mouse(ponto)
	for pressionado in [true, false]:
		var evento := InputEventMouseButton.new()
		evento.position = ponto
		evento.global_position = ponto
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.pressed = pressionado
		root.push_input(evento, true)
		await process_frame
	await process_frame

func _medidas() -> void:
	var grade: Rect2 = cena.apresentacao.retangulo_grade()
	_verificar(grade.size.is_equal_approx(Vector2(792, 396)), "Arena ampliada 50%, com as mesmas 18 casas")
	_verificar(cena.grade.COLUNAS == 6 and cena.grade.LINHAS == 3 and cena.grade.TAMANHO_CASA == 88, "Geometria lógica original preservada")
	_verificar(cena.grade.get_parent() == cena.sprite_brokk.get_parent() and cena.efeitos.get_parent() == cena.sprite_brokk.get_parent(), "Grade, atores e efeitos compartilham o transform visual")
	_verificar(cena.cenario.fundo.get_global_rect().encloses(Rect2(Vector2.ZERO, Vector2(1280, 960))), "Fundo continua cobrindo a tela ampliada")
	_verificar(cena.visual_dado.size.x >= 320 and cena.visual_dado.size.y >= 120, "Área real de renderização do dado não fica vazia")
	_verificar(cena.visual_dado.get_global_rect().position.is_equal_approx(cena.apresentacao.espaco_dado.get_global_rect().position), "Viewport 3D acompanha a posição do espaço reservado")
	for area in [cena.visual_dado.get_global_rect(), cena.apresentacao.area_detalhes.get_global_rect(), cena.barra_cartas.get_global_rect()]:
		_verificar(not grade.intersects(area), "Dados, inspeção/registro e cartas ficam fora do tabuleiro")
	for id in cena.visual_ui.paineis:
		_verificar(not cena.visual_ui.paineis[id].is_visible_in_tree(), "Nenhum quadro permanente de personagem: " + id)
	for id in cena.inspecao.indicadores:
		var marcador: Control = cena.inspecao.indicadores[id]
		_verificar(marcador.is_visible_in_tree() and marcador.size.x == 86, "PV legível sobre personagem: " + id)
		_verificar(Rect2(0, 0, 1280, 960).encloses(marcador.get_global_rect()), "PV dentro da tela: " + id)
		_verificar(not marcador.get_global_rect().intersects(cena.barra_cartas.get_global_rect()), "PV não cobre cartas: " + id)

func _inspecionar() -> void:
	var pa: int = cena.estado_brokk.pa_atuais
	var rng: int = cena.gerador.state
	var posicoes: Dictionary = cena.grade.posicoes.duplicate()
	var hp: int = cena.vida_brokk
	for id in ["Brokk", "Bandido", "Porrete"]:
		await _mouse(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes[id])))
		_verificar(cena.inspecao.exibido == id and cena.visual_ui.paineis[id].is_visible_in_tree(), "Hover mostra a ficha correspondente: " + id)
		_verificar(not cena.visual_ui.painel_registro.visible, "Inspeção usa somente a área lateral")
		for outro in cena.visual_ui.paineis:
			_verificar(cena.visual_ui.paineis[outro].visible == (outro == id), "Somente uma ficha é exibida: " + outro)
		var cartao: Control = cena.visual_ui.paineis[id]
		for filho in cartao.get_child(0).get_children():
			if filho is Label and filho.visible:
				_verificar(not filho.clip_text and filho.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Textos de inspeção quebram linha sem corte")
		await _mouse(Vector2(10, 10))
		_verificar(cena.inspecao.exibido == "" and cena.visual_ui.painel_registro.visible, "Sair do hover restaura o registro")
	await _clique(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Bandido"])))
	await _mouse(Vector2(10, 10))
	_verificar(cena.inspecao.fixado == "Bandido" and cena.inspecao.exibido == "Bandido" and cena.alvo_selecionado == "Bandido", "Clique seleciona alvo e fixa sua ficha")
	_verificar(cena.inspecao.atributos["Bandido"].text.contains("FOR") and cena.inspecao.atributos["Bandido"].text.contains("Defesa"), "Inspeção inimiga contém atributos e Defesa")
	await _clique(cena.inspecao.botao_fechar.get_global_rect().get_center())
	_verificar(cena.inspecao.exibido == "" and cena.visual_ui.painel_registro.visible, "Fechar devolve o registro sem modal")
	await _clique(cena.inspecao.indicadores["Brokk"].get_global_rect().get_center())
	await _mouse(Vector2(10, 10))
	_verificar(cena.inspecao.fixado == "Brokk" and cena.inspecao.exibido == "Brokk", "Clique no PV seleciona o dono da barra")
	_verificar(cena.inspecao.atributos["Brokk"].text.contains("CON +3") and cena.inspecao.habilidades["Brokk"].text.contains("Muralha"), "Ficha resumida e habilidades de Brokk disponíveis")
	_verificar(cena.estado_brokk.pa_atuais == pa and cena.gerador.state == rng and cena.grade.posicoes == posicoes and cena.vida_brokk == hp, "Inspecionar e selecionar não gastam PA, dados, PV ou movimento")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	await process_frame
	_verificar(cena.inspecao.fixado == "" and cena.inspecao.exibido == "" and cena.visual_ui.painel_registro.visible, "Esc fecha a inspeção pela rota real de entrada")

func _acoes_reais() -> void:
	_aproximar_brokk()
	cena.estado_brokk.mestre_armas_usado = true
	cena.gerador.seed = _semente([2])
	await cena._ao_atacar()
	await process_frame
	_verificar(cena.ultimo_ataque["natural"] == 2 and cena.ultimo_ataque["dano"] == 5 and cena.estado_brokk.pa_atuais == 2, "Ataque conserva natural, dano e custo")
	_verificar(cena.inspecao.barras["Bandido"].value == 1 and cena.inspecao.numeros["Bandido"].text == "1/6", "PV sobre inimigo acompanha dano real")
	_verificar(cena.Dados3D.resultado_visivel(cena.dado_3d) == 2, "Dado visual segue o resultado real")
	cena.vida_brokk = 8
	_verificar(cena.inspecao.barras["Brokk"].value == 8, "PV reage imediatamente ao sinal do estado")
	await process_frame
	_verificar(cena.inspecao.barras["Brokk"].value == 8 and cena.inspecao.numeros["Brokk"].text == "8/14", "PV de Brokk acompanha o estado atual")
	await _clique(cena.botao_mover.get_global_rect().get_center())
	_verificar(cena.modo_movimento == "mover", "Carta Mover continua recebendo clique")
	var destino: Vector2i = cena.grade.posicoes["Brokk"] + Vector2i.LEFT
	await _clique(cena.grade.to_global(cena.grade.centro(destino)))
	for i in range(2000):
		await process_frame
		if not cena.movimento_em_andamento:
			break
	_verificar(cena.grade.posicoes["Brokk"] == destino and cena.estado_brokk.pa_atuais == 0, "Clique na grade ampliada move à casa correta e cobra 2 PA")
	await process_frame # Indicador segue o ator no processamento do quadro.
	var altura := -45 if cena.ficha_brokk.ID == "zeno" else -40
	var esperado: Vector2 = cena.sprite_brokk.to_global(Vector2(0, altura)) - Vector2(43, 30)
	_verificar(cena.inspecao.indicadores["Brokk"].position.is_equal_approx(esperado.round()), "Barra acompanha o personagem após deslocamento")
	_verificar(not cena.botao_encerrar.disabled, "Encerrar turno permanece acessível")

func _quarto_participante(fechar_ao_terminar: bool = true) -> void:
	var c := SistemaArena.new()
	c.capitulo = 3
	c.iniciar_confronto()
	cena = load("res://Combate.tscn").instantiate()
	cena.inimigos = c.inimigos_atuais
	# Teste só de apresentação: a formação real é concluída antes de inspecionar.
	cena.semente_inicial = _semente_primeiro_turno()
	root.add_child(cena)
	for i in range(3000):
		await process_frame
		if cena.selecionando_posicao:
			cena._confirmar_posicao(Vector2i(2, 1))
		if cena._pode_agir():
			break
	await _mouse(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Sucata"])))
	_verificar(cena.inspecao.indicadores.size() == 4 and cena.inspecao.exibido == "Sucata", "Capítulo IV: hover alcança o quarto participante")
	_verificar(cena.inspecao.atributos["Sucata"].text.contains("Defesa 2"), "Defesa real da Sucata disponível na inspeção")
	await _mouse(cena.grade.to_global(cena.grade.centro(cena.grade.posicoes["Bandido"])))
	_verificar(cena.inspecao.habilidades["Bandido"].text.contains("Golpe Sujo") and cena.inspecao.habilidades["Bandido"].text.contains("Me Protejam!"), "Inspeção do chefe preserva ambas as habilidades")
	await _mouse(Vector2(10, 10))
	if fechar_ao_terminar:
		await _fechar_combate()

func _executar() -> void:
	await _novo_combate(true)
	await _mouse(Vector2(10, 10))
	_medidas()
	await _inspecionar()
	await _acoes_reais()
	await _fechar_combate()
	await _quarto_participante()
	print("RESULTADO ARENA: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
