extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Remueve el personaje de la zona en al que está actualmente y lo coloca
# en la zona nueva
func moverPersonajeAZona(personaje: Personaje, zona: Zona):
	var zonaAntigua = personaje.zona
	if zonaAntigua:
		zonaAntigua.borrarPersonaje(personaje)
	personaje.zona = zona
	zona.agregarPersonaje(personaje)
