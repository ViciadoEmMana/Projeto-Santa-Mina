extends SceneTree
## Executado duas vezes pelo validador: gravar, encerrar o processo, ler.
const Sistema = preload("res://sistema_campanha.gd")
const Save = preload("res://salvamento_campanha.gd")
var verificacoes := 0
var falhas := 0

func verificar(condicao: bool, texto: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error("FALHOU SAVE ENTRE PROCESSOS: " + texto)

func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	if argumentos.size() != 2 or argumentos[0] not in ["gravar", "ler"]:
		push_error("Use -- gravar|ler caminho_temporario_do_slot")
		quit(1)
		return
	var slot := Save.new(argumentos[1])
	if argumentos[0] == "gravar":
		var c := Sistema.new()
		c.iniciar_confronto()
		for inimigo in c.inimigos_atuais.values():
			inimigo.pv_atuais = 0
		c.concluir_confronto(true)
		c.avancar_capitulo()
		c.estado_brokk.pv_atuais = 9
		c.estado_brokk.mestre_armas_usado = true
		c.estado_brokk.muralha_usada = true
		c.estado_brokk.pa_debito_pendente = 1
		c.consumir("cerveja")
		c.inventario.adicionar_coroas(3) # Fixture identificável, não recompensa nova.
		verificar(slot.salvar(c)["ok"], "Primeiro processo grava um slot isolado")
		verificar(FileAccess.file_exists(slot.caminho), "Arquivo existe antes de encerrar")
	else:
		var resultado := slot.carregar()
		verificar(resultado["ok"], "Segundo processo lê o arquivo do primeiro")
		if resultado["ok"]:
			var c: RefCounted = resultado["campanha"]
			verificar(c.capitulo == 1 and c.fase == "exploracao" and c.localizacao == "Acampamento Protegido", "Capítulo e local persistiram após encerrar processo")
			verificar(c.estado_brokk.pv_atuais == 9 and c.inventario.coroas == 3, "PV e inventário vieram do disco")
			verificar(c.estado_brokk.mestre_armas_usado and c.estado_brokk.muralha_usada and c.estado_brokk.pa_debito_pendente == 1, "Usos e débito persistiram")
			verificar(c.alimentos.ativos["cerveja"]["restantes"] == 3 and c.inventario.mantimentos["cerveja"] == 0 and c.ficha_brokk.atributo_efetivo("FOR") == 4, "Duração, estoque e bônus vieram do save")
			verificar(c.recompensas_recebidas.has(0) and not c.conceder_recompensas(), "Vitória anterior não rende loot outra vez")
	print("RESULTADO SAVE ENTRE PROCESSOS: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
