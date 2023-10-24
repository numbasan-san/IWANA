extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var p = load("res://Escenas/Personajes/noby.tscn").instantiate() as Personaje
	var z = load("res://Escenas/Zonas/sala_p1n1.tscn").instantiate() as Zona
	add_child(z)
	moverPersonajeAZona(p, z, 200, 80)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Remueve el personaje de la zona en al que está actualmente y lo coloca
# en la zona nueva
func moverPersonajeAZona(personaje: Personaje, zona: Zona, x, y):
	var zonaAntigua = personaje.zona
	if zonaAntigua:
		zonaAntigua.borrarPersonaje(personaje)
	personaje.zona = zona
	zona.agregarPersonaje(personaje, x, y)
