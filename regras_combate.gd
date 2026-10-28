extends RefCounted
## Regras comuns, sem Defesa base implícita e sem rolagem extra para acertar.

const PA_POR_TURNO := 5
const CUSTOS := {
	"atacar": 3, "vantagem": 5, "defender": 1, "mover": 2, "correr": 3,
	"trocar_posicao": 1, "fugir": 1, "trocar_arma": 1, "pocao": 1,
}


static func defesa_total(fontes: Dictionary) -> int:
	var total := 0
	for valor in fontes.values():
		total += int(valor)
	return total


static func ataque_fisico(natural: int, atributo: int, fontes: Dictionary, bonus_arma: int = 0, ignorar_defesa: bool = false, pode_errar: bool = true) -> Dictionary:
	# O erro natural é resolvido antes de qualquer bônus ou redução.
	if natural == 1 and pode_errar:
		return {"natural": natural, "erro": true, "bruto": 0, "bonus_arma": 0, "defesa": 0, "defesa_calculada": 0, "defesa_ignorada": false, "fontes": {}, "dano": 0}
	var bruto := natural + atributo + bonus_arma
	var calculada := defesa_total(fontes)
	var defesa := 0 if ignorar_defesa else calculada
	return {"natural": natural, "erro": false, "bruto": bruto, "bonus_arma": bonus_arma, "defesa": defesa,
		"defesa_calculada": calculada, "defesa_ignorada": ignorar_defesa,
		"fontes": fontes.duplicate(), "dano": maxi(0, bruto - defesa)}


static func ataque_golpes(naturais: Array[int], atributo: int, fontes: Dictionary) -> Dictionary:
	# Uma ação com vários golpes: cada 1 erra só seu golpe.
	# Soma os acertos e reutiliza a redução centralizada, uma única vez.
	var golpes: Array[Dictionary] = []
	var soma_acertos := 0
	var acertou := false
	for natural in naturais:
		var erro := natural == 1
		golpes.append({"natural": natural, "erro": erro})
		if not erro:
			acertou = true
			soma_acertos += natural
	var ataque := ataque_fisico(soma_acertos if acertou else 1, atributo, fontes)
	ataque["natural"] = 0 # Cada golpe tem seu natural; a soma não é um dado.
	ataque["golpes"] = golpes
	ataque["soma_acertos"] = soma_acertos
	return ataque


static func modo_rolagem(vantagem: bool, desvantagem: bool) -> String:
	if vantagem and desvantagem:
		return "normal"
	return "vantagem" if vantagem else ("desvantagem" if desvantagem else "normal")


static func resolver_fontes_rolagem(vantagens: Array[String], desvantagens: Array[String]) -> String:
	# Reutilizável em ataques, desafios e resistências. Fontes não se acumulam:
	# basta haver pelo menos uma de cada tipo para resolver como um dado normal.
	return modo_rolagem(not vantagens.is_empty(), not desvantagens.is_empty())


static func quantidade_dados(modo: String) -> int:
	return 1 if modo == "normal" else (2 if modo in ["vantagem", "desvantagem"] else 0)


static func indice_resultado(dados: Array[int], modo: String) -> int:
	if dados.size() == 2:
		if modo == "vantagem" and dados[1] > dados[0]:
			return 1
		if modo == "desvantagem" and dados[1] < dados[0]:
			return 1
	return 0


static func selecionar_natural(dados: Array[int], modo: String) -> int:
	if modo == "normal" and dados.size() == 1:
		return dados[0]
	if dados.size() == 2:
		if modo == "vantagem":
			return maxi(dados[0], dados[1])
		if modo == "desvantagem":
			return mini(dados[0], dados[1])
	# 0 sinaliza dados incompatíveis com o modo resolvido.
	return 0
