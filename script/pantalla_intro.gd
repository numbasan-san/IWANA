extends Pantalla

func _ready():
	transiciones.animation_finished.connect(push_inicial, CONNECT_ONE_SHOT)

func _input(event):
	if event.is_action_released("skip"):
		print("Skiping intro")
		# Este código asume una animación específica, y no va a servir cuando se
		# cambie o extienda. Hay que ver una manera de obtener los keyframes de
		# una pista para usar como referencia para saltar a una posición
		# específica
		var fin_fade_in = 2
		var inicio_fade_out = 4
		if transiciones.current_animation_position < fin_fade_in:
			var delta = transiciones.current_animation_length - transiciones.current_animation_position
			transiciones.seek(delta, true)
		else:
			transiciones.seek(inicio_fade_out, true)

func push_inicial(anim_name):
	if anim_name == "Inicio":
		var pantallas: Pantallas = $/root/Juego.pantallas
		pantallas.push(pantallas.pantalla_menu_inicial)

func activar():
	transiciones.play("Inicio")
	super.activar()
