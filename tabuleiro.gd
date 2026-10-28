extends Node2D

const COLUNAS := 6
const LINHAS := 3
const TAMANHO_CASA := 88.0

const COR_FUNDO := Color("18212b")
const COR_CASA_A := Color("34495a")
const COR_CASA_B := Color("2b3d4d")
const COR_GRADE := Color("91a7b8")
const COR_SELECAO := Color("f2c14e")

var casa_atual := Vector2i(0, 0)
var inicio_grade := Vector2.ZERO


func _ready() -> void:
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var direcao := Vector2i.ZERO
	match event.keycode:
		KEY_LEFT, KEY_A:
			direcao.x = -1
		KEY_RIGHT, KEY_D:
			direcao.x = 1
		KEY_UP, KEY_W:
			direcao.y = -1
		KEY_DOWN, KEY_S:
			direcao.y = 1
		_:
			return

	casa_atual.x = clampi(casa_atual.x + direcao.x, 0, COLUNAS - 1)
	casa_atual.y = clampi(casa_atual.y + direcao.y, 0, LINHAS - 1)
	queue_redraw()
	get_viewport().set_input_as_handled()


func _draw() -> void:
	var tamanho_grade := Vector2(COLUNAS, LINHAS) * TAMANHO_CASA
	inicio_grade = (get_viewport_rect().size - tamanho_grade) / 2.0
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), COR_FUNDO)

	for linha in LINHAS:
		for coluna in COLUNAS:
			var posicao := inicio_grade + Vector2(coluna, linha) * TAMANHO_CASA
			var cor := COR_CASA_A if (linha + coluna) % 2 == 0 else COR_CASA_B
			draw_rect(Rect2(posicao, Vector2.ONE * TAMANHO_CASA), cor)
			draw_rect(Rect2(posicao, Vector2.ONE * TAMANHO_CASA), COR_GRADE, false, 2.0)

	var posicao_selecao := inicio_grade + Vector2(casa_atual) * TAMANHO_CASA
	draw_rect(Rect2(posicao_selecao + Vector2(5, 5), Vector2.ONE * (TAMANHO_CASA - 10)), COR_SELECAO, false, 4.0)

	var fonte := ThemeDB.fallback_font
	var texto := "TABULEIRO 3 x 6     |     Mova com as setas ou WASD"
	draw_string(fonte, Vector2(inicio_grade.x, inicio_grade.y - 24), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e8eef2"))
