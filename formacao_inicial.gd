extends RefCounted
## Planejamento sem PA. Só usa posições já confirmadas, nunca escolhas futuras.
var ordem: Array[String] = []
var indice := 0
var confirmadas: Dictionary = {}
var herois: Array[String] = []

func iniciar(iniciativa: Array, ids_herois: Array) -> void:
	ordem.assign(iniciativa)
	herois.assign(ids_herois)
	indice = 0
	confirmadas.clear()

func atual() -> String:
	return ordem[indice] if indice < ordem.size() else ""

func confirmar(id: String, casa: Vector2i) -> void:
	assert(id == atual())
	confirmadas[id] = casa
	indice += 1

func escolher(grade: Node2D, arma: Dictionary, preferencia: int = 2) -> Vector2i:
	var corpo: bool = arma.get("tipo", "corpo_a_corpo") != "distancia"
	var fileiras: Array[int] = []
	fileiras.assign([3] if corpo else [clampi(preferencia, 1, 3) + 2])
	if not corpo:
		for x in [4, 5, 3]:
			if x not in fileiras:
				fileiras.append(x)
	var alvos: Array[Vector2i] = []
	for id in herois:
		if confirmadas.has(id):
			alvos.append(confirmadas[id])
	# Sem herói confirmado, considera a borda pública da área dos heróis.
	if alvos.is_empty():
		alvos.append(Vector2i(2, 1))
		if Vector2i(2, 1) in grade.obstaculos:
			alvos.assign([Vector2i(2, 0), Vector2i(2, 2)])
	for x in fileiras:
		var melhor := Vector2i(-1, -1)
		var menor := 999
		for y in range(grade.LINHAS):
			var casa := Vector2i(x, y)
			if casa in grade.obstaculos or casa in confirmadas.values():
				continue
			var distancia := 999
			for alvo in alvos:
				var custo := distancia_caminho(grade, casa, alvo) if corpo else absi(casa.x - alvo.x) + absi(casa.y - alvo.y)
				distancia = mini(distancia, custo)
			if distancia < menor:
				menor = distancia
				melhor = casa
		if melhor.x >= 0:
			return melhor
	return Vector2i(-1, -1)

func distancia_caminho(grade: Node2D, origem: Vector2i, alvo: Vector2i) -> int:
	var fila: Array[Vector2i] = [origem]
	var custos := {origem: 0}
	while not fila.is_empty():
		var atual: Vector2i = fila.pop_front()
		if atual == alvo:
			return custos[atual]
		for direcao in grade.DIRECOES:
			var proxima: Vector2i = atual + direcao
			if not grade.dentro(proxima) or proxima in grade.obstaculos or custos.has(proxima):
				continue
			if proxima in confirmadas.values() and proxima != alvo:
				continue
			custos[proxima] = custos[atual] + 1
			fila.append(proxima)
	return 999
