extends AreaInteraccionGeneral

func interaccion(jugador: ControlJugador):
	print("El jugador " + str(jugador) + " a interactuado conmigo")
	var controlador_pantallas = $/root/Juego/ControladorPantallas
	controlador_pantallas.transicion(controlador_pantallas.pantallaCombate)
