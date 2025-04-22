extends Control

@onready var inventory : Inventory = preload(
	"res://script/object_inventory/inventory/resources/inventory.tres"
)
@onready var item_card_scene : PackedScene = preload(
	'res://scenes/menus/game_menu/utilities/item_card.tscn'
)
@onready var items_bar : GridContainer = (
	$HBoxContainer/ItemsArea/MarginContainer/items/NinePatchRect/GridContainer
)

var processed_items = [] # List to keep track of processed items.
var selected_card = null

signal select_to_use

# Function to load and display items in the menu.
func load_items():
	# Clear previously displayed items in the bar.
	clear_items_bar()
	processed_items.clear() # Reset the list of processed items.

	# Go through all the spaces in the inventory.
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]

		# If the slot has an item and it hasn't been processed before, it's processed.
		if slot.item != null and not is_item_already_processed(slot.item):
			var total_count = count_total_item_in_inventory(slot.item)

			# Instantiate the item card and update with the information.
			var item_card_instance = item_card_scene.instantiate()
			var item_node = create_item_card(slot.item, total_count, item_card_instance)

			# Add the item card to the container (items_bar).
			items_bar.add_child(item_node)
			processed_items.append(slot.item)  # Mark this item as processed.

			# Connect the button to the method that handles the item selection.
			var button = item_card_instance.get_node("container/button")
			button.pressed.connect(Callable(self, "_on_item_card_pressed").bind(item_card_instance))

# Function to clean the Grid Container by removing all its children.
func clear_items_bar():
	for child in items_bar.get_children():
		items_bar.remove_child(child)  # Remove the child from the container.
		child.queue_free()  # Free node memory.

# Function to count the total amount/stock of an item in the inventory.
func count_total_item_in_inventory(item):
	var total_count = 0
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		if slot.item != null and slot.item.name == item.name:
			total_count += slot.amount # Add the total quantity of the same item.
	return total_count

# Create the item card with its icon and name updated with the total.
func create_item_card(item, total_count, item_card_instance):
	var icon = item_card_instance.get_node("container/button/icon")
	icon.texture = item.texture  # Assign the icon texture.

	# Update the name and quantity on the item card.
	item_card_instance.icon = item.texture
	item_card_instance.text = item.name + " (" + str(total_count) + ")"
	item_card_instance.item = item

	return item_card_instance

func get_selected_item():
	return selected_card

# Handles the action when a button on an item is pressed.
func _on_item_card_pressed(item_card_instance):
	# Update the icon and information of the selected item.
	selected_card = item_card_instance
	$"../label".text = selected_card.text + " seleccionado"

# Function that checks if the item has already been processed.
func is_item_already_processed(item):
	return item in processed_items
	
func _on_use_pressed():
	$"../label".text = selected_card.text + " usado"
	select_to_use.emit()

func _on_inspect_pressed():
	$"../label".text = selected_card.text

# To reduce the amount/stock of the used item.
func _on_party_menu_item_used():
	for i in range(inventory.slots.size()): # Inventory load.
		var slot = inventory.slots[i]
		# Item amount/stock reduced.
		if slot.item == selected_card.item: slot.amount -= 1 
		# If the amount/stock is 0.
		# It's set to "less or equal" to avoid negative indices.
		if slot.amount <= 0:
			slot.amount = 0
			slot.item = null
