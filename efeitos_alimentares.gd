extends RefCounted
## Relógio configurável. Padrão provisório: rodadas de combate; exploração separada.
const Catalogo = preload("res://catalogo_consumiveis.gd")
var ativos: Dictionary = {}
var relogio := "combate"
var movimento_por_acao := true

func aplicar(id: String, estado: RefCounted) -> void:
	var item: Dictionary = Catalogo.ITENS[id]
	if item.has("cura"):
		estado.pv_atuais += int(item["cura"])
	if item.get("pendente", false):
		return
	var efeito := item.duplicate(true)
	efeito["restantes"] = int(item.get("rodadas", -1))
	efeito["temporarios_restantes"] = int(item.get("temporarios", 0))
	# Repetir a mesma comida renova; nunca soma indefinidamente.
	ativos[id] = efeito

func bonus(chave: String) -> int:
	var total := 0
	for efeito in ativos.values():
		total += int(efeito.get(chave, 0))
	return total

func pv_temporarios() -> int:
	var total := 0
	for efeito in ativos.values():
		total += int(efeito.get("temporarios_restantes", 0))
	return total

func absorver(dano: int) -> int:
	var restante := maxi(0, dano)
	for efeito in ativos.values():
		var usado := mini(restante, int(efeito.get("temporarios_restantes", 0)))
		efeito["temporarios_restantes"] = int(efeito.get("temporarios_restantes", 0)) - usado
		restante -= usado
	return restante

func avancar(tipo_relogio: String) -> void:
	if tipo_relogio != relogio and relogio != "compartilhado":
		return
	for id in ativos.keys():
		if int(ativos[id]["restantes"]) > 0:
			ativos[id]["restantes"] -= 1
			if ativos[id]["restantes"] == 0:
				ativos.erase(id)

func atualizar_ficha(ficha: RefCounted) -> void:
	ficha.modificadores_temporarios.clear()
	for atributo in ["FOR", "DES", "CON", "INT", "SAB", "CAR"]:
		ficha.modificadores_temporarios[atributo] = bonus(atributo)

func resumo() -> String:
	var nomes: Array[String] = []
	for efeito in ativos.values():
		var duracao: int = efeito["restantes"]
		nomes.append("%s%s" % [efeito["nome"], " (%d rodadas)" % duracao if duracao > 0 else " (sem duração definida)"])
	return ", ".join(nomes) if not nomes.is_empty() else "Nenhum"
