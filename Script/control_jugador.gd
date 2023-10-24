extends "res://Script/control_modelo_mundo.gd"

@export var inventory : Inventory

func _on_hurt_box_area_entered(area):
	if area.has_method('collect'):
		area.collect(inventory)

# TODO: cambiar esto para que lea una acción de movimiento custom, que no lea
# teclas directamente
func _input(event):
	var x = int(event.is_action_pressed('rpg_right')) - int(event.is_action_pressed('rpg_left'))
	var y = int(event.is_action_pressed('rpg_down')) - int(event.is_action_pressed('rpg_up'))
	set_axis(x, y)
