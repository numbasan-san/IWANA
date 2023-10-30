
extends CanvasLayer

@onready var inventory = $inventory_gui

func _input(event): # Verifica la activación y visualización del inventario.
	if event.is_action_released("toggle_inventory") or event.is_action_released("ui_accept"):
		if inventory.is_open:
			inventory.close()
		else :
			inventory.open()

func _ready(): # Mantiene al inventario cerrado desde la base.
	inventory.close()

func _on_inventory_gui_closed():  # Reanuda el juego mientras esté cerrado.
	get_tree().paused = false

func _on_inventory_gui_opened(): # Pausa el juego mientras esté abierto.
	get_tree().paused = true
