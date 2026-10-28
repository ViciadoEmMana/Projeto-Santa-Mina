extends SceneTree
## Inspeção da transparência e regiões; não modifica a imagem-fonte.
func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	var caminho := "res://assets/characters/brokk/brokk_idle_ataque_fonte_v01.png" if argumentos.is_empty() else argumentos[0]
	var imagem := Image.load_from_file(caminho)
	var linhas := int(argumentos[1]) if argumentos.size() > 1 else 4
	var largura := imagem.get_width()
	var altura := imagem.get_height()
	var visitados := PackedByteArray()
	visitados.resize(largura * altura)
	var regioes: Array[Dictionary] = []
	for y in range(altura):
		for x in range(largura):
			var inicio := y * largura + x
			if visitados[inicio] or imagem.get_pixel(x, y).a < 0.2:
				continue
			var pilha := PackedInt32Array([inicio])
			visitados[inicio] = 1
			var minimo := Vector2i(x, y)
			var maximo := minimo
			var quantidade := 0
			while not pilha.is_empty():
				var indice := pilha[-1]
				pilha.resize(pilha.size() - 1)
				var atual := Vector2i(indice % largura, indice / largura)
				minimo = minimo.min(atual)
				maximo = maximo.max(atual)
				quantidade += 1
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var proximo := atual + Vector2i(dx, dy)
						if proximo.x < 0 or proximo.y < 0 or proximo.x >= largura or proximo.y >= altura:
							continue
						var novo := proximo.y * largura + proximo.x
						if not visitados[novo] and imagem.get_pixelv(proximo).a >= 0.2:
							visitados[novo] = 1
							pilha.append(novo)
			if quantidade > 1000:
				var apoio_min := maximo.x
				var apoio_max := minimo.x
				for py in range(maxi(minimo.y, maximo.y - 8), maximo.y + 1):
					for px in range(minimo.x, maximo.x + 1):
						if imagem.get_pixel(px, py).a >= 0.2:
							apoio_min = mini(apoio_min, px)
							apoio_max = maxi(apoio_max, px)
				regioes.append({"regiao": Rect2i(minimo, maximo - minimo + Vector2i.ONE), "pixels": quantidade, "apoio_x": (apoio_min + apoio_max) / 2.0})
	regioes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: Rect2i = a["regiao"]
		var rb: Rect2i = b["regiao"]
		var linha_a := int(ra.get_center().y / (altura / float(linhas)))
		var linha_b := int(rb.get_center().y / (altura / float(linhas)))
		return linha_a < linha_b if linha_a != linha_b else ra.position.x < rb.position.x)
	print("FONTE: ", largura, "x", altura, " CANTOS ALFA: ", imagem.get_pixel(0, 0).a)
	for i in range(regioes.size()):
		print(i, ": ", regioes[i])
	# Saída opcional para montar AtlasTextures, sem alterar pixels das fontes.
	if argumentos.size() > 2:
		var dados: Array = []
		for item in regioes:
			var r: Rect2i = item["regiao"]
			dados.append([r.position.x, r.position.y, r.size.x, r.size.y, item["apoio_x"]])
		var arquivo := FileAccess.open(argumentos[2], FileAccess.WRITE)
		if arquivo == null:
			push_error("Não foi possível salvar a inspeção: " + argumentos[2])
			quit(1)
			return
		arquivo.store_string(JSON.stringify(dados, "\t"))
		arquivo.close()
	quit()
