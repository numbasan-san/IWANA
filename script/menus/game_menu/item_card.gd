extends Control

@onready var icon : Texture
@onready var text : String

<<<<<<< Updated upstream
func update_card(item):
	icon = item.texture
	text = item.name

=======
>>>>>>> Stashed changes
func _on_button_pressed():
	# Quiero una forma más elegante de acceder allá, pero no la tengo.
	
	var grid_container = self.get_parent()
	var nine_patch = grid_container.get_parent()
	var background = nine_patch.get_parent()
	
	var item_icon = background.get_node('item_icon/icon')
	item_icon.texture = icon
	var item_info = background.get_node('item_info')
	item_info.text = text
	
	print(background)
