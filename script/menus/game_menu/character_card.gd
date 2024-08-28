extends Control
# $container/button/portrait
@onready var portrait : Texture
@onready var char_name : String
@onready var description : String


func _on_button_pressed():
	# Quiero una forma más elegante de acceder allá, pero no la tengo.
	
	var grid_container = self.get_parent()
	var nine_patch = grid_container.get_parent()
	var background = nine_patch.get_parent()
	
	var character_portrait = background.get_node('character_portrait/portrain')
	character_portrait.texture = portrait
	var character_info = background.get_node('character_info')
	character_info.text = char_name + '. ' + description
	
