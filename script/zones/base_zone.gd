class_name Zone
extends Node2D

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

# Stores the points where characters can spawn. It's recommended
# that there is at least 1 spawn point for each entrance. If there are
# no spawn points, a default value is used (generaly point (0, 0))
@onready var spawn_points: Node = $SpawnPoints
@onready var tile_map: TileMap = $TileMap

# Stores the party path. When the player controled character enters the zone,
# a Path2D should be added here, and a PathFollow2D should be added to that
# path for each follower. As the player character moves more points should be
# added to the path, and when the character leaves the zone, the path should be
# deleted
@onready var party_path_node: Node = $PartyPath

# Thelayers and masks are stored so that they can be restored after
# reactivating the zone
var _collision_layers: Array[int]
var _collision_masks: Array[int]

func _ready():
	var n_phys_layers = tile_map.tile_set.get_physics_layers_count()
	var i = 0
	while i < n_phys_layers:
		_collision_layers.append(tile_map.tile_set.get_physics_layer_collision_layer(i))
		_collision_masks.append(tile_map.tile_set.get_physics_layer_collision_mask(i))
		i += 1

# Activates processing, phisics, visibility and other functionalities of a zone
func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	var n_phys_layers = tile_map.tile_set.get_physics_layers_count()
	var i = 0
	while i < n_phys_layers:
		tile_map.tile_set.set_physics_layer_collision_layer(i, _collision_layers[i])
		tile_map.tile_set.set_physics_layer_collision_mask(i, _collision_masks[i])
		i += 1
	show()

# Deactivates processing, phisics, visibility and other functionalities of a zone
func deactivate():
	hide()
	var n_phys_layers = tile_map.tile_set.get_physics_layers_count()
	var i = 0
	while i < n_phys_layers:
		tile_map.tile_set.set_physics_layer_collision_layer(i, 0)
		tile_map.tile_set.set_physics_layer_collision_mask(i, 0)
		i += 1
	set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED

# When the player character enters the zone, this function should be invoked
# The function receives a reference to the path to put it in the scene tree, but
# the actual path is modified in the Player object
func add_party_path(path: PartyPath):
	# There should never be another path when we call this function, but
	# we test just in case
	if party_path_node.get_child_count() != 0:
		clear_party_path()
	party_path_node.add_child(path)

# When the player character leaves the zone, this function should be invoked
func clear_party_path():
	for n in party_path_node.get_children():
		party_path_node.remove_child(n)
