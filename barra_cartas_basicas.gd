extends Control
## Uma área permanente. Uma futura mão especial poderá ser outra área irmã.
signal acao_solicitada(id: String)
const Carta = preload("res://carta_combate.gd")
const Definicoes = preload("res://cartas_basicas.gd")
const Regras = preload("res://regras_combate.gd")
var cartas: Dictionary = {}


func _init() -> void:
	name = "BarraCartasBasicas"
	custom_minimum_size = Vector2(944, 304)
	for definicao in Definicoes.CARTAS:
		var carta := Carta.new()
		var dados: Dictionary = definicao.duplicate(true)
		dados["arte"] = Definicoes.ARTES[definicao["id"]]
		carta.configurar(dados, Regras.CUSTOS[definicao["id"]])
		carta.pressed.connect(_solicitar.bind(definicao["id"]))
		add_child(carta)
		cartas[definicao["id"]] = carta


func _solicitar(id: String) -> void:
	# Também protege chamadas programáticas de sinais de cartas indisponíveis.
	if cartas.has(id) and not cartas[id].disabled:
		get_tree().call_group("audio_apresentacao", "carta")
		acao_solicitada.emit(id)


func atualizar(id: String, selecionada: bool, motivo: String) -> void:
	cartas[id].atualizar(selecionada, motivo)

var janela: Window
var janela_anterior: Dictionary = {}

func _ready() -> void:
	janela = get_window()
	janela_anterior = {"size": janela.size, "position": janela.position, "logical": janela.content_scale_size, "mode": janela.content_scale_mode, "aspect": janela.content_scale_aspect}
	janela.content_scale_size = Vector2i(1280, 960)
	janela.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	janela.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	if DisplayServer.get_name() != "headless" and janela.mode == Window.MODE_WINDOWED:
		var tela := DisplayServer.screen_get_usable_rect()
		var disponivel := Vector2(tela.size - Vector2i(40, 80))
		var fator := minf(1.0, minf(disponivel.x / 1280.0, disponivel.y / 960.0))
		janela.size = Vector2i(Vector2(1280, 960) * maxf(0.5, fator))
		janela.position = tela.position + (tela.size - janela.size) / 2
	resized.connect(_dispor)
	_dispor()

func _exit_tree() -> void:
	if get_meta("reorganizando", false):
		return
	if is_instance_valid(janela) and not janela_anterior.is_empty():
		janela.content_scale_size = janela_anterior["logical"]
		janela.content_scale_mode = janela_anterior["mode"]
		janela.content_scale_aspect = janela_anterior["aspect"]
		if DisplayServer.get_name() != "headless" and janela.mode == Window.MODE_WINDOWED:
			janela.size = janela_anterior["size"]
			janela.position = janela_anterior["position"]

func _dispor() -> void:
	var proporcao := minf(1.0, size.x / 944.0)
	var largura := Carta.TAMANHO.x * proporcao
	var passo := largura - 4 * proporcao
	var inicio := (size.x - largura - 4 * passo) / 2.0
	var indice := 0
	for carta in cartas.values():
		var distancia := float(indice - 2)
		carta.definir_posicao_mao(Vector2(inicio + indice * passo, 8 + absf(distancia) * 3), proporcao, distancia * 0.009)
		indice += 1
