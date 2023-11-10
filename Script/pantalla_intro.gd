extends Pantalla

func _ready():
	transiciones.animation_finished.connect(push_inicial, CONNECT_ONE_SHOT)

func _input(event):
	if event.is_action_released("skip"):
		print("Skiping intro")
		var delta = transiciones.current_animation_length - transiciones.current_animation_position
		transiciones.seek(delta, true)

func push_inicial(_anim_name):
	var pantallas = $/root/Juego/ControladorPantallas
	pantallas.push(pantallas.pantalla_menu_inicial)
