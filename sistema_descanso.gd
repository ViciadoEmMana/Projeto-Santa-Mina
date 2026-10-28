extends RefCounted
const Comidas = preload("res://catalogo_consumiveis.gd")
const SEGUROS := ["Cidade", "Vila", "Acampamento Protegido"]

static func executar(campanha: RefCounted, tipo: String, comida: String, habilidade: String = "") -> Dictionary:
	if campanha.fase != "exploracao" or campanha.estado_brokk.pv_atuais <= 0:
		return {"ok": false, "mensagem": "Descanso somente fora de combate e com Brokk vivo."}
	if not campanha.fim_turno_exploracao:
		return {"ok": false, "mensagem": "Conclua um turno de deslocamento antes de descansar."}
	if tipo not in ["curto", "longo"] or not Comidas.ITENS.has(comida):
		return {"ok": false, "mensagem": "Escolha um descanso e um mantimento válido."}
	if tipo == "longo" and campanha.localizacao not in SEGUROS:
		return {"ok": false, "mensagem": "Descanso Longo exige Cidade, Vila ou Acampamento Protegido; é proibido na masmorra."}
	var estado: RefCounted = campanha.estado_brokk
	if tipo == "curto" and (habilidade not in ["mestre_armas_usado", "muralha_usada"] or not estado.get(habilidade)):
		return {"ok": false, "mensagem": "Escolha exatamente uma habilidade de classe já gasta."}
	if not campanha.inventario.retirar_comida(comida):
		return {"ok": false, "mensagem": "Mantimento indisponível."}
	if tipo == "curto":
		estado.set(habilidade, false)
	else:
		estado.mestre_armas_usado = false
		estado.muralha_usada = false
		estado.pv_atuais += floori(estado.pv_maximos / 2.0) + campanha.ficha_brokk.atributo_efetivo("CON")
	campanha.alimentos.aplicar(comida, estado)
	campanha.alimentos.atualizar_ficha(campanha.ficha_brokk)
	campanha.fim_turno_exploracao = false
	return {"ok": true, "mensagem": "Descanso %s concluído. Uma unidade de %s consumida; efeito alimentar aplicado." % [tipo, Comidas.ITENS[comida]["nome"]]}
