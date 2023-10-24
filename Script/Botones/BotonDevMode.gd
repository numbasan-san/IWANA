extends TextureButton

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

func _on_pressed():
	get_node("/root/Juego").toggleDevMode()
	
