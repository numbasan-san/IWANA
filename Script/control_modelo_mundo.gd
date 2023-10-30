
extends CharacterBody2D

var personaje: Personaje

var axis : Vector2
var sprite_in_turn : Texture
var anim = ''
var stop_anim = 'stop_player_down'

# Called when the node enters the scene tree for the first time.
func _ready():
	personaje = $".."
	$Animation.play(stop_anim) # Animación de "parado" inicial.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Se establece la velocidad de movimiento del avatar del jugador.
	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	# Las animaciones según por donde se mueva el personaje.
	if get_axis().y == -1:
		anim = 'walk_player_up'
		stop_anim = 'stop_player_up'
	if get_axis().y == 1:
		anim = 'walk_player_down'
		stop_anim = 'stop_player_down'
	if get_axis().x == -1:
		anim = 'walk_player_left'
		stop_anim = 'stop_player_left'
	if get_axis().x == 1:
		anim = 'walk_player_right'
		stop_anim = 'stop_player_right'
	$Animation.play(anim)
	if  get_axis().x == 0 and get_axis().y == 0:
		# La "animación" de "parado" según la última dirección a la que se movió el jugador.
		# Se establece en las condicionales anteriores.
		$Animation.play(stop_anim)
	
func get_axis() -> Vector2:
	return axis

func set_axis(x, y):
	axis = Vector2(x, y).normalized()

# Mueve este modelo a una nueva posición, potencialmente en una zona distinta

# Nota: esta funcionalidad no activa o desactiva las zonas, o cambia el padre de
# esas zonas, solo afecta al personaje. Esta función solo debe ser llamada desde
# la función recolocar_personaje en el script mundo, y hay que usar esa función
# directamente para manejar el cambio de zonas en el juego

func recolocar(zona_nueva: Zona, posicion: Vector2, direccion: String):
	# Si el modelo no está en ninguna zona, el padre será el contenedor Personaje
	var zona_actual = get_parent()
	# Si lo traemos a una zona por primera vez, hay que mostrar el nodo
	if not zona_actual is Zona:
		show()
	
	# Si estamos moviendo a una zona distinta, cambiamos el padre de este nodo
	if zona_nueva != zona_actual:
		zona_actual.call_deferred("remove_child", self)
		zona_nueva.call_deferred("add_child", self)
	
	self.position = posicion
	last_vector = direccion

# Quita a este modelo de la zona actual y lo devuelve a su contenedor Personaje
func quitar_zona():
	hide()
	get_parent().call_deferred("remove_child", self)
	personaje.call_deferred("add_child", self)

# Activa proceso, fisica, visibilidad y otras funcionalidades de un personaje
func activar():
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	show()

# Desactiva proceso, fisica, visibilidad y otras funcionalidades de un personaje
func desactivar():
	hide()
	set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED

