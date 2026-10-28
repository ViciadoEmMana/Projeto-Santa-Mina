extends RefCounted
const ARQUEIRO_VISUAL = preload("res://scenes/characters/BandidoArqueiro.tscn")
const PORRETE_VISUAL = preload("res://scenes/characters/BandidoPorrete.tscn")
const VISUAIS = {
	"Bandido Arqueiro": ARQUEIRO_VISUAL,
	"Bandido do Porrete": PORRETE_VISUAL,
	"Goblin do Porrete": preload("res://scenes/characters/GoblinPorrete.tscn"),
	"Goblin Sucata": preload("res://scenes/characters/GoblinSucata.tscn"),
	"Goblin Tiro Certo": preload("res://scenes/characters/GoblinTiroCerto.tscn"),
	"Goblin Faca Cega": preload("res://scenes/characters/GoblinFacaCega.tscn"),
	"Tripa Seca": preload("res://scenes/characters/TripaSeca.tscn"),
}
## Expande a apresentação existente para fichas e quantidades de inimigos variáveis.
var sprites: Dictionary = {}
var vidas: Dictionary = {}
var barras: Dictionary = {}
var dados: Dictionary = {}
var numeros: Dictionary = {}
var iniciativas: Dictionary = {}
var dado_extra: Node3D

func preparar(c: Node) -> void:
	sprites = {"Bandido": c.sprite_bandido, "Porrete": c.sprite_porrete}
	vidas = {"Bandido": c.texto_vida_bandido, "Porrete": c.texto_vida_porrete}
	barras = {"Bandido": c.barra_vida_bandido, "Porrete": c.barra_vida_porrete}
	dados = {"Brokk": c.dado_iniciativa_brokk, "Bandido": c.dado_iniciativa_bandido, "Porrete": c.dado_iniciativa_porrete}
	numeros = {"Brokk": c.numeros_iniciativa_brokk, "Bandido": c.numeros_iniciativa_bandido, "Porrete": c.numeros_iniciativa_porrete}
	iniciativas = {"Brokk": c.texto_iniciativa_brokk, "Bandido": c.texto_iniciativa_bandido, "Porrete": c.texto_iniciativa_porrete}
	if c.inimigos.has("Sucata"):
		c.grade.posicoes["Sucata"] = Vector2i(5, 0)
		var sprite: Sprite2D = c.sprite_bandido.duplicate()
		sprite.name = "TerceiroInimigo"
		c.add_child(sprite)
		sprites["Sucata"] = sprite
		var pai: CanvasLayer = c.texto_vida_bandido.get_parent().get_parent().get_parent()
		var painel: PanelContainer = c._criar_painel(pai, Vector2(759, 40), Vector2(177, 104))
		var coluna: VBoxContainer = c._criar_coluna(painel, c.inimigos["Sucata"].nome)
		vidas["Sucata"] = c._adicionar_label(coluna, "", 12, Color("f1e7d0"))
		barras["Sucata"] = c._adicionar_barra(coluna, Color("b84740"))
		c.visual_ui.rotulos_armas["Sucata"] = c._adicionar_label(coluna, "", 10, Color("c9c0af"))
		iniciativas["Sucata"] = c._adicionar_label(coluna, "", 9, Color("c9c0af"))
		c.visual_ui.completar_cartao("Sucata", painel, coluna)
		c.painel_bandido.position.x = 405
		c.painel_porrete.position.x = 582
		c.painel_bandido.custom_minimum_size = Vector2.ZERO
		c.painel_porrete.custom_minimum_size = Vector2.ZERO
		for id in c.inimigos:
			var card: PanelContainer = c.visual_ui.paineis[id]
			for controle in card.get_child(0).get_children():
				if controle is Label:
					controle.clip_text = true
					controle.add_theme_font_size_override("font_size", 10)
			card.size = Vector2(177, 104)
		var cubo: Node3D = c.dado_iniciativa_bandido.duplicate()
		cubo.name = "DadoIniciativaSucata"
		c.dado_iniciativa_bandido.get_parent().add_child(cubo)
		var rotulos: Array[Label3D] = []
		for filho in cubo.get_children():
			if filho is Label3D:
				rotulos.append(filho)
		dados["Sucata"] = cubo
		numeros["Sucata"] = rotulos
		var indice := 0
		for dado in dados.values():
			dado.position.x = -1.65 + indice * 1.1
			dado.scale = Vector3.ONE * 0.4
			indice += 1
	for id in c.inimigos:
		var card: PanelContainer = c.visual_ui.paineis[id]
		card.get_child(0).get_child(0).text = c.inimigos[id].nome.to_upper()
		iniciativas[id].text = "Aguardando iniciativa..."
		card.tooltip_text = "%s • %s nível %d • %s\n%s\n%s" % [c.inimigos[id].nome, c.inimigos[id].tipo, c.inimigos[id].nivel, c.inimigos[id].categoria, "; ".join(c.inimigos[id].pendencias), str(c.inimigos[id].habilidades)]
		if c.inimigos[id].arma["nome"] == "Duas Facas Cegas":
			for lado in [-1, 1]:
				var faca := Polygon2D.new()
				faca.polygon = PackedVector2Array([Vector2(8 * lado, 7), Vector2(13 * lado, 0), Vector2(14 * lado, 8)])
				faca.color = Color("b9bac0")
				sprites[id].add_child(faca)
		if c.inimigos[id].arma["nome"] == "Gancho":
			var gancho := Line2D.new()
			gancho.points = PackedVector2Array([Vector2(-10, 10), Vector2(-13, -4), Vector2(-18, -6), Vector2(-20, -2)])
			gancho.width = 2
			gancho.default_color = Color("a7a7a5")
			sprites[id].add_child(gancho)
		if int(c.inimigos[id].arma.get("quantidade_dados", 1)) > 1 and dado_extra == null:
			dado_extra = c.dado_bandido_3d.duplicate()
			dado_extra.name = "SegundoDadoAtaque"
			c.dado_bandido_3d.get_parent().add_child(dado_extra)
			dado_extra.visible = false
	# Só depois de preparar todos os clones, troca cada ficha pelo visual próprio.
	for id in c.inimigos:
		if VISUAIS.has(c.inimigos[id].nome):
			_trocar_sprite(c, id, VISUAIS[c.inimigos[id].nome])

func _trocar_sprite(c: Node, id: String, cena: PackedScene) -> void:
	var anterior: Sprite2D = sprites[id]
	var novo: Sprite2D = cena.instantiate()
	novo.position = anterior.position
	var nome_anterior := anterior.name
	c.remove_child(anterior)
	novo.name = nome_anterior
	c.add_child(novo)
	if id == "Bandido":
		c.sprite_bandido = novo
	elif id == "Porrete":
		# Preserva a âncora existente, sem arma geométrica duplicada sobre o PNG.
		c.porrete_visual.reparent(novo, false)
		c.porrete_visual.modulate.a = 0.0
		c.sprite_porrete = novo
	sprites[id] = novo
	anterior.queue_free()

func atualizar(c: Node) -> void:
	for id in c.inimigos:
		var inimigo: RefCounted = c.inimigos[id]
		vidas[id].text = "PV %d/%d • PA %d/%d" % [inimigo.pv_atuais, inimigo.pv_maximos, inimigo.pa_atuais, inimigo.pa_maximos]
		barras[id].max_value = inimigo.pv_maximos
		barras[id].value = inimigo.pv_atuais
		var estados: Array[String] = ["Defesa %d" % inimigo.defesa]
		if inimigo.habilidades.get("golpe_sujo", {}).get("ativo", false):
			estados.append("GS " + ("usado" if inimigo.golpe_sujo_usado else "disp."))
		if inimigo.condicoes.derrubado:
			estados.append("Derrubado")
		c.visual_ui.atualizar_cartao(id, inimigo.pa_atuais, inimigo.pa_maximos, inimigo.pv_atuais > 0, c.turno_atual == id, estados)
		if inimigo.habilidades.get("golpe_sujo", {}).get("ativo", false):
			c.visual_ui.condicoes[id].tooltip_text += "\nGS = Golpe Sujo: " + ("usado" if inimigo.golpe_sujo_usado else "disponível") + ". Uma vez por combate; teste DES/SAB CD 12 contra ataque corpo a corpo."
		if inimigo.habilidades.get("me_protejam", {}).get("ativo", false):
			c.visual_ui.condicoes[id].tooltip_text += "\nMe Protejam!: dano final 5+ ou fatal é transferido a um goblin vivo adjacente com mais PV, sem recalcular Defesa. Uma transferência por ataque."
		var texto := "%s • %dd%d%+d • %s" % [inimigo.arma["nome"], inimigo.arma.get("quantidade_dados", 1), inimigo.arma["dado"], inimigo.bonus_ataque, c._modo_ataque_inimigo(id).capitalize()]
		c.visual_ui.rotulos_armas[id].text = texto
		c.visual_ui.rotulos_armas[id].tooltip_text = texto + "\nDefesa %d • FOR %+d • DES %+d • %d PA máximos" % [inimigo.defesa, inimigo.forca, inimigo.destreza, inimigo.pa_maximos]

