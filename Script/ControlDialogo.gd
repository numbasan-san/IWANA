extends Node

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Detectamos que teclas se estan presionando para continuar o
# retroceder el dialogo
func _input(event):

	if event.is_action_pressed("nv_avanzar_dialogo"):
		controladorPantalla.transicion(controladorPantalla.pantallaMundo)
