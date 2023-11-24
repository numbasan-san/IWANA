class_name CharacterCombatContainer extends Panel

@export var stats : Resource # ThePlayerResource

@export var portrait: TextureRect
@export var character_name: Label
@export var health_bar: ProgressBar
@export var energy_bar: ProgressBar
@export var health_value: Label
@export var energy_value: Label
@export var animations: AnimationPlayer

var character: Character

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
func set_to_character(new_character: Character = null):
	# We must first remove the previous character, if any, and then we can add
	# the new one if it's not null.
	remove_character()
	if new_character:
		character = new_character
		character_name.text = character.name
		_update_portrait(null, character.combat_model.current_portrait)
		character.combat_model.update_portrait.connect(_update_portrait)
		_update_max_health(0, character.stats.max_health)
		character.stats.update_max_health.connect(_update_max_health)
		_update_health(0, character.stats.health)
		character.stats.update_health.connect(_update_health)
		_update_max_energy(0, character.stats.max_energy)
		character.stats.update_max_energy.connect(_update_max_energy)
		_update_energy(0, character.stats.energy)
		character.stats.update_energy.connect(_update_energy)
		
		show()
		

# If this container has a character registered, it removes it and disconnects
# all signals
func remove_character():
	if character:
		hide()
		character.combat_model.update_portrait.disconnect(_update_portrait)
		character.stats.update_max_health.disconnect(_update_max_health)
		character.stats.update_health.disconnect(_update_health)
		character.stats.update_max_energy.disconnect(_update_max_energy)
		character.stats.update_energy.disconnect(_update_energy)
		character = null

func _update_portrait(_old: TextureRect, new: TextureRect):
	portrait.texture = new.texture

func _update_max_health(_old: int, new: int):
	var current = character.stats.health
	health_bar.max_value = new
	health_bar.value = current
	health_value.text = str(current) + "/" + str(new)
	
func _update_health(_old: int, new: int):
	var max = character.stats.max_health
	health_bar.max_value = max
	health_bar.value = new
	health_value.text = str(new) + "/" + str(max)

func _update_max_energy(_old: int, new: int):
	var current = character.stats.energy
	energy_bar.max_value = new
	energy_bar.value = current
	energy_value.text = str(current) + "/" + str(new)
	
func _update_energy(_old: int, new: int):
	var max = character.stats.max_energy
	energy_bar.max_value = max
	energy_bar.value = new
	energy_value.text = str(new) + "/" + str(max)
