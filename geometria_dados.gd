extends RefCounted
## Cascas convexas pequenas, geradas uma vez. Faces numeradas, não valores aleatórios.
static var cache: Dictionary = {}
const TIPOS := [4, 6, 8, 10, 12, 20]

static func faces(tipo: int) -> Array:
	if cache.has(tipo):
		return cache[tipo]
	var pontos: Array[Vector3] = []
	var phi := (1.0 + sqrt(5.0)) / 2.0
	match tipo:
		4:
			pontos.assign([Vector3(1, 1, 1), Vector3(-1, -1, 1), Vector3(-1, 1, -1), Vector3(1, -1, -1)])
		6, 12:
			for x in [-1, 1]:
				for y in [-1, 1]:
					for z in [-1, 1]:
						pontos.append(Vector3(x, y, z))
		8:
			pontos.assign([Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK])
		10:
			pontos.assign([Vector3.UP, Vector3.DOWN])
			var altura := (1.0 - cos(PI / 5.0)) / (1.0 + cos(PI / 5.0))
			for i in range(10):
				pontos.append(Vector3(cos(i * PI / 5.0) * 0.85, altura * (-1 if i % 2 == 0 else 1), sin(i * PI / 5.0) * 0.85))
	if tipo in [12, 20]:
		var a := 1.0 / phi if tipo == 12 else 1.0
		for i in [-1, 1]:
			for j in [-1, 1]:
				pontos.append(Vector3(0, i * a, j * phi))
				pontos.append(Vector3(i * a, j * phi, 0))
				pontos.append(Vector3(j * phi, 0, i * a))
	var raio := 0.0
	for ponto in pontos:
		raio = maxf(raio, ponto.length())
	for i in range(pontos.size()):
		pontos[i] *= 0.98 / raio
	var planos: Dictionary = {}
	for a in range(pontos.size()):
		for b in range(a + 1, pontos.size()):
			for c in range(b + 1, pontos.size()):
				var normal := (pontos[b] - pontos[a]).cross(pontos[c] - pontos[a]).normalized()
				if normal.length_squared() < 0.9:
					continue
				var d := normal.dot(pontos[a])
				if d < 0:
					normal = -normal
					d = -d
				var valido := true
				for ponto in pontos:
					if normal.dot(ponto) > d + 0.0001:
						valido = false
						break
				if not valido:
					continue
				var chave := "%d,%d,%d,%d" % [roundi(normal.x * 10000), roundi(normal.y * 10000), roundi(normal.z * 10000), roundi(d * 10000)]
				if planos.has(chave):
					continue
				var vertices: Array[Vector3] = []
				for ponto in pontos:
					if absf(normal.dot(ponto) - d) < 0.0001:
						vertices.append(ponto)
				var centro := Vector3.ZERO
				for ponto in vertices:
					centro += ponto
				centro /= vertices.size()
				var u := (vertices[0] - centro).normalized()
				var v := normal.cross(u)
				vertices.sort_custom(func(p: Vector3, q: Vector3) -> bool: return atan2((p - centro).dot(v), (p - centro).dot(u)) < atan2((q - centro).dot(v), (q - centro).dot(u)))
				planos[chave] = {"normal": normal, "centro": centro, "vertices": vertices}
	cache[tipo] = planos.values()
	return cache[tipo]
