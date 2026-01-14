class_name OverlayMover extends Panel

## If the mouse has been clicked over this control and it's been held.
var click_hold: bool = false

signal moved(delta: float)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("control_resize"):
		click_hold = true
	elif event.is_action_released("control_resize"):
		click_hold = false
	
	if event is InputEventMouseMotion and click_hold:
		var old: Vector2
		var new: Vector2
		# Because we are going to change the parent control, and this control
		# is anchored to it, we don't need to move this control, as moving
		# parent will update it, so we only need to pass the current control
		# position and the mouse position, as that is where it is moving towards.
		old = global_position
		new = get_global_mouse_position()
		
		moved.emit(new - old)
