class_name PortraitContainer
extends CharacterContainer

@export var slot: int
@export var background: TextureRect
@export var portrait: TextureRect
@export var character_name: Label
@export var animations: AnimationPlayer

# Region that selects the background icon for the 1st and 3rd
# character slots
var _bg_region_1: Rect2 = Rect2(32, 249, 294, 318)
# Position of the name label for the 1st and 3rd
# character slots
var _name_label_pos_1: Vector2 = Vector2(12, 256)
# Rotation of the name label for the 1st and 3rd
# character slots
var _name_label_rot_1 = 3
# Position for bars for 1st and 3rd character slots
var _bar_pos_1: Vector2 = Vector2(21, -15)
# Region for the 2nd and 4th character slot
var _bg_region_2: Rect2 = Rect2(353, 252, 282, 309)
# Position of the name label for the 1st and 3rd
# character slots
var _name_label_pos_2: Vector2 = Vector2(22, 270)
# Rotation of the name label for the 1st and 3rd
# character slots
var _name_label_rot_2 = -6
# Position for bars for 2nd and 4th character slots
var _bar_pos_2: Vector2 = Vector2(-6, -3)

# If this container is selected it should show some indicator
var is_selected: bool = false:
	set(value):
		if value:
			animations.play("GUI/Selected")
		elif animations.current_animation == "GUI/Selected":
			animations.stop()
		is_selected = value

# This is used instead of _ready so that we can pass the slot
# variable to the health and energy bars before those are
# initialized
func _enter_tree():
	hide()
	fill_bars.slot = slot
	change_slot(self.slot)

# The specific image and layout of a portrait depends on its
# position in the party menu. We can use this function to change
# them accordingly
func change_slot(slot: int):
	if slot == 1 or slot == 3:
		(background.texture as AtlasTexture).region = _bg_region_1
		fill_bars.position = _bar_pos_1
		character_name.position = _name_label_pos_1
		character_name.rotation_degrees = _name_label_rot_1
	else:
		(background.texture as AtlasTexture).region = _bg_region_2
		fill_bars.position = _bar_pos_2
		character_name.position = _name_label_pos_2
		character_name.rotation_degrees = _name_label_rot_2

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
