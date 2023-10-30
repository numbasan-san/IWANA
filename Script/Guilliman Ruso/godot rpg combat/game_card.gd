
extends Control

# rival's card
@onready var rival_base_card = $rival_board/card/body # diseño de la carta
@onready var rival_retrato = $rival_board/card/portrait # imagen de la carta
@onready var rival_ornament = $rival_board/card/ornament # decoración de la carta
@onready var rival_coste = $rival_board/card/cost  # número entero
@onready var rival_sello1 = $rival_board/card/seals/seal # habilidad
@onready var rival_sello2 = $rival_board/card/seals/seal2 # habilidad
@onready var rival_damage = $rival_board/card/damage
@onready var rival_salud = $rival_board/card/healt

# player's card
#@onready var player_board = load("res://Script/player_board.gd").new()
@onready var player_base_card = $player_board/card/body # diseño de la carta
@onready var player_retrato = $player_board/card/portrait # imagen de la carta
@onready var player_ornament = $player_board/card/ornament # decoración de la carta
@onready var player_coste = $player_board/card/cost  # número entero
@onready var player_sello1 = $player_board/card/seals/seal # habilidad
@onready var player_sello2 = $player_board/card/seals/seal2 # habilidad
@onready var player_damage = $player_board/card/damage
@onready var player_salud = $player_board/card/healt

# info card
@onready var info_cost = $info_card/cost # diseño de la carta
@onready var info_nombre = $info_card/name # nombre de la carta
@onready var info_description = $info_card/description # nombre de la carta
@onready var info_damage = $info_card/damage
@onready var info_salud = $info_card/health

func _ready():
	load_scriptable_and_load()

func load_scriptable_and_load():
	var rival_card = load("res://Script/Scriptable Objects/urayuli.tres")
	var player_card = load("res://Script/Scriptable Objects/dios_mantis.tres")
	var info_card = load("res://Script/Scriptable Objects/info_card.tres")
	
#	print(player_card.base_card)
#	print(player_card.ornament)
#	print(player_card.retrato)
#	print(player_card.coste)
#	print(player_card.sello1)
#	print(player_card.sello2)
#	print(player_card.damage)
#	print(player_card.salud)
#
#	player_board.get_player_base_card.texture = (player_card.base_card)
#	player_board.set_player_ornament(player_board.get_player_ornament, player_card.ornament)
#	player_board.set_player_retrato(player_board.get_player_retrato, player_card.retrato)
#	player_board.set_player_coste(player_board.get_player_coste, player_card.coste)
#	player_board.set_player_sello1(player_board.get_player_sello1, player_card.sello1)
#	player_board.set_player_sello2(player_board.get_player_sello2, player_card.sello2)
#	player_board.set_player_damage(player_board.get_player_damage, player_card.damage)
#	player_board.set_player_salud(player_board.get_player_salud, player_card.salud)
	
#	rival's card
	rival_base_card.texture = rival_card.base_card
	rival_ornament.texture = rival_card.ornament
	rival_retrato.texture = rival_card.retrato
	rival_coste.texture = rival_card.coste

	info_nombre.text = str(info_card.nombre)
	info_description.text = str(info_card.description)

	rival_sello1.texture = rival_card.sello1
	rival_sello2.texture = rival_card.sello2
	if rival_card.sello2 == null:
		rival_sello2.visible = false

	rival_damage.text = str(rival_card.damage)
	rival_salud.text = str(rival_card.salud)

	# player's card
	player_base_card.texture = player_card.base_card
	player_ornament.texture = player_card.ornament
	player_retrato.texture = player_card.retrato
	player_coste.texture = player_card.coste

	info_nombre.text = str(player_card.nombre)
	info_description.text = str(player_card.description)
	info_cost.texture = player_card.coste

	player_sello1.texture = player_card.sello1
	player_sello2.texture = player_card.sello2
	if player_card.sello2 == null:
		player_sello2.visible = false

	print("1er sello: " + str(player_card.sello1) + ".")
	print("2do sello: " + str(player_card.sello2) + ".")

	player_damage.text = str(player_card.damage)
	player_salud.text = str(player_card.salud)

	info_damage.text = str(player_card.damage)
	info_salud.text = str(player_card.salud)
