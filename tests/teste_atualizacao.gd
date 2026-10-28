extends "res://tests/teste_campanha.gd"
const Formacao = preload("res://formacao_inicial.gd")
const Grade = preload("res://grade_combate.gd")
const Trajeto = preload("res://trajetoria_arco.gd")
const Geometria = preload("res://geometria_dados.gd")
const Dados3D = preload("res://dado_poliedrico.gd")

func _geometrias() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var estado_rng := rng.state
	for tipo in Geometria.TIPOS:
		var faces := Geometria.faces(tipo)
		verificar(faces.size() == tipo, "Quantidade real de faces: d%d" % tipo)
		var dado := Node3D.new()
		root.add_child(dado)
		var numeros := Dados3D.configurar(dado, tipo, Color.BLUE)
		verificar(numeros.size() == tipo and dado.get_node("Cubo").mesh is ArrayMesh, "Malha real e um número por face")
		for i in range(faces.size()):
			var face: Dictionary = faces[i]
			verificar(face["vertices"].size() == (5 if tipo == 12 else (4 if tipo in [6, 10] else 3)), "Polígono correto de cada sólido")
			for ponto in face["vertices"]:
				verificar(absf((ponto - face["centro"]).dot(face["normal"])) < 0.0001, "Face plana; número não flutua")
			verificar(numeros[i].text == str(i + 1) and numeros[i].position.distance_to(face["centro"]) < 0.01, "Número próprio centralizado sobre sua face")
			var raio := 10.0
			for j in range(face["vertices"].size()):
				var aresta: Vector3 = face["vertices"][(j + 1) % face["vertices"].size()] - face["vertices"][j]
				raio = minf(raio, aresta.cross(face["centro"] - face["vertices"][j]).length() / aresta.length())
			var texto := ThemeDB.fallback_font.get_string_size(numeros[i].text, HORIZONTAL_ALIGNMENT_LEFT, -1, 84) + Vector2.ONE * 8
			verificar(texto.length() / 2.0 * numeros[i].pixel_size <= raio * 0.9, "Número e contorno cabem integralmente na face")
			verificar(numeros[i].get_parent() == dado and numeros[i].scale.is_equal_approx(Vector3.ONE), "Número preso ao sólido, sem espelhamento por escala")
			dado.rotation = Dados3D.orientacao(dado, i + 1)
			verificar(Dados3D.resultado_visivel(dado) == i + 1, "Resultado visual exato d%d: %d" % [tipo, i + 1])
			var base: Basis = dado.basis * numeros[i].basis
			verificar(base.x.dot(Vector3.RIGHT) > 0.85 and base.y.dot(Vector3.UP) > 0.97 and base.determinant() > 0.99, "Número final não espelhado nem invertido; pose mostra volume")
		dado.queue_free()
		await process_frame
	verificar(rng.state == estado_rng, "Geometria e orientação não sorteiam novamente")
	print("Poliedros: geometria, faces, números, orientação e RNG conferidos.")

