extends Node2D
## Cenário em camadas; não altera posições, obstáculos, custos ou cliques.
const FUNDOS := {
	"Estrada": "res://assets/environments/estrada/estrada_fundo_v01.png",
	"Floresta": "res://assets/environments/floresta/floresta_fundo_v01.png",
	"Entrada da Caverna": "res://assets/environments/passagem/passagem_fundo_v01.png",
	"Covil de Tripa Seca": "res://assets/environments/covil/covil_fundo_v01.png",
}
const PISOS = preload("res://assets/environments/pisos/pisos_atlas_v01.png")
const PROPS = preload("res://assets/environments/props/props_atlas_v01.png")
var ambiente := "Covil de Tripa Seca"
var fundo: TextureRect
var piso: TextureRect
var objetos: Node2D
var brilhos: Array[Sprite2D] = []
var tempo := 0.0

static func textura_fundo(local: String) -> Texture2D:
	return load(FUNDOS.get(local, FUNDOS["Covil de Tripa Seca"]))

func _ready() -> void:
	z_index = 0 # Fica antes da grade na árvore, mas depois do fundo da cena.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fundo = _quadro("FundoDistante", Vector2(-28, -38), Vector2(584, 330))
	fundo.modulate = Color(0.36, 0.36, 0.36)
	piso = _quadro("Piso", Vector2.ZERO, Vector2(528, 264))
	piso.modulate = Color(0.62, 0.62, 0.62)
	objetos = Node2D.new()
	objetos.name = "PropsDasBordas"
	add_child(objetos)
	configurar(ambiente)

func _quadro(nome: String, posicao: Vector2, tamanho: Vector2) -> TextureRect:
	var quadro := TextureRect.new()
	quadro.name = nome
	quadro.position = posicao
	quadro.size = tamanho
	quadro.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	quadro.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	quadro.clip_contents = true
	quadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(quadro)
	return quadro

func configurar(local: String) -> void:
	ambiente = local if FUNDOS.has(local) else "Covil de Tripa Seca"
	if fundo == null:
		return
	fundo.texture = textura_fundo(ambiente)
	var indice: int = FUNDOS.keys().find(ambiente)
	var atlas := AtlasTexture.new()
	atlas.atlas = PISOS
	var lado := PISOS.get_width() / 2.0
	atlas.region = Rect2(Vector2(indice % 2, indice / 2) * lado, Vector2.ONE * lado)
	atlas.filter_clip = true
	piso.texture = atlas
	for filho in objetos.get_children():
		filho.queue_free()
	brilhos.clear()
	var externo := ambiente in ["Estrada", "Floresta"]
	_prop(7 if externo else 0, Vector2(-17, 264), 46)
	_prop(6 if externo else 1, Vector2(516, 264), 42)
	if not externo:
		_prop(5, Vector2(-14, -2), 43)
		_prop(5, Vector2(516, -2), 43)
		for x in [-14, 516]:
			var brilho := Sprite2D.new()
			var gradiente := Gradient.new()
			gradiente.colors = PackedColorArray([Color(1.0, 0.62, 0.20, 0.32), Color(1.0, 0.45, 0.1, 0.0)])
			var luz := GradientTexture2D.new()
			luz.gradient = gradiente
			luz.width = 128
			luz.height = 128
			luz.fill = GradientTexture2D.FILL_RADIAL
			luz.fill_from = Vector2(0.5, 0.5)
			luz.fill_to = Vector2(1.0, 0.5)
			brilho.texture = luz
			brilho.position = Vector2(x, -15)
			objetos.add_child(brilho)
			brilhos.append(brilho)

func _prop(indice: int, posicao: Vector2, largura: float) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = PROPS
	var celula := Vector2(PROPS.get_width() / 4.0, PROPS.get_height() / 2.0)
	atlas.region = Rect2(Vector2(indice % 4, indice / 4) * celula, celula)
	atlas.filter_clip = true
	var objeto := Sprite2D.new()
	objeto.texture = atlas
	objeto.scale = Vector2.ONE * (largura / celula.x)
	objeto.position = posicao - Vector2(0, celula.y * objeto.scale.y / 2)
	objetos.add_child(objeto)

func _process(delta: float) -> void:
	tempo += delta
	for i in range(brilhos.size()):
		# Oscilação leve e determinística; não usa o gerador dos dados.
		brilhos[i].modulate.a = 0.82 + 0.12 * sin(tempo * 3.7 + i)

func enquadrar(posicao_grade: Vector2, tamanho_tela: Vector2) -> void:
	position = posicao_grade
	# O fundo ocupa a tela e recebe sombra; piso/props continuam presos à grade.
	fundo.position = to_local(Vector2.ZERO)
	fundo.size = tamanho_tela / global_scale
