
extends Control

var is_open : bool = false
signal opened
signal closed

@onready var inventory : Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")
@onready var slots : Array = $NinePatchRect/Container.get_children()

# Se actualiza el inventario cada que este sea abierto.
func _ready():
	inventory.update.connect(update)
	update()

# Se actualiza el inventario a nivel visual.
func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

# Se permite la apertura del inventario.
func open():
	visible = true
	is_open = true
	opened.emit()

# Se permite el cierre del inventario.
func close():
	visible = false
	is_open = false
	closed.emit()
