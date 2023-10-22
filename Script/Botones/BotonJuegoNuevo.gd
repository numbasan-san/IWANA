extends TextureButton

@onready var controladorPantalla = $"/root/Juego/ControladorPantallas"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	# Código temporal del prototipo para cargar personajes en modo dialogo
	# Cambiar cuando esté listo el gestor de escenas
	var contenidosDialogo = controladorPantalla.pantallaDialogo.find_child("ContenidosDialogo")
	var noby = load("res://Escenas/Personajes/noby.tscn").instantiate()
	var dani = load("res://Escenas/Personajes/daniela.tscn").instantiate()
	contenidosDialogo.agregarPersonaje(noby, contenidosDialogo.Posicion.IZQUIERDA)
	contenidosDialogo.agregarPersonaje(dani, contenidosDialogo.Posicion.DERECHA)
	controladorPantalla.transicion(controladorPantalla.pantallaDialogo)
