extends Node2D

class_name ControlJugador

@export var inventory : Inventory

# TODO: cambiar esto para que lea una acción de movimiento custom, que no lea
# teclas directamente

# Movimiento del avatar.
func _process(_delta):
	var x = int(Input.is_action_pressed('rpg_right')) - int(Input.is_action_pressed('rpg_left'))
	var y = int(Input.is_action_pressed('rpg_down')) - int(Input.is_action_pressed('rpg_up'))
	get_parent().set_axis(x, y)
	
# Las colisiones con items en el suelo.
func _on_interaccion_item(area):
	if area.has_method('collect'): # La colisión del avatar del jugador con un objeto.
		if inventory.count_empty_slot() >= 1: # En caso de que haya espacio en el inventario.
			area.collect(inventory)
		else: # En caso no haya espacio en el inventario.
			# Se verifica si en el último espacio del inventario hay espacio en el stack del ítem en turno.
			if inventory.count_stacks():
				area.collect(inventory)


# Entrar al area de interaccion de una puerta
func _on_interaccion_puerta(area):
	if area.has_method('change_zone'):
		area.change_zone(get_parent().personaje)


# Entrar al area de interaccion de un objeto con transparencia
func _on_entrar_transparencia(area):
	if area is ControlTransparencia and area.global_position.y > get_parent().global_position.y:
		area.activar_transparencia()

# Salir del area de interaccion de un objeto con transparencia
func _on_salir_transparencia(area):
	if area is ControlTransparencia:
		area.desactivar_transparencia()
