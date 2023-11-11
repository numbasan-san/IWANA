extends AreaInteraccionGeneral

func interaccion(jugador: ControlJugador):
	print("El jugador " + str(jugador) + " a interactuado conmigo")
	var pantallas: Pantallas = $/root/Juego.pantallas
	pantallas.push(pantallas.pantalla_combate)
