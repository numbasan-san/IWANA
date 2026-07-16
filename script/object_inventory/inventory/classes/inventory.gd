extends Resource
class_name Inventory

@export var slots : Array[Slot] = []
@export var gold : int = 1000

signal update

func insert(item : Item):
	# Para poder crear stacks.
	for slot in slots:
		if slot and slot.item == item:
			if slot.amount >= slot.item.max_stack:
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

func count_empty_slot() -> int:
	var empty_slot = 0
	for i in range(slots.size()):
		if !slots[i] or !slots[i].item:
			empty_slot += 1
	return empty_slot

func remove_slot(inventory_slot: Slot):
	var index = slots.find(inventory_slot)
	if index < 0 : return
	slots[index] = Slot.new()

func insert_slot(index: int, slot: Slot):
	slots[index] = slot

func count_stacks() -> bool:
	if slots.is_empty(): return true
	
	var stack = true
	if count_empty_slot() == 0:
		var last_slot = slots[slots.size() - 1]
		if last_slot and last_slot.amount >= last_slot.item.stack:
			stack = false
	return stack

