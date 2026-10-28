extends RefCounted
## Centros das casas na mesma reta, em ordem do disparo. Não usa proximidade.
static func na_linha(origem: Vector2i, alvo: Vector2i, casa: Vector2i) -> bool:
	var direcao := alvo - origem
	var delta := casa - origem
	var produto := delta.x * direcao.x + delta.y * direcao.y
	return delta.x * direcao.y == delta.y * direcao.x and produto > 0 and produto < direcao.length_squared()

static func primeiro(origem: Vector2i, alvo: Vector2i, posicoes: Dictionary, vivos: Array[String], obstaculos: Array[Vector2i]) -> Dictionary:
	var distancia := 999999
	var resultado: Dictionary = {}
	for casa in obstaculos:
		if na_linha(origem, alvo, casa):
			var d := (casa - origem).length_squared()
			if d < distancia:
				distancia = d
				resultado = {"obstaculo": true, "casa": casa}
	var ids: Array = posicoes.keys()
	ids.sort()
	for id in ids:
		if id not in vivos or not na_linha(origem, alvo, posicoes[id]):
			continue
		var d: int = (posicoes[id] - origem).length_squared()
		if d < distancia:
			distancia = d
			resultado = {"obstaculo": false, "id": id, "casa": posicoes[id]}
	return resultado

static func ativar(arma: Dictionary, natural: int, interceptacao: Dictionary) -> bool:
	return arma.get("fogo_amigo", false) and arma.get("categoria_efeito", "") == "projetil" and arma.get("tipo", "") == "distancia" and natural in [1, 2] and interceptacao.has("id")

static func atravessa_obstaculo(origem: Vector2i, alvo: Vector2i, casa: Vector2i) -> bool:
	# Paredes ocupam a casa inteira. Tocar só um vértice não atravessa seu interior.
	var inicio := Vector2(origem) + Vector2.ONE * 0.5
	var direcao := Vector2(alvo - origem)
	var entrada := 0.0
	var saida := 1.0
	for eixo in range(2):
		var minimo := float(casa[eixo]) + 0.00001
		var maximo := float(casa[eixo]) + 0.99999
		if absf(direcao[eixo]) < 0.00001:
			if inicio[eixo] < minimo or inicio[eixo] > maximo:
				return false
		else:
			var a := (minimo - inicio[eixo]) / direcao[eixo]
			var b := (maximo - inicio[eixo]) / direcao[eixo]
			entrada = maxf(entrada, minf(a, b))
			saida = minf(saida, maxf(a, b))
			if saida <= entrada:
				return false
	return saida > entrada and saida > 0 and entrada < 1
