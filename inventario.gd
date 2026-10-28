extends RefCounted
const Catalogo = preload("res://catalogo_consumiveis.gd")
var mantimentos: Dictionary = {}
var equipamentos: Dictionary = {}
var especiais: Dictionary = {}
var coroas := 0

func adicionar_comida(id: String, quantidade: int = 1) -> bool:
	if not Catalogo.ITENS.has(id) or quantidade <= 0:
		return false
	mantimentos[id] = int(mantimentos.get(id, 0)) + quantidade
	return true

func retirar_comida(id: String) -> bool:
	if int(mantimentos.get(id, 0)) < 1:
		return false
	mantimentos[id] -= 1
	return true

func adicionar_equipamento(nome: String) -> void:
	equipamentos[nome] = int(equipamentos.get(nome, 0)) + 1

func adicionar_especial(nome: String) -> void:
	especiais[nome] = int(especiais.get(nome, 0)) + 1

func adicionar_coroas(valor: int) -> bool:
	if valor < 0:
		return false
	coroas += valor
	return true
