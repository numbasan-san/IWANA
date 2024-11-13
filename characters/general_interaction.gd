# This script must contain the code to execute when the player enters this area
# and presses the interact button

class_name GeneralInteractionArea extends Area2D

@onready var collider: CollisionShape2D = $CollisionShape2D
@export var will_fight: bool
var character

func _ready():

	if not ScriptManager.chain_ended.is_connected(_after_dialog):
		ScriptManager.chain_ended.connect(_after_dialog)
	character = $"../.."

func interaction(_player: PlayerControl):
	# Si este personaje tiene una unidad de diálogo asociada, esperaremos
	# a que termine de hablar
	if $"..".character.dialog_unit:
		ProcessedCharacters.append_char(character.char_info)
		ScriptManager.current_scene.load($"..".character.dialog_unit)
	else:
		_start_battle()
		ProcessedCharacters.append_char(character.char_info)

func _after_dialog(scene_name: String, unit_name: String):
	if unit_name == $"..".character.dialog_unit:
		ProcessedCharacters.append_char(character.char_info)
		if will_fight:
			_start_battle()

func _start_battle():
	pass

func enable():
	collider.disabled = false
	
func disable():
	collider.disabled = true
