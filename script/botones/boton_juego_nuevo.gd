extends TextureButton

@onready var screens = $/root/Juego.pantallas

func _on_pressed():
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	CharacterManager.change_player("noby")
	var starting_zone = ZoneManager.load("sala_p1n1")
	screens.pantalla_mundo.get_node("Mundo").recolocar_personaje(noby, starting_zone)
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("zona_dev_testing")
	screens.pantalla_mundo.get_node("Mundo").recolocar_personaje(dummy, dev_zone)
	screens.push(screens.pantalla_mundo)
	$/root/Juego/ControladorGuion.reiniciar()
	disabled = true
