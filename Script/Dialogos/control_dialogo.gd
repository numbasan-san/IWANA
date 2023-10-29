extends Node

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

# Detectamos que teclas se estan presionando para continuar o
# retroceder el dialogo
func _input(event):

	if event.is_action_pressed("nv_avanzar_dialogo"):
		controladorPantalla.transicion(controladorPantalla.pantallaMundo)
