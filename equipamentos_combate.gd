extends RefCounted
## Dados dos equipamentos e alcance lógico. Não altera PA nem movimento.

const MACHADO_FERRO := {
	"nome": "Machado de Ferro", "categoria": "comum", "tipo": "corpo_a_corpo",
	"maos": 1, "dado": 6, "tipo_dano": "fisico", "atributo": "FOR",
	"categoria_efeito": "cortante",
	"alcance": {"modo": "adjacente"},
	"bonus_natural": {"natural": 6, "atributo": "FOR", "minimo": 2, "dano": 2},
}
const ESPADA_FERRO := {
	"nome": "Espada de Ferro", "categoria": "comum", "tipo": "corpo_a_corpo",
	"maos": 1, "dado": 6, "tipo_dano": "fisico", "atributo": "FOR",
	"categoria_efeito": "cortante", "alcance": {"modo": "adjacente"},
	"repetir_erro": {"atributos": ["FOR", "DES"], "minimo": 2, "por_combate": 1},
}
const ESCUDO_FERRO_MADEIRA := {
	"nome": "Escudo de Ferro e Madeira", "maos": 1,
	"defesa": 2, "naturais": [2, 3], "modificadores": {"DES": -1},
}
const ESCUDO_MADEIRA_FERRO := {
	"nome": "Escudo de Madeira e Ferro", "maos": 1,
	"defesa": 2, "naturais": [2, 3], "modificadores": {"DES": -1},
}
const ARCO_CURTO := {
	"nome": "Arco Curto", "fogo_amigo": true, "categoria": "comum", "tipo": "distancia",
	"maos": 2, "dado": 6, "tipo_dano": "fisico", "atributo": "DES",
	"categoria_efeito": "projetil",
	"alcance": {"modo": "tabuleiro"}, "desvantagem_adjacencia_ortogonal": true,
}
const PORRETE := {
	"nome": "Porrete", "categoria": "comum", "tipo": "corpo_a_corpo",
	"maos": 1, "dado": 6, "tipo_dano": "fisico", "atributo": "FOR",
	"categoria_efeito": "contundente",
	"alcance": {"modo": "adjacente"},
	"derrubado_natural": {"natural": 6, "atributo": "FOR", "minimo": 2},
}
# Mantida para outros equipamentos cujo alcance ainda não foi definido.
const ALCANCE_ESTENDIDO_PENDENTE := {"modo": "estendido", "definido": false, "deslocamentos": []}
const ALCANCE_LANCAS_GRANDES := {
	"modo": "estendido", "definido": true, "distancia_maxima": 2,
	"atravessa_obstaculos": true, "atravessa_personagens": true, "alvo_unico": true,
}
const LANCA_FERRO_GRANDE := {
	"nome": "Lança de Ferro Grande", "categoria": "comum", "tipo": "corpo_a_corpo",
	"maos": 2, "dado": 6, "tipo_dano": "fisico", "valor_coroas": 5,
	"categoria_efeito": "perfurante",
	"alcance": ALCANCE_LANCAS_GRANDES,
	"ignorar_defesa": {"natural_minimo": 6, "natural_maximo": 6, "atributos": ["FOR", "DES"], "minimo": 3},
}
const LANCA_ACO_IMPERIAL := {
	"nome": "Lança de Aço Imperial", "categoria": "rara", "tipo": "corpo_a_corpo",
	"maos": 2, "dado": 8, "tipo_dano": "fisico", "valor_coroas": 10,
	"categoria_efeito": "perfurante",
	"alcance": ALCANCE_LANCAS_GRANDES,
	"ignorar_defesa": {"natural_minimo": 6, "natural_maximo": 8, "atributos": ["FOR", "DES"], "minimo": 3},
}


static func permite_repetir_erro(arma: Dictionary, atributos: Dictionary) -> bool:
	var regra: Dictionary = arma.get("repetir_erro", {})
	for atributo in regra.get("atributos", []):
		if int(atributos.get(atributo, 0)) >= int(regra["minimo"]):
			return true
	return false


