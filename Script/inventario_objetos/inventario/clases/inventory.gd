
extends Resource

class_name Inventory

@export var slots : Array[Slot]
signal update

func insert(item : Item):
	# Para poder crear stacks.
	for slot in slots:
		if slot.item == item:
			if slot.amount >= slot.item.stack:
				continue
			slot.amount += 1
			update.emit()
			return

	# Para meter nuevos objetos en el inventario.
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			update.emit()
			return

# Cuenta cuantos espacios vacíos hay en el inventario.
func count_empty_slot() -> int:
	var empty_slot = 0
	for i in range(slots.size()):
		if !slots[i].item:
			empty_slot += 1
	return empty_slot

# Para verificar que hay espacio en el stack del último espacio del inventario.
func count_stacks() -> bool:
	var stack = true
	if count_empty_slot() == 0:
		var last_slot = slots[(slots.size() - 1)]
		if last_slot.amount >= last_slot.item.stack:
			stack = false
	return stack
