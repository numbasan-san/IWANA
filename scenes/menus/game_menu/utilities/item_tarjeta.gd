extends Control

@export var icon : Texture
@export var namae : String
@export var text : String
@export var stack : String
@export var item_data : Item  # Nueva propiedad para guardar el item
@export var hover : Texture


func _on_button_pressed():
	var shop_menu = get_parent()
	while shop_menu != null and not shop_menu.has_method("_on_item_card_pressed"):
		shop_menu = shop_menu.get_parent()
	
	if shop_menu and shop_menu.has_method("_on_item_card_pressed"):
		shop_menu._on_item_card_pressed(self)

func _on_button_focus_entered():
	$Button/MarginContainer/HBoxContainer/icon.texture = hover

func _on_button_focus_exited():
	$Button/MarginContainer/HBoxContainer/icon.texture = icon

func _on_button_mouse_entered():
	$Button/MarginContainer/HBoxContainer/icon.texture = hover

func _on_button_mouse_exited():
	$Button/MarginContainer/HBoxContainer/icon.texture = icon
