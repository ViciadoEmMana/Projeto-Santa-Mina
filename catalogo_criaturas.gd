extends RefCounted
## Fichas de campanha. Os danos novos seguem exatamente as expressões fornecidas.
const Estado = preload("res://estado_inimigo.gd")
const Equipamentos = preload("res://equipamentos_combate.gd")
const CLAVA := {"nome": "Clava", "categoria": "comum", "tipo": "corpo_a_corpo", "maos": 1, "dado": 6, "tipo_dano": "fisico", "categoria_efeito": "contundente", "alcance": {"modo": "adjacente"}}
const GANCHO := {"nome": "Gancho", "categoria": "comum", "tipo": "corpo_a_corpo", "maos": 1, "dado": 4, "tipo_dano": "fisico", "categoria_efeito": "perfurante", "alcance": {"modo": "adjacente"}}
const ARCO_PODRE := {"nome": "Arco Podre", "fogo_amigo": true, "categoria": "comum", "tipo": "distancia", "maos": 2, "dado": 6, "tipo_dano": "fisico", "categoria_efeito": "projetil", "alcance": {"modo": "tabuleiro"}, "desvantagem_adjacencia_ortogonal": true}
const FACAS := {"nome": "Duas Facas Cegas", "categoria": "comum", "tipo": "corpo_a_corpo", "maos": 2, "dado": 4, "quantidade_dados": 2, "golpes_independentes": true, "tipo_dano": "fisico", "categoria_efeito": "cortante", "alcance": {"modo": "adjacente"}, "natural_unico": false}
const ESPADA_CURTA := {"nome": "Espada Curta", "categoria": "comum", "tipo": "corpo_a_corpo", "maos": 1, "dado": 6, "tipo_dano": "fisico", "categoria_efeito": "cortante", "alcance": {"modo": "adjacente"}}
const FICHAS := {
	"bandido_arqueiro": {"fileira_preferida": 2, "nome": "Bandido Arqueiro", "pv": 6, "FOR": 0, "DES": 1, "pa": 3, "defesa": 0, "arma": Equipamentos.ARCO_CURTO, "bonus": 1},
	"bandido_porrete": {"nome": "Bandido do Porrete", "pv": 8, "FOR": 2, "DES": 0, "pa": 3, "defesa": 0, "arma": Equipamentos.PORRETE, "bonus": 2},
	"goblin_porrete": {"nome": "Goblin do Porrete", "pv": 6, "FOR": 1, "DES": 1, "pa": 3, "defesa": 0, "arma": CLAVA, "bonus": 0, "drop": "Porrete Desgastado", "coroas": 2},
	"goblin_sucata": {"nome": "Goblin Sucata", "pv": 6, "FOR": 2, "DES": 0, "pa": 3, "defesa": 2, "arma": GANCHO, "bonus": 0, "drop": "Tampa de Ferro", "coroas": 2, "pendencias": ["DES não informada: 0 provisório."]},
	"goblin_tiro": {"fileira_preferida": 3, "nome": "Goblin Tiro Certo", "pv": 5, "FOR": 0, "DES": 2, "pa": 3, "defesa": 0, "arma": ARCO_PODRE, "bonus": -1, "drop": "Arco Desgastado", "coroas": 2, "pendencias": ["FOR não informada: 0 provisório.", "Alcance e proximidade herdados provisoriamente dos arcos."]},
	"goblin_faca": {"nome": "Goblin Faca Cega", "pv": 6, "FOR": 0, "DES": 2, "pa": 3, "defesa": 0, "arma": FACAS, "bonus": 0, "drop": "Facas Cegas", "coroas": 2, "pendencias": ["FOR não informada: 0 provisório."], "habilidades": {"passo_agil": {"ativo": true, "casas": 1, "pa": 0, "por_rodada": 1}}},
	"tripa_seca": {"nome": "Tripa Seca", "pv": 13, "FOR": 2, "DES": 2, "pa": 4, "defesa": 2, "arma": ESPADA_CURTA, "bonus": 0, "categoria": "chefe", "nivel": 4, "drop": "Escudo de Madeira e Ferro", "coroas": 7,
		"habilidades": {"ativar_armadilha": {"ativo": false}, "golpe_sujo": {"ativo": true, "cd": 12, "custo_pa": 0, "por_combate": 1}, "terra_nos_olhos": {"ativo": false}, "me_protejam": {"ativo": true, "dano_alto": 5, "distancia": 1, "custo_pa": 0, "por_ataque": 1, "transferencia": "integral_sem_recalcular_defesa"}}},
}

static func criar(id: String) -> RefCounted:
	var dados: Dictionary = FICHAS[id]
	var estado := Estado.new(dados["nome"], dados["pv"], dados["FOR"], dados["DES"], dados["arma"].duplicate(true), dados["pa"])
	estado.ficha_id = id
	estado.fileira_preferida = dados.get("fileira_preferida", 2)
	estado.defesa = dados["defesa"]
	estado.bonus_ataque = dados["bonus"]
	estado.nivel = dados.get("nivel", 2 if id.begins_with("goblin") else 1)
	estado.categoria = dados.get("categoria", "comum")
	estado.habilidades = dados.get("habilidades", {}).duplicate(true)
	estado.pendencias.assign(dados.get("pendencias", []))
	return estado
