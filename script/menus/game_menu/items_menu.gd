extends Control

@onready var inventory : Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")
@onready var item_card_scene : PackedScene = preload('res://scenes/menus/game_menu/utilities/item_card.tscn')
@onready var items_bar : GridContainer = $background/items_bar/NinePatchRect/GridContainer

var processed_items = []  # Lista para llevar el control de los ítems procesados.

# Llamamos a las funciones y conectamos los botones en la escena
func clean():
	$background/item_icon/icon.texture = null
	$background/item_info.text = ''

# Función para cargar y mostrar los ítems en el menú.
func load_items():
	# Limpiar los ítems previamente mostrados en la barra.
	clear_items_bar()
	processed_items.clear()  # Reiniciar la lista de ítems procesados.
	clean()
	
	# Recorrer todos los espacios del inventario.
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		
		# Si el slot tiene un ítem y no ha sido procesado antes, lo procesamos.
		if slot.item != null and not is_item_already_processed(slot.item):
			var total_count = count_total_item_in_inventory(slot.item)
			
			# Instanciar la tarjeta del ítem y actualizar con la información.
			var item_card_instance = item_card_scene.instantiate()
			var item_node = create_item_card(slot.item, total_count, item_card_instance)
			
			# Añadir la tarjeta de ítem al contenedor (items_bar).
			items_bar.add_child(item_node)
			processed_items.append(slot.item)  # Marcar este ítem como procesado.

			# Conectar el botón al método que gestiona la selección del ítem.
			var button = item_card_instance.get_node("container/button")
			button.pressed.connect(Callable(self, "_on_item_card_pressed").bind(item_card_instance))

# Función para limpiar el GridContainer eliminando todos sus hijos.
func clear_items_bar():
	for child in items_bar.get_children():
		items_bar.remove_child(child)  # Eliminar el hijo del contenedor.
		child.queue_free()  # Liberar la memoria del nodo.

# Función para contar las existencias totales de un ítem en el inventario.
func count_total_item_in_inventory(item):
	var total_count = 0
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		if slot.item != null and slot.item.name == item.name:
			total_count += slot.amount  # Sumar la cantidad total del mismo ítem.
	return total_count

# Crear la tarjeta del ítem con su ícono y el nombre actualizado con el total.
func create_item_card(item, total_count, item_card_instance):
	var icon = item_card_instance.get_node("container/button/icon")
	icon.texture = item.texture  # Asignar la textura del ícono.
	
	# Actualizar el nombre y la cantidad en la tarjeta del ítem.
	item_card_instance.icon = item.texture
	item_card_instance.text = item.name + " (" + str(total_count) + ")"
	
	return item_card_instance

# Maneja la acción cuando se presiona un botón de un ítem.
func _on_item_card_pressed(item_card_instance):
	var item_icon = $background/item_icon/icon
	var item_info = $background/item_info
	
	# Actualizar el ícono y la información del ítem seleccionado.
	item_icon.texture = item_card_instance.icon
	item_info.text = item_card_instance.text

# Función que verifica si el ítem ya fue procesado.
func is_item_already_processed(item):
	return item in processed_items

# Funciones de cambio de menú.
func _on_characters_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('characters_menu')
	characters_menu.visible = true
	characters_menu.load_canditates()

func _on_maps_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var maps_menu = selected_menu.get_node('maps_menu')
	maps_menu.visible = true
	maps_menu.load_maps()

func _on_contacts_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var contacts_menu = selected_menu.get_node('contacts_menu')
	contacts_menu.visible = true
	contacts_menu.load_characters()
