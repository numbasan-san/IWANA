
extends Control

var is_open : bool = false
signal opened
signal closed

@onready var inventory : Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")
@onready var item_stack_gui_class = preload("res://scenes/inventory/item_stack_gui.tscn")
@onready var slots : Array = $NinePatchRect/Container.get_children()

var item_in_hand : ItemStackGui
var old_index : int = -1
var locked : bool = false

# Se actualiza el inventario cada que este sea abierto.
func _ready():
	connnect_slots()
	inventory.update.connect(update)
	update()

func connnect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

# Se actualiza el inventario a nivel visual.
func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventory_slot : Slot = inventory.slots[i]
		
		if !inventory_slot.item: continue
		
		var item_stack_gui : ItemStackGui = slots[i].item_stack_gui
		if !item_stack_gui:
			item_stack_gui = item_stack_gui_class.instantiate()
			slots[i].insert(item_stack_gui)
		
		item_stack_gui.inventorySlot = inventory_slot
		item_stack_gui.update()

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

# Acciones que ocurren cuando se "cliquea" un objeto en el inventario.
func on_slot_clicked(slot):
	if locked : return
	if slot.is_empty(): # Se permite mover el objeto a una casilla vacía.
		if !item_in_hand : return
		insert_item_in_slot(slot)
		return
	if !item_in_hand: # Se permite seleccionar un objeto si no se tiene seleccionado uno.
		take_item_from_slot(slot)
		return

	# Cuando se seleccionan dos objetos iguales para hacer stacks.
	if slot.item_stack_gui.inventorySlot.item.name == item_in_hand.inventorySlot.item.name:
		stack_items(slot)
		return

	# Se cambia de objetos cuando hay una casilla ocupada por otro objeto.
	swap_items(slot)

# Se toma un objeto de la casilla del inventario.
func take_item_from_slot(slot):
	item_in_hand = slot.take_item()
	add_child(item_in_hand)
	update_item_in_hand()
	
	old_index = slot.index

# Se mete el objeto en una casilla.
func insert_item_in_slot(slot):
	var item = item_in_hand
	remove_child(item_in_hand)
	item_in_hand = null
	slot.insert(item)
	old_index = -1

# Cambio de objetos cuando se ocupa una casilla por otro objeto.
func swap_items(slot):
	var temp_item = slot.take_item()
	insert_item_in_slot(slot)
	item_in_hand = temp_item
	add_child(item_in_hand)
	update_item_in_hand()

# El "stackeo" de objetos.
func stack_items(slot):
	var slot_item : ItemStackGui = slot.item_stack_gui
	var max_amount = slot_item.inventorySlot.item.stack
	var total_amount = slot_item.inventorySlot.amount + item_in_hand.inventorySlot.amount
	
	if slot_item.inventorySlot.amount == max_amount: # Cuando ya hay un stack completo.
		swap_items(slot)
		return
	if total_amount <= max_amount: # Cuando el stack es menor al máximo del objeto.
		slot_item.inventorySlot.amount = total_amount
		remove_child(item_in_hand)
		item_in_hand = null
		old_index = -1
	else: # Cuando el stack es mucho menor al máximo del objeto.
		slot_item.inventorySlot.amount = max_amount
		item_in_hand.inventorySlot.amount = total_amount - max_amount
	slot_item.update()
	if item_in_hand : item_in_hand.update()

# Para hacer que el objeto siga al mouse una vez selecto.
func update_item_in_hand():
	if !item_in_hand: return
	item_in_hand.global_position = get_global_mouse_position() - (item_in_hand.size / 2)

func put_item_back():
	locked = true
	if old_index < 0:
		var empty_slots = slots.filter(func (s): return s.is_empty())
		if empty_slots.is_empty(): return
		
		old_index = empty_slots[0].index
	var target_slot = slots[old_index]
	
	var tween = create_tween()
	var target_position = target_slot.global_position + target_slot.size / 2
	tween.tween_property(item_in_hand, 'global_position', target_position, 0.2)
	await tween.finished
	
	insert_item_in_slot(target_slot)
	locked = false

func _input(envent):
	if item_in_hand and !locked and Input.is_action_pressed("right_click"):
		put_item_back()
	update_item_in_hand()
