# This script must contain the code to execute when the player enters this area
# and presses the interact button

class_name GeneralInteractionArea extends Area2D

signal talked(npc: Character)

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
		print("El personaje " + character.char_info.name + " habló.")
		
		# Esto es para generar o entregar una misión de habla.
		var person = $"..".character.char_info.person
		var ownDoneQuest = QuestsManager.own_quest_done(person)
		if ownDoneQuest: QuestsManager.quest_done(ownDoneQuest)
		# talked.emit(person)
		
		ProcessedCharacters.append_char(character.char_info)
		if will_fight:
			_start_battle()

func _start_battle():
	pass

func enable():
	collider.disabled = false
	
func disable():
	collider.disabled = true
