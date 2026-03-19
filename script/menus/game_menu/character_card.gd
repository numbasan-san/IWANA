extends Control

@onready var portrait : Texture
@onready var char_name : String
@onready var description : String
@onready var character : Character

func _on_button_pressed():
	# Quiero una forma más elegante de acceder allá, pero no la tengo.
	
	var grid_container = self.get_parent()
	var nine_patch = grid_container.get_parent()
	var background = nine_patch.get_parent()
	
	var char_portrait = background.get_node('char_portrait/portrait')
	char_portrait.texture = portrait
	var character_info = background.get_node_or_null('bar2/character_info')
	character_info.text = char_name + '. ' + description
	
	var menu = background.get_parent()
	
	if character != null:
		menu.selected_char = character
	
	var ascend_btn = background.get_node_or_null('HBoxContainer/ascend_btn')
	var accept_btn = background.get_node_or_null('HBoxContainer/accept_btn')
	var get_out_btn = background.get_node_or_null('HBoxContainer/get_out_btn')
	
	if ascend_btn and accept_btn and get_out_btn:
		ascend_btn.disabled = false
		accept_btn.disabled = false
		get_out_btn.disabled = false
