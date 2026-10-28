extends RefCounted
## Não há preços, efeitos de Galinhada ou de Porção Comum inventados.
const ITENS := {
	"pao_queijo": {"nome": "Pão de Queijo", "temporarios": 2},
	"caldo_ovo": {"nome": "Caldo de Ovo", "cura": 1, "doencas": true},
	"cuscuz": {"nome": "Cuscuz com Manteiga", "movimento": 1, "rodadas": 3},
	"cafe": {"nome": "Café", "iniciativa": 1, "rodadas": 3},
	"rabada": {"nome": "Rabada", "dano_armas": 1, "rodadas": 3},
	"moqueca": {"nome": "Moqueca", "dano_magias": 1, "rodadas": 3},
	"galinhada": {"nome": "Galinhada", "pendente": true},
	"cerveja": {"nome": "Cerveja", "FOR": 1, "rodadas": 3},
	"doce": {"nome": "Doce", "DES": 1, "rodadas": 1},
	"costela": {"nome": "Costela de Porco", "temporarios": 3, "rodadas": 3},
	"salada": {"nome": "Salada de Frutas", "DES": 1, "rodadas": 3},
	"acaraje": {"nome": "Acarajé", "SAB": 1, "rodadas": 3},
	"vinho": {"nome": "Vinho", "INT": 1, "rodadas": 3},
	"campari": {"nome": "Campari", "CAR": 1, "rodadas": 3},
}

static func descrever(id: String) -> String:
	var item: Dictionary = ITENS[id]
	if item.get("pendente", false):
		return "Efeito próprio pendente. Pode pagar um descanso."
	var partes: Array[String] = []
	for chave in ["FOR", "DES", "SAB", "INT", "CAR"]:
		if item.has(chave):
			partes.append("+%d %s" % [item[chave], chave])
	for par in [["temporarios", "PV temporários"], ["cura", "PV (cura)"], ["iniciativa", "iniciativa"], ["movimento", "casa de movimento"], ["dano_armas", "dano com armas"], ["dano_magias", "dano com magias (preparado)"]]:
		if item.has(par[0]):
			partes.append("+%d %s" % [item[par[0]], par[1]])
	if item.get("doencas", false):
		partes.append("Vantagem contra doenças (preparado)")
	return "; ".join(partes) + (" • %d rodada(s)" % item["rodadas"] if item.has("rodadas") else " • sem duração definida")
