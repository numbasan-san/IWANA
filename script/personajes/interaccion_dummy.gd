extends AreaInteraccionGeneral

func interaccion(jugador: ControlJugador):
	print("El jugador " + str(jugador) + " a interactuado conmigo")
	ScreenManager.push(ScreenManager.combat_screen)
