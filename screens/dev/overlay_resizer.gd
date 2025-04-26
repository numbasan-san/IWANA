class_name OverlayResizer extends Panel

## This control moves either vertically or horizontaly
@export var vertical_movement: bool
@export_enum("Top", "Left", "Bottom", "Right") var overlay_side: int

## If the mouse has been clicked over this control and it's been held.
var click_hold: bool = false

signal moved(delta: float)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("control_resize"):
		click_hold = true
		print("CLickHold: " + str(click_hold))
	elif event.is_action_released("control_resize"):
		click_hold = false
		print("CLickHold: " + str(click_hold))
	
	if event is InputEventMouseMotion and click_hold:
		var old: float
		var new: float
		if vertical_movement:
			# Because we are going to change the parent control, and this control
			# is anchored to it, we don't need to move this control, as resizing
			# parent will update it, so we only need to pass the current control
			# position and the mouse position, as that is where it is moving towards.
			old = global_position.y
			new = get_global_mouse_position().y
		else:
			old = global_position.x
			new = get_global_mouse_position().x
		
		print("Moved: " + str(new - old))
		moved.emit(new - old)
