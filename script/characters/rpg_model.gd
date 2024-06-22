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
	velocity.x = get_axis().x * 800
	velocity.y = get_axis().y * 800
	move_and_slide()
	
	# Animations depending of the player direction
	if get_axis().y == -1: #Up
		anim = 'walk_up'
		stop_anim = 'stop_up'
	if get_axis().y == 1: # Down
		anim = 'walk_down'
		stop_anim = 'stop_down'
	if get_axis().x == -1: # Left
		anim = 'walk_left'
		stop_anim = 'stop_left'
	if get_axis().x == 1: # Right
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

# Moves this model to a new position in the same zone
# If we want to move it to a different zone, we must use the reposition
# function in the Character object
func reposition(new_position: Vector2, new_direction: String):
	self.position = new_position
	anim = "walk_" + new_direction
	stop_anim = "stop_" + new_direction

# Activates processing, physics, visibility and other functionality of the character
func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	show()

# Deactivates processing, physics, visibility and other functionality of the character
func deactivate():
	hide()
	set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED

