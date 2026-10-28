extends RefCounted
const Ficha = preload("res://ficha_zeno.gd")
const Estado = preload("res://estado_combate_zeno.gd")
const Inventario = preload("res://inventario.gd")
const Alimentos = preload("res://efeitos_alimentares.gd")
const Criaturas = preload("res://catalogo_criaturas.gd")
const Capitulos = preload("res://capitulos_campanha.gd")
const Descanso = preload("res://sistema_descanso.gd")
const Comidas = preload("res://catalogo_consumiveis.gd")

var ficha_brokk: RefCounted
var estado_brokk: RefCounted
var inventario: RefCounted
var alimentos: RefCounted
var capitulo := 0
var fase := "exploracao"
var localizacao := "Estrada"
var turno_exploracao := 0
var fim_turno_exploracao := false
var recompensas_recebidas: Dictionary = {}
var ultima_recompensa := ""
var inimigos_atuais: Dictionary = {}
var batalha_vencida := false

func _init() -> void:
	reiniciar()

func reiniciar() -> void:
	ficha_brokk = Ficha.new()
	estado_brokk = Estado.new(ficha_brokk.pv_maximos())
	inventario = Inventario.new()
	alimentos = Alimentos.new()
	capitulo = 0
	fase = "exploracao"
	localizacao = "Estrada"
	turno_exploracao = 0
	fim_turno_exploracao = false
	recompensas_recebidas.clear()
	ultima_recompensa = ""
	inimigos_atuais.clear()
	batalha_vencida = false
	# Provisões de TESTE configuráveis: a quantidade inicial oficial não foi definida.
	for id in Comidas.ITENS:
		inventario.adicionar_comida(id)

func dados_capitulo() -> Dictionary:
	return Capitulos.CAPITULOS[capitulo]

func criar_inimigos() -> Dictionary:
	var resultado := {}
	var ids := ["Bandido", "Porrete", "Sucata"]
	var fichas: Array = dados_capitulo()["inimigos"]
	for i in range(fichas.size()):
		resultado[ids[i]] = Criaturas.criar(fichas[i])
	return resultado

func iniciar_confronto() -> bool:
	if fase != "exploracao" or estado_brokk.pv_atuais <= 0:
		return false
	fase = "combate"
	estado_brokk.iniciar_combate()
	estado_brokk.pa_atuais = 0
	inimigos_atuais = criar_inimigos()
	batalha_vencida = false
	localizacao = dados_capitulo()["local"]
	fim_turno_exploracao = false
	return true

func concluir_confronto(vitoria: bool) -> bool:
	if fase != "combate":
		return false
	if not vitoria or estado_brokk.pv_atuais <= 0:
		estado_brokk.encerrar_combate()
		fase = "derrota"
		return true
	if inimigos_atuais.is_empty():
		return false
	for inimigo in inimigos_atuais.values():
		if inimigo.pv_atuais > 0:
			return false
	batalha_vencida = true
	estado_brokk.encerrar_combate()
	conceder_recompensas()
	fase = "final" if capitulo == 3 else "vitoria"
	return true

func conceder_recompensas() -> bool:
	if fase != "combate" or not batalha_vencida or recompensas_recebidas.has(capitulo):
		return false
	var itens: Array[String] = []
	for id in dados_capitulo()["inimigos"]:
		var ficha: Dictionary = Criaturas.FICHAS[id]
		if ficha.has("drop"):
			inventario.adicionar_equipamento(ficha["drop"])
			inventario.adicionar_coroas(ficha["coroas"])
			itens.append("%s e %d coroas" % [ficha["drop"], ficha["coroas"]])
	if capitulo == 3:
		inventario.adicionar_equipamento("Espada de Ferro")
		inventario.adicionar_equipamento("Arco Curto")
		inventario.adicionar_especial("Porção Comum")
		itens.append("Espada de Ferro, Arco Curto e 1 Porção Comum (efeito pendente)")
	recompensas_recebidas[capitulo] = true
	ultima_recompensa = "\n".join(itens) if not itens.is_empty() else "Os bandidos não têm drops definidos. Nenhuma recompensa inventada."
	return true

func avancar_capitulo() -> bool:
	if fase != "vitoria" or capitulo >= 3:
		return false
	capitulo += 1
	fase = "exploracao"
	localizacao = dados_capitulo()["preparacao"]
	fim_turno_exploracao = false
	return true

func concluir_deslocamento() -> bool:
	if fase != "exploracao" or fim_turno_exploracao:
		return false
	turno_exploracao += 1
	fim_turno_exploracao = true
	alimentos.avancar("exploracao")
	alimentos.atualizar_ficha(ficha_brokk)
	return true

func consumir(comida: String) -> bool:
	if fase != "exploracao" or estado_brokk.pv_atuais <= 0 or not inventario.retirar_comida(comida):
		return false
	alimentos.aplicar(comida, estado_brokk)
	alimentos.atualizar_ficha(ficha_brokk)
	return true

func descansar(tipo: String, comida: String, habilidade: String = "") -> Dictionary:
	return Descanso.executar(self, tipo, comida, habilidade)
