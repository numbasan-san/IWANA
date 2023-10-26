extends "res://Script/control_modelo_mundo.gd"

@export var inventory : Inventory

# TODO: cambiar esto para que lea una acción de movimiento custom, que no lea
# teclas directamente
func _process(delta):
	var x = int(Input.is_action_pressed('rpg_right')) - int(Input.is_action_pressed('rpg_left'))
	var y = int(Input.is_action_pressed('rpg_down')) - int(Input.is_action_pressed('rpg_up'))
	set_axis(x, y)
	
	super._process(delta)

func _on_hurt_box_area_entered(area):
	if area.has_method('collect'):
		area.collect(inventory)
	if area.has_method('change_zone'):
		area.change_zone()
