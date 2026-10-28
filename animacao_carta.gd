extends RefCounted
## Transições visuais curtas, independentes do relógio e do RNG do combate.
var tween: Tween

func aplicar(carta: Control, destino: Vector2, fator: float, angulo: float, imediato: bool) -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	if imediato or not carta.is_inside_tree():
		carta.position = destino
		carta.scale = Vector2.ONE * fator
		carta.rotation = angulo
		return
	tween = carta.create_tween().set_parallel(true).set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(carta, "position", destino, 0.12)
	tween.tween_property(carta, "scale", Vector2.ONE * fator, 0.12)
	tween.tween_property(carta, "rotation", angulo, 0.12)
