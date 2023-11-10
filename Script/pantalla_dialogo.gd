extends Pantalla


@onready var controlador_guion = $"/root/Juego/ControladorGuion"

func _input(event):
	if event.is_action_pressed("nv_avanzar_dialogo"):
		controlador_guion.continuar.emit()
