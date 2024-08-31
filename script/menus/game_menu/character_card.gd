extends Control
# $character_card/container/button/portrait
@onready var portrait : Texture
@onready var char_name : String
@onready var description : String

func _on_button_pressed():
	# Quiero una forma más elegante de acceder allá, pero no la tengo.
	
	var grid_container = self.get_parent()
	var nine_patch = grid_container.get_parent()
	var background = nine_patch.get_parent()
	
	var char_portrait = background.get_node('char_portrait/portrait')
	char_portrait.texture = portrait
	var character_info = background.get_node_or_null('character_info')
	if character_info == null:
		character_info = background.get_node_or_null('bar2/character_info')
	character_info.text = char_name + '. ' + description
