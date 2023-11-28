
extends Area2D

@export var item_res : Item

# Called when the node enters the scene tree for the first time.
func collect(inventory : Inventory):
	inventory.insert(item_res)
	queue_free()
