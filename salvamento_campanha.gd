extends RefCounted
## Um slot manual, entre confrontos. JSON contém dados, nunca objetos ou scripts.
const Sistema = preload("res://sistema_campanha.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const Comidas = preload("res://catalogo_consumiveis.gd")
const VERSAO := 2
const CAMINHO := "user://campanha_v1.json"
const LIMITE_BYTES := 262144
const ARMAS := {
	"padrao": {}, "espada_ferro": Equipamentos.ESPADA_FERRO, "machado_ferro": Equipamentos.MACHADO_FERRO,
	"arco_curto": Equipamentos.ARCO_CURTO, "porrete": Equipamentos.PORRETE,
	"lanca_ferro_grande": Equipamentos.LANCA_FERRO_GRANDE,
	"lanca_aco_imperial": Equipamentos.LANCA_ACO_IMPERIAL,
}
const INTEIROS_ESTADO := {
	"pa_atuais": 5, "pa_penalidade_pendente": 1000000,
	"pa_debito_pendente": 1000000, "pa_debito_registrado": 1000000,
	"pa_debitado_neste_turno": 1000000, "ultimo_dado_inimigo": 20,
}

var caminho: String

func _init(destino: String = CAMINHO) -> void:
	caminho = destino

func existe() -> bool:
	return FileAccess.file_exists(caminho) or FileAccess.file_exists(caminho + ".bak")

func salvar(campanha: RefCounted) -> Dictionary:
	if campanha.fase == "combate":
		return _erro("Salve depois de concluir o confronto.")
	var documento := criar_documento(campanha)
	var validacao := restaurar(documento)
	if not validacao["ok"]:
		return _erro("Não foi possível salvar: " + validacao["mensagem"])
	var temporario := caminho + ".tmp"
	var arquivo := FileAccess.open(temporario, FileAccess.WRITE)
	if arquivo == null:
		return _erro("Não foi possível abrir o arquivo para salvar. O save anterior foi preservado.")
	arquivo.store_string(JSON.stringify(documento, "\t", false))
	arquivo.flush()
	var erro := arquivo.get_error()
	arquivo.close()
	if erro != OK or not _ler(temporario)["ok"]:
		return _erro("A gravação não pôde ser conferida. O save anterior foi preservado.")
	# Conserva a última gravação válida antes de substituir o slot principal.
	if FileAccess.file_exists(caminho) and _ler(caminho)["ok"]:
		if DirAccess.copy_absolute(caminho, caminho + ".bak") != OK:
			return _erro("Não foi possível criar a cópia de segurança. O save anterior foi preservado.")
	if DirAccess.rename_absolute(temporario, caminho) != OK:
		return _erro("Não foi possível concluir a gravação. O save anterior foi preservado.")
	return {"ok": true, "mensagem": "Campanha salva. Capítulo %d/4 • PV %d/%d." % [campanha.capitulo + 1, campanha.estado_brokk.pv_atuais, campanha.estado_brokk.pv_maximos]}

func carregar() -> Dictionary:
	var resultado := _ler(caminho)
	if resultado["ok"]:
		return resultado
	if FileAccess.file_exists(caminho + ".bak"):
		var backup := _ler(caminho + ".bak")
		if backup["ok"]:
			backup["mensagem"] = "Cópia de segurança carregada: a gravação principal estava indisponível."
			backup["backup"] = true
			return backup
	return resultado

func _ler(origem: String) -> Dictionary:
	if not FileAccess.file_exists(origem):
		return _erro("Nenhuma campanha salva neste slot.")
	var arquivo := FileAccess.open(origem, FileAccess.READ)
	if arquivo == null:
		return _erro("Não foi possível ler a campanha salva.")
	if arquivo.get_length() > LIMITE_BYTES:
		arquivo.close()
		return _erro("Arquivo de campanha maior que o limite aceito.")
	var texto := arquivo.get_as_text()
	var erro := arquivo.get_error()
	arquivo.close()
	if erro != OK:
		return _erro("A leitura da campanha não pôde ser concluída.")
	var json := JSON.new()
	if json.parse(texto) != OK:
		return _erro("Arquivo de campanha inválido. A partida atual foi preservada.")
	return restaurar(json.data)

static func criar_documento(c: RefCounted) -> Dictionary:
	var estado: RefCounted = c.estado_brokk
	var arma_id := "desconhecida"
	for id in ARMAS:
		if c.ficha_brokk.arma_equipada == ARMAS[id]:
			arma_id = id
			break
	var heroi := {
		"id": "zeno", "nome": "Zeno", "raca": "Humano", "classe": "Guerreiro",
		"pv": estado.pv_atuais, "escudo": c.ficha_brokk.escudo_equipado, "arma": arma_id,
		"mestre_armas_usado": estado.mestre_armas_usado, "muralha_usada": estado.muralha_usada,
		"defesa_temporaria": estado.bonus_defesa_temporaria,
		"vantagens": estado.fontes_vantagem.duplicate(), "desvantagens": estado.fontes_desvantagem.duplicate(),
		"derrubado": estado.condicoes.derrubado, "penalidade_condicao": estado.condicoes.penalidade_pendente,
		"espada_repeticao_usada": estado.espada_repeticao_usada,
	}
	for chave in INTEIROS_ESTADO:
		heroi[chave] = estado.get(chave)
	var efeitos := {}
	for id in c.alimentos.ativos:
		var efeito: Dictionary = c.alimentos.ativos[id]
		efeitos[id] = {"restantes": efeito["restantes"], "temporarios_restantes": efeito["temporarios_restantes"]}
	var recompensas: Array = c.recompensas_recebidas.keys()
	recompensas.sort()
	return {
		"jogo": "santa_mina", "versao": VERSAO, "salvo_em": int(Time.get_unix_time_from_system()),
		"progresso": {
			"capitulo": c.capitulo, "fase": c.fase, "local": c.localizacao,
			"turno": c.turno_exploracao, "fim_turno": c.fim_turno_exploracao,
			"recompensas": recompensas, "ultima_recompensa": c.ultima_recompensa,
			"batalha_vencida": c.batalha_vencida,
		},
		"heroi": heroi,
		"inventario": {
			"mantimentos": c.inventario.mantimentos.duplicate(), "equipamentos": c.inventario.equipamentos.duplicate(),
			"especiais": c.inventario.especiais.duplicate(), "coroas": c.inventario.coroas,
		},
		"alimentos": {"relogio": c.alimentos.relogio, "movimento_por_acao": c.alimentos.movimento_por_acao, "ativos": efeitos},
	}

static func restaurar(documento: Variant) -> Dictionary:
	documento = _migrar_legado(documento)
	var problema := _validar(documento)
	if not problema.is_empty():
		return _erro(problema + " A partida atual foi preservada.")
	# Só constrói a nova campanha depois de validar todos os campos.
	var c := Sistema.new()
	var p: Dictionary = documento["progresso"]
	c.capitulo = int(p["capitulo"])
	c.fase = p["fase"]
	c.localizacao = p["local"]
	c.turno_exploracao = int(p["turno"])
	c.fim_turno_exploracao = p["fim_turno"]
	c.ultima_recompensa = p["ultima_recompensa"]
	c.batalha_vencida = p["batalha_vencida"]
	for capitulo in p["recompensas"]:
		c.recompensas_recebidas[int(capitulo)] = true
	var b: Dictionary = documento["heroi"]
	c.ficha_brokk.escudo_equipado = b["escudo"]
	c.ficha_brokk.arma_equipada = ARMAS[b["arma"]].duplicate(true)
	var estado: RefCounted = c.estado_brokk
	estado.pv_atuais = int(b["pv"])
	estado.mestre_armas_usado = b["mestre_armas_usado"]
	estado.muralha_usada = b["muralha_usada"]
	estado.espada_repeticao_usada = b["espada_repeticao_usada"]
	estado.bonus_defesa_temporaria = int(b["defesa_temporaria"])
	estado.fontes_vantagem.assign(b["vantagens"])
	estado.fontes_desvantagem.assign(b["desvantagens"])
	estado.condicoes.derrubado = b["derrubado"]
	estado.condicoes.penalidade_pendente = int(b["penalidade_condicao"])
	for chave in INTEIROS_ESTADO:
		estado.set(chave, int(b[chave]))
	estado.bonus_defesa_natural = c.ficha_brokk.bonus_pele_rocha(estado.pv_atuais)
	estado.bonus_defesa_escudo = c.ficha_brokk.bonus_escudo(estado.ultimo_dado_inimigo)
	var inventario: Dictionary = documento["inventario"]
	for chave in ["mantimentos", "equipamentos", "especiais"]:
		var estoque := {}
		for nome in inventario[chave]:
			estoque[nome] = int(inventario[chave][nome])
		c.inventario.set(chave, estoque)
	c.inventario.coroas = int(inventario["coroas"])
	# Reconstrói bônus pelo catálogo. O save não define atributos ou regras novos.
	var a: Dictionary = documento["alimentos"]
	c.alimentos.relogio = a["relogio"]
	c.alimentos.movimento_por_acao = a["movimento_por_acao"]
	for id in a["ativos"]:
		var efeito: Dictionary = Comidas.ITENS[id].duplicate(true)
		efeito["restantes"] = int(a["ativos"][id]["restantes"])
		efeito["temporarios_restantes"] = int(a["ativos"][id]["temporarios_restantes"])
		c.alimentos.ativos[id] = efeito
	c.alimentos.atualizar_ficha(c.ficha_brokk)
	return {"ok": true, "mensagem": "Campanha carregada. Capítulo %d/4 • PV %d/%d." % [c.capitulo + 1, estado.pv_atuais, estado.pv_maximos], "campanha": c, "backup": false}

static func _validar(d: Variant) -> String:
	if not d is Dictionary or not d.get("jogo") is String or d["jogo"] != "santa_mina":
		return "Este arquivo não é um save de Santa Mina."
	if not _inteiro(d.get("versao"), VERSAO, VERSAO):
		return "Versão de save incompatível."
	if not _inteiro(d.get("salvo_em"), 0, 99999999999):
		return "Data do save inválida."
	for chave in ["progresso", "heroi", "inventario", "alimentos"]:
		if not d.get(chave) is Dictionary:
			return "Seção ausente ou inválida: " + chave + "."
	var p: Dictionary = d["progresso"]
	if not _inteiro(p.get("capitulo"), 0, 3) or not p.get("fase") is String or p["fase"] not in ["exploracao", "vitoria", "final", "derrota"]:
		return "Capítulo ou fase inválida; saves durante combate não são aceitos."
	var capitulo := int(p["capitulo"])
	var fase: String = p["fase"]
	if (fase == "final" and capitulo != 3) or (fase == "vitoria" and capitulo == 3):
		return "Conclusão incompatível com o capítulo."
	var local_esperado: String = Sistema.Capitulos.CAPITULOS[capitulo]["preparacao" if fase == "exploracao" else "local"]
	if not p.get("local") is String or p["local"] != local_esperado or not _inteiro(p.get("turno"), 0, 1000000) or not p.get("fim_turno") is bool or not p.get("batalha_vencida") is bool:
		return "Estado de exploração inválido."
	if not _texto(p.get("ultima_recompensa"), 4096) or not p.get("recompensas") is Array:
		return "Histórico de recompensas inválido."
	var quantidade := capitulo + (1 if fase in ["vitoria", "final"] else 0)
	if p["recompensas"].size() != quantidade:
		return "Histórico de capítulos incompatível."
	for i in range(quantidade):
		if not _inteiro(p["recompensas"][i], i, i):
			return "Histórico de recompensas repetido ou fora de ordem."
	if fase in ["vitoria", "final"] and not p["batalha_vencida"]:
		return "Vitória sem conclusão de confronto."
	var b: Dictionary = d["heroi"]
	if b.get("id") != "zeno" or b.get("nome") != "Zeno" or b.get("raca") != "Humano" or b.get("classe") != "Guerreiro":
		return "Identidade do protagonista inválida."
	if not _inteiro(b.get("pv"), 0 if fase == "derrota" else 1, 14) or not b.get("arma") is String or not ARMAS.has(b["arma"]):
		return "PV ou arma de Zeno inválidos."
	for chave in ["escudo", "mestre_armas_usado", "muralha_usada", "derrubado", "espada_repeticao_usada"]:
		if not b.get(chave) is bool:
			return "Estado de Zeno inválido: " + chave + "."
	for chave in INTEIROS_ESTADO:
		if not _inteiro(b.get(chave), 0, INTEIROS_ESTADO[chave]):
			return "Valor de PA ou dado inválido: " + chave + "."
	if not _inteiro(b.get("defesa_temporaria"), 0, 2) or int(b["defesa_temporaria"]) == 1 or not _inteiro(b.get("penalidade_condicao"), 0, 1000000):
		return "Defesa temporária ou condição inválida."
	if not _fontes(b.get("vantagens")) or not _fontes(b.get("desvantagens")):
		return "Fontes de Vantagem/Desvantagem inválidas."
	var inv: Dictionary = d["inventario"]
	if not _inteiro(inv.get("coroas"), 0, 1000000):
		return "Quantidade de coroas inválida."
	for chave in ["mantimentos", "equipamentos", "especiais"]:
		if not _estoque(inv.get(chave)):
			return "Inventário inválido: " + chave + "."
	for id in inv["mantimentos"]:
		if not Comidas.ITENS.has(id):
			return "Mantimento desconhecido no save."
	var a: Dictionary = d["alimentos"]
	if not a.get("relogio") is String or a["relogio"] not in ["combate", "exploracao", "compartilhado"] or not a.get("movimento_por_acao") is bool or not a.get("ativos") is Dictionary:
		return "Configuração dos alimentos inválida."
	for id in a["ativos"]:
		if not Comidas.ITENS.has(id) or not a["ativos"][id] is Dictionary:
			return "Efeito alimentar desconhecido ou inválido."
		var item: Dictionary = Comidas.ITENS[id]
		var efeito: Dictionary = a["ativos"][id]
		if item.has("cura") or item.get("pendente", false):
			return "Este mantimento não mantém um efeito ativo."
		var duracao := int(item.get("rodadas", -1))
		if not _inteiro(efeito.get("restantes"), 1 if duracao > 0 else -1, duracao) or not _inteiro(efeito.get("temporarios_restantes"), 0, int(item.get("temporarios", 0))):
			return "Duração ou PV temporários inválidos."
	return ""

static func _migrar_legado(documento: Variant) -> Variant:
	# Mantém o slot antigo e migra só sua estrutura; nunca grava durante carregar.
	if not documento is Dictionary or not _inteiro(documento.get("versao"), 1, 1):
		return documento
	if not documento.get("brokk") is Dictionary:
		return documento
	var novo: Dictionary = documento.duplicate(true)
	novo["versao"] = VERSAO
	novo["heroi"] = novo["brokk"]
	novo.erase("brokk")
	novo["heroi"].merge({"id": "zeno", "nome": "Zeno", "raca": "Humano", "classe": "Guerreiro", "espada_repeticao_usada": false}, true)
	return novo


static func _inteiro(valor: Variant, minimo: int, maximo: int) -> bool:
	# JSON devolve números como float; rejeita frações e booleanos explicitamente.
	return (valor is int or valor is float) and is_finite(float(valor)) and float(valor) == floor(float(valor)) and valor >= minimo and valor <= maximo

static func _texto(valor: Variant, limite: int) -> bool:
	return valor is String and valor.length() <= limite

static func _fontes(valor: Variant) -> bool:
	if not valor is Array or valor.size() > 64:
		return false
	for fonte in valor:
		if not _texto(fonte, 128):
			return false
	return true

static func _estoque(valor: Variant) -> bool:
	if not valor is Dictionary or valor.size() > 128:
		return false
	for nome in valor:
		if not _texto(nome, 128) or nome.is_empty() or not _inteiro(valor[nome], 0, 1000000):
			return false
	return true

static func _erro(mensagem: String) -> Dictionary:
	return {"ok": false, "mensagem": mensagem}
