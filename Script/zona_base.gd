class_name Zona extends Node2D

var personajes: Array[Personaje]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Si esta zona no contiene a este personaje, lo agrega
func agregarPersonaje(personaje: Personaje):
	if not personajes.has(personaje):
		personajes.append(personaje)

# Si esta zona contiene al personaje, lo borra
func borrarPersonaje(personaje: Personaje):
	if personajes.has(personaje):
		personajes.erase(personaje)
		
