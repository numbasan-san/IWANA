extends "res://Script/control_modelo_mundo.gd"

@export var inventory : Inventory

# TODO: cambiar esto para que lea una acción de movimiento custom, que no lea
# teclas directamente

# Movimiento del avatar.
func _process(delta):
	var x = int(Input.is_action_pressed('rpg_right')) - int(Input.is_action_pressed('rpg_left'))
	var y = int(Input.is_action_pressed('rpg_down')) - int(Input.is_action_pressed('rpg_up'))
	set_axis(x, y)
	
	super._process(delta)

# Las colisiones con objetos cuya colisión tenga una función o evento en especial.
func _on_hurt_box_area_entered(area):
	if area.has_method('collect'): # La colisión del avatar del jugador con un objeto.
		if inventory.count_empty_slot() >= 1: # En caso de que haya espacio en el inventario.
			area.collect(inventory)
		else: # En caso no haya espacio en el inventario.
			# Se verifica si en el último espacio del inventario hay espacio en el stack del ítem en turno.
			if inventory.count_stacks():
				area.collect(inventory)

	# La colisión del avatar del jugador con una "puerta".
	if area.has_method('change_zone'):
		area.change_zone(personaje)
