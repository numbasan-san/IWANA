class_name Zone extends Node2D

# Por ahora esto está borrado. Si en el futuro tiene sentido preguntar
# a una zona por todos sus personajes, hay que habilitar esto
#var personajes: Array[Personaje]

# TODO: al igual que un nodo Personaje está separado en modelos para
# los diálogos, combate y mundo, y contiene variables relacionadas con todos
# los ámbitos, habría que cambiar las zonas para que representen su versión en
# modo diálogo, combate y mundo.

# --------------------------------------------------
# Estas funciones están borradas, ya que solo tienen sentido si hay que poblar
# el arreglo de Personajes. Cuando tenga sentido que una zona maneje a sus
# personajes, hay que habilitar estas funciones.

# Si esta zona no contiene a este personaje, lo agrega
# Esta función solo revisa que el personaje no exista en esta misma zona, pero
# no garantiza que no se haya agregado a otra zona, por lo que puede ocurrir que
# si se usa esta función, el mismo personaje exista en dos o más zonas. Para
# garantizar que solo exista en una única zona, hay que usar la función
# mover_personaje_a_zona en el script mundo.gd
#func agregarPersonaje(
#		personaje: Personaje,
#		posicion: Vector2 = Vector2(0, 0),
#		direccion: String = 'd'):
#	if not personajes.has(personaje):
#		personajes.append(personaje)
#		personaje.get_node("ModeloMundo").recolocar(self, posicion, direccion)
#
#
## Si esta zona contiene al personaje, lo borra
#func borrarPersonaje(personaje: Personaje):
#	if personajes.has(personaje):
#		personajes.erase(personaje)
#		personaje.zona = null
#
#		# Esto obtiene el nodo cuerpo del personaje, que es un duplicado del
#		# original. Cuando haya que guardar datos del personaje, verificar que al
#		# moverlo a otra zona esos datos no se pierdan
#		get_node(personaje.name.validate_node_name()).queue_free()

#-----------------------------------------------------

@export var spawn_points: Node

# Activates processing, phisics, visibility and other functionalities of a zone
func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	show()

# Deactivates processing, phisics, visibility and other functionalities of a zone
func deactivate():
	hide()
	set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED
