extends RefCounted
## Visual puro: recebe tipo/resultado já sorteado e nunca usa RNG.
const Geometria = preload("res://geometria_dados.gd")

static func configurar(dado: Node3D, tipo: int, cor: Color) -> Array[Label3D]:
	if dado.get_parent() is Node3D:
		preparar_luz(dado.get_parent())
	var rotulos: Array[Label3D] = []
	if dado.get_meta("tipo_dado", 0) == tipo and dado.get_meta("cor_dado", Color.BLACK) == cor:
		for filho in dado.get_children():
			if filho is Label3D:
				rotulos.append(filho)
		if rotulos.size() == tipo:
			return rotulos
		rotulos.clear()
	for filho in dado.get_children():
		if filho is Label3D:
			dado.remove_child(filho)
			filho.queue_free()
	var cubo := dado.get_node_or_null("Cubo") as MeshInstance3D
	if cubo == null:
		cubo = MeshInstance3D.new()
		cubo.name = "Cubo" # Referência histórica, agora suporta todos os sólidos.
		dado.add_child(cubo)
	var vertices := PackedVector3Array()
	var normais := PackedVector3Array()
	var faces := Geometria.faces(tipo)
	for face: Dictionary in faces:
		var pontos: Array = face["vertices"]
		for i in range(1, pontos.size() - 1):
			for indice in [0, i + 1, i]:
				vertices.append(pontos[indice])
				normais.append(face["normal"])
		var label := Label3D.new()
		label.name = "Face_%d" % (rotulos.size() + 1)
		label.text = str(rotulos.size() + 1)
		label.position = face["centro"] + face["normal"] * 0.004
		label.basis = base_face(face["normal"])
		label.font_size = 84
		label.pixel_size = 0.0042 if tipo >= 12 else (0.0036 if tipo == 10 else (0.0052 if tipo == 8 else 0.006))
		label.outline_size = 4
		var raio_interno := 10.0
		for j in range(pontos.size()):
			var aresta: Vector3 = pontos[(j + 1) % pontos.size()] - pontos[j]
			raio_interno = minf(raio_interno, aresta.cross(face["centro"] - pontos[j]).length() / aresta.length())
		var texto_pixels := ThemeDB.fallback_font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 84) + Vector2.ONE * 8
		label.pixel_size = minf(label.pixel_size, raio_interno * 0.88 / (texto_pixels.length() / 2.0))
		label.modulate = Color("fff0ce")
		label.outline_modulate = Color("15151b")
		label.no_depth_test = false
		label.shaded = false
		dado.add_child(label)
		rotulos.append(label)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normais
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	cubo.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = cor
	material.metallic = 0.35
	material.roughness = 0.48
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	cubo.material_override = material
	dado.set_meta("tipo_dado", tipo)
	dado.set_meta("cor_dado", cor)
	return rotulos

static func base_face(normal: Vector3) -> Basis:
	var cima := Vector3.UP if absf(normal.dot(Vector3.UP)) < 0.95 else Vector3.FORWARD
	var x := cima.cross(normal).normalized()
	var y := normal.cross(x).normalized()
	return Basis(x, y, normal)

static func orientacao_tipo(tipo: int, resultado: int) -> Vector3:
	assert(resultado >= 1 and resultado <= tipo)
	var inclinacao := Basis.from_euler(Vector3(-0.12, 0.48 if tipo == 4 else (0.25 if tipo == 6 else 0.16), 0))
	return (inclinacao * base_face(Geometria.faces(tipo)[resultado - 1]["normal"]).inverse()).get_euler()

static func orientacao(dado: Node3D, resultado: int) -> Vector3:
	dado.set_meta("resultado", resultado)
	return orientacao_tipo(dado.get_meta("tipo_dado", 6), resultado)

static func resultado_visivel(dado: Node3D) -> int:
	var faces := Geometria.faces(dado.get_meta("tipo_dado", 6))
	var maior := -2.0
	var valor := 0
	for i in range(faces.size()):
		var alinhamento: float = (dado.basis.orthonormalized() * faces[i]["normal"]).dot(Vector3.BACK)
		if alinhamento > maior:
			maior = alinhamento
			valor = i + 1
	return valor

static func animar(dado: Node3D, resultado: int) -> Tween:
	var final := orientacao(dado, resultado)
	var altura := dado.position.y
	var tween := dado.create_tween()
	tween.tween_property(dado, "rotation", final + Vector3(TAU * 2, TAU * 3, TAU * 2), 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(dado, "position:y", altura + 0.16, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(dado, "position:y", altura, 0.45).set_delay(0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): dado.rotation = final)
	tween.tween_property(dado, "position:y", altura - 0.035, 0.06)
	tween.tween_property(dado, "position:y", altura, 0.09)
	return tween

static func preparar_luz(mundo: Node3D) -> void:
	if mundo.has_node("AmbienteDados"):
		return
	var ambiente := WorldEnvironment.new()
	ambiente.name = "AmbienteDados"
	var configuracao := Environment.new()
	configuracao.background_mode = Environment.BG_CLEAR_COLOR
	configuracao.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	configuracao.ambient_light_color = Color("b6c3d4")
	configuracao.ambient_light_energy = 0.5
	ambiente.environment = configuracao
	mundo.add_child(ambiente)
