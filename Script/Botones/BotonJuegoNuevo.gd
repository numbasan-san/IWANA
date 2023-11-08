extends TextureButton

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

# Esto es una variable temporal para mostrar correctamente el modo
# dev al comenzar el juego. Hay que reemprazarlo por mejor código despues
@export var boton_dev: BaseButton

func _on_pressed():
	# Código temporal del prototipo para cargar personajes en modo dialogo
	# Cambiar cuando esté listo el gestor de escenas
	if boton_dev.is_pressed():
		$/root/Juego/DevMode.habilitar()
	var contenidosDialogo = controladorPantalla.pantallaDialogo.find_child("ContenidosDialogo")
	var noby = $/root/Juego.cargar_personaje("noby")
	$/root/Juego/Personajes.cambiar_jugador("noby")
	var dani = $/root/Juego.cargar_personaje("daniela")
	var zona_ini = $/root/Juego.cargar_zona("sala_p1n1")
	$/root/Juego/PantallaMundo/Mundo.recolocar_personaje(noby, zona_ini)
	var dummy = $/root/Juego.cargar_personaje("dummy")
	var zona_dev = $/root/Juego.cargar_zona("zona_dev_testing")
	$/root/Juego/PantallaMundo/Mundo.recolocar_personaje(dummy, zona_dev)
	contenidosDialogo.agregarPersonaje(noby, contenidosDialogo.Posicion.IZQUIERDA)
	contenidosDialogo.agregarPersonaje(dani, contenidosDialogo.Posicion.DERECHA)
	$/root/Juego/ControladorGuion.reiniciar()
	disabled = true
