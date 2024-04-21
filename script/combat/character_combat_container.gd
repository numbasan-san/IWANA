class_name PortraitContainer
extends CharacterContainer

@export var stats : Resource # ThePlayerResource

@export var portrait: TextureRect
@export var character_name: Label
@export var animations: AnimationPlayer

# If this container is selected it should show some indicator
var is_selected: bool = false:
	set(value):
		if value:
			animations.play("GUI/Selected")
		elif animations.current_animation == "GUI/Selected":
			animations.stop()
		is_selected = value

func _ready():
	hide()

# Assigns a character to this character slot in the gui to monitor its stats
func set_character(new_character: Character = null):
	super.set_character(new_character)
	if new_character:
		character_name.text = character.name
		_update_portrait(null, new_character.combat_model.current_portrait)
		new_character.combat_model.update_portrait.connect(_update_portrait)
	
		show()

# If this container has a character registered, it removes it and disconnects
# all signals
func remove_character():
	if character:
		hide()
		character.combat_model.update_portrait.disconnect(_update_portrait)
	super.remove_character()

func _update_portrait(_old: TextureRect, new: TextureRect):
	portrait.texture = new.texture
