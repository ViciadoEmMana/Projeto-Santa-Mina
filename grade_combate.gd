extends Node2D
## Reutiliza as dimensões do tabuleiro original, sem alterar sua cena ou script.

signal casa_clicada(casa: Vector2i)

const Original = preload("res://tabuleiro.gd")
const COLUNAS := Original.COLUNAS
const LINHAS := Original.LINHAS
const TAMANHO_CASA := Original.TAMANHO_CASA
const DIRECOES := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var posicoes := {"Brokk": Vector2i(2, 1), "Bandido": Vector2i(4, 1)}
# Mortos permanecem desenhados, mas deixam de ocupar casas.
var derrotados: Array[String] = []
var nao_posicionados: Array[String] = []
var alvo_destacado := ""
var alvo_no_alcance := false
var alvos_validos: Array[String] = []
var destinos: Array[Vector2i] = []
var trilha: Array[Vector2i] = []
# Vazia no combate atual. Obstáculos futuros bloqueiam movimento, não lanças.
var obstaculos: Array[Vector2i] = []
var opacidade_piso := 1.0 # Apenas apresentação; o tabuleiro original é preservado.


func dentro(casa: Vector2i) -> bool:
	return casa.x >= 0 and casa.x < COLUNAS and casa.y >= 0 and casa.y < LINHAS


func ocupada(casa: Vector2i, exceto: String = "") -> bool:
	for nome in posicoes:
		if nome != exceto and nome not in derrotados and nome not in nao_posicionados and posicoes[nome] == casa:
			return true
	return false


func nome_casa(casa: Vector2i) -> String:
	return "%s%d" % ["ABC".substr(casa.y, 1), casa.x + 1] if dentro(casa) else "fora"


func centro(casa: Vector2i) -> Vector2:
	return (Vector2(casa) + Vector2(0.5, 0.5)) * TAMANHO_CASA


func posicionar(nome: String, casa: Vector2i) -> bool:
	if not dentro(casa) or casa in obstaculos or ocupada(casa, nome):
		return false
	posicoes[nome] = casa
	queue_redraw()
	return true


func casas_iniciais(total_iniciativa: int) -> Array[Vector2i]:
	var primeira_coluna := 2 if total_iniciativa < 10 else (1 if total_iniciativa < 15 else 0)
	var casas: Array[Vector2i] = []
	for y in range(LINHAS):
		for x in range(primeira_coluna, 3):
			var casa := Vector2i(x, y)
			if casa not in obstaculos and not ocupada(casa, "Brokk"):
				casas.append(casa)
	return casas


func caminho(nome: String, destino: Vector2i, maximo_passos: int) -> Array[Vector2i]:
	var vazio: Array[Vector2i] = []
	if not posicoes.has(nome) or not dentro(destino) or destino in obstaculos or ocupada(destino, nome):
		return vazio
	var origem: Vector2i = posicoes[nome]
	if origem == destino:
		return vazio
	# Busca curta: cada passo é ortogonal e casas ocupadas nunca entram na fila.
	var fila: Array[Vector2i] = [origem]
	var caminhos := {origem: vazio}
	while not fila.is_empty():
		var atual: Vector2i = fila.pop_front()
		var trajeto: Array[Vector2i] = caminhos[atual]
		if trajeto.size() >= maximo_passos:
			continue
		for direcao in DIRECOES:
			var proxima: Vector2i = atual + direcao
			if not dentro(proxima) or proxima in obstaculos or ocupada(proxima, nome) or caminhos.has(proxima):
				continue
			var novo: Array[Vector2i] = trajeto.duplicate()
			novo.append(proxima)
			if proxima == destino:
				return novo
			caminhos[proxima] = novo
			fila.append(proxima)
	return vazio


func casas_movimento(nome: String, passos: int) -> Array[Vector2i]:
	var casas: Array[Vector2i] = []
	for y in range(LINHAS):
		for x in range(COLUNAS):
			var casa := Vector2i(x, y)
			if not caminho(nome, casa, passos).is_empty():
				casas.append(casa)
	return casas


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local := to_local(event.position)
		if Rect2(Vector2.ZERO, Vector2(COLUNAS, LINHAS) * TAMANHO_CASA).has_point(local):
			casa_clicada.emit(Vector2i(floori(local.x / TAMANHO_CASA), floori(local.y / TAMANHO_CASA)))
			get_viewport().set_input_as_handled()


func _draw() -> void:
	var fonte := ThemeDB.fallback_font
	for x in range(COLUNAS):
		draw_string(fonte, Vector2(x * TAMANHO_CASA + 40, -8), str(x + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef2"))
	for y in range(LINHAS):
		draw_string(fonte, Vector2(-21, y * TAMANHO_CASA + 48), "ABC".substr(y, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef2"))
		for x in range(COLUNAS):
			var casa := Vector2i(x, y)
			var retangulo := Rect2(Vector2(casa) * TAMANHO_CASA, Vector2.ONE * TAMANHO_CASA)
			var cor := Color("34495a") if (x + y) % 2 == 0 else Color("2b3d4d")
			cor.a = opacidade_piso
			draw_rect(retangulo, cor)
			if casa in obstaculos:
				draw_rect(retangulo.grow(-8), Color("171e25"))
			if casa in destinos:
				draw_rect(retangulo.grow(-4), Color(0.22, 0.64, 0.35, 0.55))
			draw_rect(retangulo, Color("91a7b8"), false, 2.0)
	for nome in posicoes:
		if nome in nao_posicionados:
			continue
		var cor := Color("62aaff") if nome == "Brokk" else Color("f26a68")
		draw_rect(Rect2(Vector2(posicoes[nome]) * TAMANHO_CASA + Vector2(5, 5), Vector2.ONE * (TAMANHO_CASA - 10)), cor, false, 3.0)
	for indice in range(1, trilha.size()):
		draw_line(centro(trilha[indice - 1]), centro(trilha[indice]), Color("f2d28b"), 3.0)
	for nome in alvos_validos:
		if posicoes.has(nome) and nome not in derrotados:
			var retangulo := Rect2(Vector2(posicoes[nome]) * TAMANHO_CASA, Vector2.ONE * TAMANHO_CASA)
			draw_rect(retangulo.grow(-12), Color("f4cf79"), false, 3.0)
	if posicoes.has(alvo_destacado) and alvo_destacado not in derrotados:
		var retangulo := Rect2(Vector2(posicoes[alvo_destacado]) * TAMANHO_CASA, Vector2.ONE * TAMANHO_CASA)
		var cor := Color("e7bd66") if alvo_no_alcance else Color("c77964")
		draw_rect(retangulo.grow(-8), cor, false, 3.0)
