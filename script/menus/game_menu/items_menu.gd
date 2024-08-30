extends Control

@onready var inventory : Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")
@onready var item_card_scene : PackedScene = preload('res://scenes/menus/game_menu/utilities/item_card.tscn')
@onready var items_bar : GridContainer = $background/NinePatchRect/GridContainer

var processed_items = []

func load_items():
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		if slot.item != null and not is_item_already_processed(slot.item):
			var item_card_instance = item_card_scene.instantiate()  # Create an instance of the item_card scene
			var item_node = create_item_card(slot.item, item_card_instance)
			items_bar.add_child(item_node)
			processed_items.append(slot.item)  # Marcar el objeto como procesado

#		else: # Por si lo necesito después.
#			print('Slot ' + str(i) + ' vacío.')

# Helper function to create a node for an item card
func create_item_card(item, item_card_instance):
	# Set the icon and name of the item in the item_card instance
	var icon = item_card_instance.get_node("container/button/icon")
	icon.texture = item.texture  # Assuming the item has a texture property
	
	item_card_instance.icon = item.texture
	item_card_instance.text = item.name
	
	return item_card_instance

func is_item_already_processed(item):
	return item in processed_items



func _on_characters_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('characters_menu')
	characters_menu.visible = true
	characters_menu.load_characters()
	

func _on_maps_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var maps_menu = selected_menu.get_node('maps_menu')
	maps_menu.visible = true
	maps_menu.load_maps()
