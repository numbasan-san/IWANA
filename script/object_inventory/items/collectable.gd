# res://script/object_inventory/items/collectable.gd
extends Area2D

@export var item_res : Item

# Called when the node enters the scene tree for the first time.
func collect(inventory : Inventory):
	inventory.insert(item_res)
	QuestsManager.collect_quest(item_res.item)
	queue_free()
