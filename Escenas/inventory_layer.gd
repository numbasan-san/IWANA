
extends CanvasLayer

@onready var inventory = $inventory_gui

func _input(event):
	if event.is_action_released("toggle_inventory"):
		if inventory.is_open:
			inventory.close()
		else :
			inventory.open()

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.close()

func _on_inventory_gui_closed():
	get_tree().paused = false

func _on_inventory_gui_opened():
	get_tree().paused = true
