class_name Character
extends Node

@export var unique = true

# The zone where this character is actually placed in the rpg world
var zone: Zone

@export var dialog_model: DialogModel
@export var rpg_model: ModeloRPG
@export var combat_model: CombatModel
@export var stats: Stats
@export var skills: Array[Skill]

# The name of a unit of the script that is going to be loaded when someone
# interacts with this character
# TODO: we must make a more general code that would work if there are different
# situations that can trigger different units
var dialog_unit: String

func _ready():
	for skill in skills:
		skill.user = self
	# We perform this here because resources don't have a _ready function
	stats.replenish()

func reposition(new_zone: Zone, position: Vector2, direction: String):
	if rpg_model:
		rpg_model.reposition(new_zone, position, direction)
		zone = new_zone
