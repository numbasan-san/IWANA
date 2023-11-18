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
		# Si la imagen recién está apareciendo, saltamos a la posición opuesta
		# para que comience a desaparecer sin mostrarse completamente
		if transiciones.current_animation_position < fin_fade_in:
			var delta = transiciones.current_animation_length - transiciones.current_animation_position
			transiciones.seek(delta, true)
		# Si todavía no comienza a desaparecer, saltamos a ese punto diréctamente
		elif transiciones.current_animation_position < inicio_fade_out:
			transiciones.seek(inicio_fade_out, true)
		# Si ya empezó a desaparecer, no hacemos nada

func push_inicial(anim_name):
	if anim_name == "Inicio":
		ScreenManager.push(ScreenManager.main_menu_screen)

func activar():
	transiciones.play("Inicio")
	super.activar()
