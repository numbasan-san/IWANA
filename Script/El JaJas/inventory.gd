
extends Resource

class_name Inventory

@export var slots : Array[InventorySlot]
signal update

func insert(item : Item):
	for slot in slots:
		if slot.item == item:
			if slot.amount > slot.item.stack:
				continue
			slot.amount += 1
			update.emit()
			return

	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			update.emit()
			return
