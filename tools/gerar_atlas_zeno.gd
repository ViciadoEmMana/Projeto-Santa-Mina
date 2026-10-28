extends SceneTree
## Só registra regiões/âncoras; não altera os pixels da imagem gerada.
const FONTE := "res://assets/characters/zeno/zeno_animacoes_fonte_v01.png"
const DESTINO := "res://assets/characters/zeno/zeno_animacoes.tres"
func _initialize() -> void:
	var imagem := Image.load_from_file(FONTE)
	if imagem == null:
		quit(1)
		return
	var nomes := ["idle", "caminhar", "correr", "ataque", "defesa", "dano", "morte"]
	var velocidades := [6, 8, 12, 11, 10, 10, 9]
	var texto := "[gd_resource type=\"SpriteFrames\" load_steps=58 format=3]\n\n[ext_resource type=\"Texture2D\" path=\"" + FONTE + "\" id=\"1\"]\n"
	var animacoes := PackedStringArray()
	var altura_idle := 0
	for linha in range(7):
		var quadros := PackedStringArray()
		for coluna in range(8):
			var inicio := Vector2i(coluna * imagem.get_width() / 8, linha * imagem.get_height() / 7)
			var fim := Vector2i((coluna + 1) * imagem.get_width() / 8, (linha + 1) * imagem.get_height() / 7)
			var minimo := fim
			var maximo := inicio
			for y in range(inicio.y, fim.y):
				for x in range(inicio.x, fim.x):
					if imagem.get_pixel(x, y).a >= 0.2:
						minimo = minimo.min(Vector2i(x, y))
						maximo = maximo.max(Vector2i(x, y))
			var tamanho := maximo - minimo + Vector2i.ONE
			if tamanho.x < 10 or tamanho.y < 10:
				push_error("Quadro vazio: %d/%d" % [linha, coluna])
				quit(1)
				return
			if linha == 0:
				altura_idle += tamanho.y
			var id := "Quadro_%d_%d" % [linha, coluna]
			var margem_x := 192 + minimo.x - inicio.x - (fim.x - inicio.x) / 2
			texto += "\n[sub_resource type=\"AtlasTexture\" id=\"%s\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d, %d, %d, %d)\nmargin = Rect2(%d, %d, %d, %d)\nfilter_clip = true\n" % [id, minimo.x, minimo.y, tamanho.x, tamanho.y, margem_x, 352 - tamanho.y, 384 - tamanho.x, 384 - tamanho.y]
			quadros.append("{\"duration\": 1.0, \"texture\": SubResource(\"%s\")}" % id)
		animacoes.append("{\"frames\": [%s], \"loop\": %s, \"name\": &\"%s\", \"speed\": %d.0}" % [", ".join(quadros), "true" if linha < 3 else "false", nomes[linha], velocidades[linha]])
	texto += "\n[resource]\nanimations = [%s]\nmetadata/escala_atlas = %f\nmetadata/protagonista = \"zeno\"\n" % [",\n".join(animacoes), 70.0 / (altura_idle / 8.0)]
	var arquivo := FileAccess.open(DESTINO, FileAccess.WRITE)
	arquivo.store_string(texto)
	arquivo.close()
	print("ZENO ATLAS: %dx%d, 56 quadros, 7 animações; escala %.4f." % [imagem.get_width(), imagem.get_height(), 70.0 / (altura_idle / 8.0)])
	quit()
