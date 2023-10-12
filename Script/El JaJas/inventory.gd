
extends Resource

class_name Inventory

@export var items : Array[Item]
signal update

func insert(item : Item):
	for i in range(items.size()):
		if !items[i]:
			items[i] = item
			break
	update.emit()
