extends AreaInteraccionGeneral

func interaccion(jugador: ControlJugador):
	print("El jugador " + str(jugador) + " a interactuado conmigo")
	var controlador_pantallas = $/root/Juego/ControladorPantallas
	controlador_pantallas.push(controlador_pantallas.pantalla_combate)
