extends Screen


# Detects when the user presses a button to advance the dialog. It shouldn't
# have any effect when another instruction is being executed
# TODO: fix this so that dialog lines take some time to render to screen and
# pressing a button draws it faster instead of just skiping it
func _unhandled_input(event):
	if is_active and event.is_action_pressed("nv_avanzar_dialogo"):
		ScriptManager.unpaused.emit()
