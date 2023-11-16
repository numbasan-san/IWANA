extends Pantalla


@onready var controlador_guion = $"/root/Juego/ControladorGuion"

# Detecta cuando el usuario presiona un botón para avanzar el diálogo. No debe
# tener efecto cuando se está ejecutando otro tipo de instrucción
# TODO: arreglar esto para que los diálogos se demoren un poco en imprimir sus
# contenidos, y presionar el botón de avanzar diálogo solo lo apura y no pasa al
# diálogo siguiente
func _unhandled_input(event):
	if event.is_action_pressed("nv_avanzar_dialogo"):
		controlador_guion.continuar.emit()
