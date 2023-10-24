class_name Zona extends Node2D

var personajes: Array[Personaje]

# TODO: al igual que un nodo Personaje está separado en modelos para
# los diálogos, combate y mundo, y contiene variables relacionadas con todos
# los ámbitos, habría que cambiar las zonas para que representen su versión en
# modo diálogo, combate y mundo.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Si esta zona no contiene a este personaje, lo agrega
func agregarPersonaje(personaje: Personaje, x, y):
	if not personajes.has(personaje):
		personajes.append(personaje)
		personaje.zona = self
		var nodoCuerpo = personaje.get_node("ModeloMundo/Cuerpo").duplicate()
		nodoCuerpo.name = personaje.name
		nodoCuerpo.position = Vector2(x, y)
		add_child(nodoCuerpo)

# Si esta zona contiene al personaje, lo borra
func borrarPersonaje(personaje: Personaje):
	if personajes.has(personaje):
		personajes.erase(personaje)
		personaje.zona = null
		get_node(personaje.name.validate_node_name()).queue_free()
		
