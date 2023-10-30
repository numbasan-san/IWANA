extends TextureButton

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

func _on_pressed():
	# Código temporal del prototipo para cargar personajes en modo dialogo
	# Cambiar cuando esté listo el gestor de escenas
	var contenidosDialogo = controladorPantalla.pantallaDialogo.find_child("ContenidosDialogo")
	var noby = $/root/Juego.cargar_personaje("noby")
	noby.control_jugador = true
	var dani = $/root/Juego.cargar_personaje("daniela")
	var zona_ini = $/root/Juego.cargar_zona("sala_p1n1")
	print("Zona inicial: " + str(zona_ini))
	$/root/Juego/PantallaMundo/Mundo.recolocar_personaje(noby, zona_ini)
	contenidosDialogo.agregarPersonaje(noby, contenidosDialogo.Posicion.IZQUIERDA)
	contenidosDialogo.agregarPersonaje(dani, contenidosDialogo.Posicion.DERECHA)
	controladorPantalla.transicion(controladorPantalla.pantallaDialogo)
