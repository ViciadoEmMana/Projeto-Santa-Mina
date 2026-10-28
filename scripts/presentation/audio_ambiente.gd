extends Node
## Áudio adicional de apresentação; escolhe materiais sem usar o RNG dos ataques.
const PASTA := "res://audio/ambiente/"
var passos: AudioStreamPlayer
var cartas: AudioStreamPlayer
var dados: AudioStreamPlayer
var ambiente: AudioStreamPlayer
var externo := false

func _ready() -> void:
	add_to_group("audio_apresentacao")
	passos = _canal("Passos", -22)
	cartas = _canal("Carta", -21)
	dados = _canal("Dados", -23)
	ambiente = _canal("Ambiente", -26)

func _canal(nome: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = nome
	player.volume_db = volume
	add_child(player)
	return player

func configurar(local: String) -> void:
	externo = local in ["Estrada", "Floresta"]
	var fonte: AudioStreamWAV = load(PASTA + ("vento_floresta.wav" if externo else "vento_caverna.wav"))
	var loop: AudioStreamWAV = fonte.duplicate()
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = roundi(loop.get_length() * loop.mix_rate)
	ambiente.stream = loop
	ambiente.play()

func passo() -> void:
	passos.stream = load(PASTA + ("passo_terra.wav" if externo else "passo_pedra.wav"))
	passos.play()

func carta() -> void:
	cartas.stream = load(PASTA + "carta.wav")
	cartas.play()

func rolar() -> void:
	dados.stream = load(PASTA + "dados.wav")
	dados.play()

func _exit_tree() -> void:
	for player in [passos, cartas, dados, ambiente]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
