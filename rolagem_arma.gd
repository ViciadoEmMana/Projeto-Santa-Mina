extends RefCounted
## Vantagem compara conjuntos completos. 2d4 continua sendo um ataque.
const Regras = preload("res://regras_combate.gd")

static func sortear(arma: Dictionary, modo: String, rng: RandomNumberGenerator) -> Dictionary:
	var grupos: Array[Array] = []
	var totais: Array[int] = []
	for i in range(Regras.quantidade_dados(modo)):
		var dados: Array[int] = []
		for j in range(int(arma.get("quantidade_dados", 1))):
			dados.append(rng.randi_range(1, int(arma["dado"])))
		grupos.append(dados)
		var total := 0
		for valor in dados:
			total += valor
		totais.append(total)
	var indice := Regras.indice_resultado(totais, modo)
	var selecionados: Array[int] = []
	selecionados.assign(grupos[indice])
	return {"grupos": grupos, "totais": totais, "selecionados": selecionados, "total": totais[indice], "natural_unico": selecionados.size() == 1}