func _formacoes() -> void:
	var grade := Grade.new()
	var f := Formacao.new()
	f.iniciar(["Goblin", "Brokk", "Arco"], ["Brokk"])
	grade.posicoes["Brokk"] = Vector2i(0, 0)
	var casa := f.escolher(grade, Criaturas.CLAVA)
	verificar(casa == Vector2i(3, 1), "Primeiro inimigo usa área pública, sem conhecer futuro herói")
	f.confirmar("Goblin", casa)
	f.confirmar("Brokk", Vector2i(2, 2))
	verificar(f.escolher(grade, Criaturas.ARCO_PODRE, 3) == Vector2i(5, 2), "Arqueiro prefere terceira fileira configurada")
	f.iniciar(["Brokk", "G1", "G2", "G3"], ["Brokk"])
	f.confirmar("Brokk", Vector2i(2, 2))
	var usadas: Array[Vector2i] = []
	for id in ["G1", "G2", "G3"]:
		casa = f.escolher(grade, Criaturas.CLAVA)
		verificar(casa.x == 3 and casa not in usadas, "Todos os melees na frente, sem sobreposição")
		usadas.append(casa)
		f.confirmar(id, casa)
	verificar(usadas[0] == Vector2i(3, 2), "Inimigo posterior considera posição real do herói")
	f.iniciar(["H1", "H2", "G"], ["H1", "H2"])
	f.confirmar("H1", Vector2i(0, 0))
	f.confirmar("H2", Vector2i(2, 2))
	verificar(f.escolher(grade, Criaturas.CLAVA) == Vector2i(3, 2), "Formação suporta mais de um herói")
	grade.obstaculos.assign([Vector2i(3, 2)])
	verificar(f.escolher(grade, Criaturas.CLAVA) == Vector2i(3, 1), "Obstáculo exclui casa mais próxima")
	grade.obstaculos.assign([Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2)])
	verificar(f.escolher(grade, Criaturas.CLAVA) == Vector2i(-1, -1), "Não coloca melee fora da fileira permitida")
	grade.obstaculos.clear()
	f.iniciar(["A1", "A2", "A3", "A4"], ["Brokk"])
	for id in ["A1", "A2", "A3"]:
		casa = f.escolher(grade, Criaturas.ARCO_PODRE, 2)
		verificar(casa.x == 4, "Arqueiro usa preferência de segunda fileira")
		f.confirmar(id, casa)
	verificar(f.escolher(grade, Criaturas.ARCO_PODRE, 2).x == 5, "Fileira cheia procura alternativa válida")
	f.iniciar(["Brokk", "Goblin"], ["Brokk"])
	f.confirmar("Brokk", Vector2i(0, 0))
	grade.obstaculos.assign([Vector2i(2, 0), Vector2i(2, 1)])
	verificar(f.escolher(grade, Criaturas.CLAVA) == Vector2i(3, 2), "Melee minimiza caminho real contornando paredes, não só proximidade")
	grade.free()

func _trajetorias() -> void:
	var posicoes := {"Arco": Vector2i(5, 1), "Alvo": Vector2i(0, 1), "Perto": Vector2i(4, 1), "Longe": Vector2i(3, 1), "Fora": Vector2i(4, 0)}
	var vivos: Array[String] = ["Arco", "Alvo", "Perto", "Longe", "Fora"]
	var paredes: Array[Vector2i] = []
	var inter := Trajeto.primeiro(posicoes["Arco"], posicoes["Alvo"], posicoes, vivos, paredes)
	verificar(inter.get("id") == "Perto", "Primeiro personagem na trajetória, não o mais perto do alvo")
	for natural in range(1, 7):
		verificar(Trajeto.ativar(Equipamentos.ARCO_CURTO, natural, inter) == (natural in [1, 2]), "Fogo amigo somente natural 1/2 com interceptador")
		verificar(not Trajeto.ativar(Criaturas.CLAVA, natural, inter), "Não aplica a armas não especificadas")
	vivos.erase("Perto")
	verificar(Trajeto.primeiro(posicoes["Arco"], posicoes["Alvo"], posicoes, vivos, paredes).get("id") == "Longe", "Morto não intercepta")
	paredes.append(Vector2i(4, 1))
	verificar(Trajeto.primeiro(posicoes["Arco"], posicoes["Alvo"], posicoes, vivos, paredes).get("obstaculo", false), "Obstáculo anterior bloqueia trajetória")
	verificar(Trajeto.na_linha(Vector2i(0, 0), Vector2i(4, 2), Vector2i(2, 1)), "Alinhamento oblíquo exato")
	verificar(not Trajeto.na_linha(Vector2i(0, 0), Vector2i(4, 2), Vector2i(1, 1)), "Proximidade à linha não é alinhamento")
	verificar(Trajeto.na_linha(Vector2i(0, 0), Vector2i(2, 2), Vector2i(1, 1)), "Linha diagonal")
	verificar(not Trajeto.na_linha(Vector2i(0, 0), Vector2i(2, 2), Vector2i(3, 3)), "Exclui personagem atrás do alvo")
	verificar(not Trajeto.ativar(Equipamentos.ARCO_CURTO, 1, {}), "Sem interceptador mantém erro normal")
	verificar(not Trajeto.ativar({"tipo": "distancia", "categoria_efeito": "projetil"}, 1, inter), "Magia/projétil não cadastrado como arco não recebe fogo amigo")
	verificar(Trajeto.atravessa_obstaculo(Vector2i(0, 0), Vector2i(5, 2), Vector2i(1, 0)), "Parede bloqueia interior da casa, mesmo sem centro colinear")
	verificar(not Trajeto.atravessa_obstaculo(Vector2i(0, 0), Vector2i(5, 2), Vector2i(2, 2)), "Parede fora da trajetória não bloqueia")

