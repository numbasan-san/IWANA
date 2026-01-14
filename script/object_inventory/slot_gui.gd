
extends Button

@onready var background_sprite : Sprite2D = $background
@onready var container : CenterContainer = $CenterContainer
@onready var inventory : Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")

var item_stack_gui : ItemStackGui
var index : int

func insert(isg : ItemStackGui):
	item_stack_gui = isg
	# background_sprite.fram = 1
	container.add_child(item_stack_gui)
	if !item_stack_gui.inventorySlot or inventory.slots[index] == item_stack_gui.inventorySlot:
		return
	inventory.insert_slot(index, item_stack_gui.inventorySlot)

func take_item():
	var item = item_stack_gui
	inventory.remove_slot(item_stack_gui.inventorySlot)
	container.remove_child(item_stack_gui)
	item_stack_gui = null
	
	return item

func is_empty():
	return !item_stack_gui
