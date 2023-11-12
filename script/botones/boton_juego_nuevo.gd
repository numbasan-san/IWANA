extends TextureButton

@onready var pantallas = $/root/Juego.pantallas

# Esto es una variable temporal para mostrar correctamente el modo
# dev al comenzar el juego. Hay que reemprazarlo por mejor código despues
@export var boton_dev: BaseButton

func _on_pressed():
	# Código temporal del prototipo para cargar personajes en modo dialogo
	# Cambiar cuando esté listo el gestor de escenas
	var noby = $/root/Juego.cargar_personaje("noby")
	$/root/Juego/Personajes.cambiar_jugador("noby")
	var zona_ini = $/root/Juego.cargar_zona("sala_p1n1")
	pantallas.pantalla_mundo.get_node("Mundo").recolocar_personaje(noby, zona_ini)
	var dummy = $/root/Juego.cargar_personaje("dummy")
	var zona_dev = $/root/Juego.cargar_zona("zona_dev_testing")
	pantallas.pantalla_mundo.get_node("Mundo").recolocar_personaje(dummy, zona_dev)
	pantallas.push(pantallas.pantalla_mundo)
	$/root/Juego/ControladorGuion.reiniciar()
	disabled = true
