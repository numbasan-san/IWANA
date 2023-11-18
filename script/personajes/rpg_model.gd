class_name ModeloRPG
extends CharacterBody2D

var character: Character

var axis : Vector2
var sprite_in_turn : Texture
var anim = ''
var stop_anim = 'stop_down'

func _ready():
	character = $".."
	if has_node("Animation"):
		# Initial stoping animation
		$Animation.play(stop_anim)

func _process(_delta):
	# Movement speed of the character models in world
	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	# Animations depending of the player direction
	#Up
	if get_axis().y == -1:
		anim = 'walk_up'
		stop_anim = 'stop_up'
	# Down
	if get_axis().y == 1:
		anim = 'walk_down'
		stop_anim = 'stop_down'
	# Left
	if get_axis().x == -1:
		anim = 'walk_left'
		stop_anim = 'stop_left'
	# Right
	if get_axis().x == 1:
		anim = 'walk_right'
		stop_anim = 'stop_right'
	if has_node("Animation"):
		$Animation.play(anim)
	if  get_axis().x == 0 and get_axis().y == 0 and has_node("Animation"):
		# Stoping animation depending on the last direction the character was
		# moving
		$Animation.play(stop_anim)
	
func get_axis() -> Vector2:
	return axis

func set_axis(x, y):
	axis = Vector2(x, y).normalized()

# Moves this character to a new position, potentially in a new zone
# Note: This function doesn't activate or deactivate the zones, it only affects
# the player. This function must be called from the character_reposition in the
# world node, or from another function that's called by that one, to ensure that
# the zones will be updated correctly
func reposition(new_zone: Zona, new_position: Vector2, new_direction: String):
	# If the model isn't in any zone, it will be the Character container
	var current_zone = get_parent()
	# If we bring it to a zone for the first time, we must activate the node
	if not current_zone is Zona:
		activate()
	
	# If we are moving to a different zone, we change the parent of this node
	if new_zone != current_zone:
		current_zone.call_deferred("remove_child", self)
		new_zone.call_deferred("add_child", self)
	
	self.position = new_position
	anim = "walk_" + new_direction
	stop_anim = "stop_" + new_direction

# Removes this model from the current zone and returns it to its Character container
func remove_from_zone():
	hide()
	get_parent().call_deferred("remove_child", self)
	character.call_deferred("add_child", self)

# Activates processing, physics, visibility and other functionality of the character
func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	show()

# Deactivates processing, physics, visibility and other functionality of the character
func desactivar():
	hide()
	set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED

