class_name Character
extends Node

@export var unique = true

# The zone where this character is actually placed in the rpg world
var zone: Zone

@export var dialog_model: DialogModel
@export var rpg_model: ModeloRPG
@export var combat_model: CombatModel
@export var stats: Stats

func reposition(new_zone: Zone, position: Vector2, direction: String):
	if rpg_model:
		rpg_model.reposition(new_zone, position, direction)
		zone = new_zone