static func avaliar_alcance(arma: Dictionary, origem: Vector2i, alvo: Vector2i, tamanho: Vector2i) -> Dictionary:
	if not _dentro(origem, tamanho) or not _dentro(alvo, tamanho):
		return {"permitido": false, "motivo": "Origem ou alvo fora do tabuleiro."}
	if origem == alvo:
		return {"permitido": false, "motivo": "Não é possível atacar a própria casa."}
	var alcance: Dictionary = arma.get("alcance", {})
	var diferenca := alvo - origem
	match alcance.get("modo", ""):
		"adjacente":
			if maxi(absi(diferenca.x), absi(diferenca.y)) == 1:
				return {"permitido": true, "motivo": ""}
			return {"permitido": false, "motivo": "Fora do alcance: esta arma exige uma casa adjacente, incluindo diagonais."}
		"tabuleiro":
			return {"permitido": true, "motivo": ""}
		"estendido":
			if not alcance.get("definido", false):
				return {"permitido": false, "motivo": "Alcance estendido ainda não definido para esta arma."}
			if alcance.has("distancia_maxima"):
				# Distância de Chebyshev: não consulta caminho, ocupação ou obstáculos.
				# Somente o alvo indicado é alcançado; movimento continua usando a grade.
				var distancia := maxi(absi(diferenca.x), absi(diferenca.y))
				var dentro_alcance: bool = distancia <= int(alcance["distancia_maxima"])
				return {"permitido": dentro_alcance, "motivo": "" if dentro_alcance else "Fora do alcance: máximo de duas casas, incluindo diagonais."}
			var permitido: bool = diferenca in alcance.get("deslocamentos", [])
			return {"permitido": permitido, "motivo": "" if permitido else "Alvo fora do alcance configurado."}
	return {"permitido": false, "motivo": "Alcance do equipamento ainda não definido."}


static func _dentro(casa: Vector2i, tamanho: Vector2i) -> bool:
	return casa.x >= 0 and casa.y >= 0 and casa.x < tamanho.x and casa.y < tamanho.y


static func desvantagem_por_proximidade(arma: Dictionary, origem: Vector2i, inimigos: Array[Vector2i]) -> bool:
	if not arma.get("desvantagem_adjacencia_ortogonal", false):
		return false
	for inimigo in inimigos:
		var diferenca := inimigo - origem
		if absi(diferenca.x) + absi(diferenca.y) == 1:
			return true
	return false


static func bonus_dano(arma: Dictionary, natural: int, atributos: Dictionary) -> int:
	var condicao: Dictionary = arma.get("bonus_natural", {})
	if condicao.is_empty() or natural != int(condicao["natural"]):
		return 0
	if int(atributos.get(condicao["atributo"], 0)) < int(condicao["minimo"]):
		return 0
	return int(condicao["dano"])


static func ignora_defesa(arma: Dictionary, natural: int, atributos: Dictionary) -> bool:
	# Efeito da arma, separado de futuros críticos. Não altera os bônus do alvo.
	var condicao: Dictionary = arma.get("ignorar_defesa", {})
	if condicao.is_empty() or natural < 2 or natural > int(arma["dado"]):
		return false
	if natural < int(condicao["natural_minimo"]) or natural > int(condicao["natural_maximo"]):
		return false
	for atributo in condicao["atributos"]:
		if int(atributos.get(atributo, 0)) >= int(condicao["minimo"]):
			return true
	return false


static func tenta_derrubar(arma: Dictionary, natural: int, atributos: Dictionary) -> bool:
	var efeito: Dictionary = arma.get("derrubado_natural", {})
	return not efeito.is_empty() and natural == int(efeito["natural"]) and int(atributos.get(efeito["atributo"], 0)) >= int(efeito["minimo"])