func sincronizar(c: Node) -> void:
	c.porrete_visual.visible = c.inimigos["Porrete"].pv_atuais > 0 and c.inimigos["Porrete"].arma.get("categoria_efeito", "") == "contundente"
	for id in sprites:
		var sprite: Sprite2D = sprites[id]
		sprite.position = c.grade.position + c.grade.centro(c.grade.posicoes[id])
		sprite.visible = id not in c.grade.nao_posicionados
		if sprite.has_meta("arqueiro_original") or sprite.has_meta("inimigo_original"):
			sprite.rotation = 0.0
			sprite.modulate = Color.WHITE
			sprite.call("definir_vivo", c.inimigos[id].pv_atuais > 0)
			continue
		sprite.rotation = PI / 2.0 if c.inimigos[id].pv_atuais == 0 else 0.0
		if c.inimigos[id].pv_atuais == 0:
			sprite.modulate = Color("777777")
		elif c.inimigos[id].ficha_id.begins_with("goblin"):
			sprite.modulate = Color("a5d87b")
		elif c.inimigos[id].categoria == "chefe":
			sprite.modulate = Color("d6c466")

func animar_rolagem(c: Node, arma: Dictionary, rolagem: Dictionary, modo: String) -> void:
	var multi: bool = not rolagem["natural_unico"]
	c.Dados3D.configurar(c.dado_bandido_3d, arma["dado"], Color("a13538"))
	if dado_extra != null:
		c.Dados3D.configurar(dado_extra, arma["dado"], Color("a13538"))
	c.dado_bandido_3d.position.x = -0.95 if multi else 0.0
	c.dado_bandido_3d.scale = Vector3.ONE * (0.75 if multi else 1.0)
	if dado_extra != null:
		dado_extra.visible = multi
		dado_extra.position.x = 0.95
		dado_extra.scale = Vector3.ONE * 0.75
	for grupo in rolagem["grupos"]:
		for j in range(grupo.size()):
			var dado: Node3D = c.dado_bandido_3d if j == 0 else dado_extra
			c.texto_dado.text = "Rolando d%d: %d..." % [arma["dado"], j + 1]
			await c._animar_dado(dado, grupo[j])
	var escolhidos: Array = rolagem["selecionados"]
	c.dado_bandido_3d.rotation = c.Dados3D.orientacao(c.dado_bandido_3d, escolhidos[0])
	if multi:
		dado_extra.rotation = c.Dados3D.orientacao(dado_extra, escolhidos[1])
		c.texto_dado.text = "2d4: %d + %d = %d (%s)" % [escolhidos[0], escolhidos[1], rolagem["total"], modo]
	else:
		c.texto_dado.text = "D%d: %d" % [arma["dado"], rolagem["total"]]
		if rolagem["totais"].size() == 2:
			c.texto_dado.text = "%s: %d e %d | usado: %d" % [modo.capitalize(), rolagem["totais"][0], rolagem["totais"][1], rolagem["total"]]