func _semente_sequencia(valores: Array[int]) -> int:
	var rng := RandomNumberGenerator.new()
	for candidato in range(100000):
		rng.seed = candidato
		var valido := true
		for valor in valores:
			if rng.randi_range(1, 6) != valor:
				valido = false
		if valido:
			return candidato
	return -1

func _fogo_amigo_real() -> void:
	for natural in [1, 2]:
		for dano in range(1, 7):
			await _encontro(Sistema.new())
			cena.grade.posicoes = {"Brokk": Vector2i(0, 1), "Bandido": Vector2i(5, 1), "Porrete": Vector2i(3, 1)}
			cena.inimigos["Porrete"].defesa = 2
			cena.ordem_turnos.assign(["Brokk", "Bandido"])
			cena.turno_atual = "Bandido"
			cena.pa_bandido = 3
			cena._sincronizar_sprites()
			cena.gerador.seed = _semente_sequencia([natural, dano])
			var antes: int = cena.efeitos.resolucoes
			await cena._executar_ataque_inimigo("Bandido")
			verificar(cena.ultimo_ataque["fogo_amigo"] and cena.ultimo_ataque["alvo_dano"] == "Porrete", "Inimigo desvia para aliado na trajetória")
			verificar(cena.vida_brokk == 14 and cena.inimigos["Porrete"].pv_atuais == 8 - maxi(0, dano + 1 - 2), "Só interceptador recebe dano; Defesa uma vez")
			verificar(not cena.ultimo_ataque["erro"] and cena.ultimo_ataque["dados_dano"] == [dano], "Novo dado é dano; 1 não cria um segundo erro")
			verificar(cena.pa_bandido == 0 and cena.efeitos.resolucoes == antes + 1 and not cena.estado_brokk.muralha_usada, "Um ataque, 3 PA, sem reação do alvo não atingido")
			verificar(Dados3D.resultado_visivel(cena.dado_bandido_3d) == dano, "Dado vermelho mostra dano realmente usado")
			await _fechar()
	for natural in [1, 2, 3]:
		await _encontro(Sistema.new())
		cena.ficha_brokk.arma_equipada = Equipamentos.ARCO_CURTO.duplicate(true)
		cena.grade.posicoes = {"Brokk": Vector2i(0, 1), "Bandido": Vector2i(5, 1), "Porrete": Vector2i(2, 1)}
		cena.inimigos["Porrete"].defesa = 2
		cena.estado_brokk.mestre_armas_usado = true
		cena.alvo_selecionado = "Bandido"
		cena.gerador.seed = _semente_sequencia([natural, 6])
		await cena._ao_atacar()
		verificar(cena.ultimo_ataque["fogo_amigo"] == (natural in [1, 2]), "Fogo amigo vale para arqueiro jogador")
		verificar(cena.estado_brokk.pa_atuais == 2, "Jogador paga somente 3 PA")
		if natural in [1, 2]:
			verificar(cena.vida_bandido == 6 and cena.inimigos["Porrete"].pv_atuais == 3 and Dados3D.resultado_visivel(cena.dado_3d) == 6, "Jogador usa DES, atinge interceptador e mantém visual exato")
		else:
			verificar(cena.inimigos["Porrete"].pv_atuais == 8 and cena.vida_bandido == 2, "Natural 3 não ativa fogo amigo")
		await _fechar()
	# Sem interceptador: 1 continua erro; 2 acerta normalmente, sem segundo dado.
	for natural in [1, 2]:
		await _encontro(Sistema.new())
		cena.ficha_brokk.arma_equipada = Equipamentos.ARCO_CURTO.duplicate(true)
		cena.estado_brokk.mestre_armas_usado = true
		cena.grade.posicoes = {"Brokk": Vector2i(0, 1), "Bandido": Vector2i(5, 1), "Porrete": Vector2i(2, 0)}
		cena.gerador.seed = _semente_dado(6, natural)
		await cena._ao_atacar()
		verificar(not cena.ultimo_ataque["fogo_amigo"] and cena.vida_bandido == (6 if natural == 1 else 3), "Sem interceptador preserva erro 1/acerto 2 do arco")
		await _fechar()
	await _encontro(Sistema.new())
	cena.ficha_brokk.arma_equipada = Equipamentos.ARCO_CURTO.duplicate(true)
	cena.grade.posicoes = {"Brokk": Vector2i(0, 0), "Bandido": Vector2i(5, 2), "Porrete": Vector2i(4, 0)}
	cena.grade.obstaculos.assign([Vector2i(1, 0)])
	var estado_antes: int = cena.gerador.state
	await cena._ao_atacar()
	verificar(cena.estado_brokk.pa_atuais == 5 and cena.gerador.state == estado_antes and cena.vida_bandido == 6, "Parede impede disparo sem PA ou rolagem")
	await _fechar()

