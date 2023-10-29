
extends CharacterBody2D

var personaje: Personaje

var axis : Vector2
var last_vector : String
var sprite_in_turn : Texture
var anim = 'stop_player_down'

# Called when the node enters the scene tree for the first time.
func _ready():
	personaje = $".."
	$"Animation".play(anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	if get_axis().y == -1:
		anim = "walk_player_up"
		last_vector = 'u'
	if get_axis().y == 1:
		anim = "walk_player_down"
		last_vector = 'd'
	if get_axis().x == -1:
		anim = "walk_player_left"
		last_vector = 'l'
	if get_axis().x == 1:
		anim = "walk_player_right"
		last_vector = 'r'
	$"Animation".play(anim)
	
	if  get_axis().x == 0 and get_axis().y == 0:
		$"Animation".stop()
		var stop_anim = {"u": "stop_player_up", "d": "stop_player_down", "r": "stop_player_right", 	"l": "stop_player_left"}
		for i in stop_anim:
			if last_vector == i:
				$Animation.play(stop_anim[last_vector])
	
func get_axis() -> Vector2:
	return axis

func set_axis(x, y):
	axis = Vector2(x, y).normalized()

# Mueve este modelo a una nueva posición, potencialmente en una zona distinta
func recolocar(zona_nueva: Zona, posicion: Vector2, direccion: String):
	# Si el modelo no está en ninguna zona, el padre será el contenedor Personaje
	var zona_actual = get_parent()
	# Si lo traemos a una zona por primera vez, hay que mostrar el nodo
	if not zona_actual is Zona:
		show()
	
	# Si estamos moviendo a una zona distinta, cambiamos el padre de este nodo
	if zona_nueva != zona_actual:
		zona_actual.remove_child(self)
		zona_nueva.add_child(self)
	
	self.position = posicion
	last_vector = direccion

# Quita a este modelo de la zona actual y lo devuelve a su contenedor Personaje
func quitar_zona():
	hide()
	get_parent().remove_child(self)
	personaje.add_child(self)