func _executar() -> void:
	await _geometrias()
	_formacoes()
	_trajetorias()
	await _fogo_amigo_real()
	await _interface_e_formacao_reais()
	await create_timer(0.1, true, false, true).timeout
	print("RESULTADO ATUALIZAÇÃO: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)

func _interface_e_formacao_reais() -> void:
	for capitulo in range(4):
		var c := Sistema.new()
		c.capitulo = capitulo
		await _encontro(c)
		verificar(cena.formacao.confirmadas.keys() == cena.ordem_turnos, "Ordem real da iniciativa é ordem da escolha")
		var usadas: Array[Vector2i] = [cena.grade.posicoes["Brokk"]]
		for id in cena.inimigos:
			var casa: Vector2i = cena.grade.posicoes[id]
			verificar(casa.x >= 3 and casa.x <= 5 and casa not in usadas and casa not in cena.grade.obstaculos, "Formação real respeita área e ocupação")
			var corpo: bool = cena.inimigos[id].arma.get("tipo") != "distancia"
			verificar(casa.x == (3 if corpo else cena.inimigos[id].fileira_preferida + 2), "Criatura real começa na fileira definida")
			verificar(cena.inimigos[id].pa_atuais == 0, "Escolha inicial não concede PA nem inicia turno extra")
			usadas.append(casa)
		verificar(cena.estado_brokk.pa_atuais == 5 and cena.historico_turnos == ["Brokk"], "Posicionamento não conta como rodada de ações")
		var retangulos: Array[Rect2] = [cena.apresentacao.retangulo_grade(), cena.apresentacao.area_detalhes.get_global_rect(), cena.visual_dado.get_global_rect(), cena.barra_cartas.get_global_rect()]
		for painel in cena.visual_ui.paineis.values():
			verificar(not painel.is_visible_in_tree(), "Fichas não ocupam o topo nem cobrem o tabuleiro")
		for i in range(retangulos.size()):
			verificar(Rect2(0, 0, 1280, 960).encloses(retangulos[i]), "Área essencial dentro da interface")
			for j in range(i + 1, retangulos.size()):
				verificar(not retangulos[i].intersects(retangulos[j]), "Painéis, cartas, dados e tabuleiro não se cobrem")
		verificar(cena.visual_ui.painel_registro.size.y >= 250 and cena.visual_ui.registro.get_theme_font_size("normal_font_size") >= 16, "Registro maior e fonte legível")
		await _fechar()
