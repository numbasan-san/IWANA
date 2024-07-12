class_name RPGModel
extends CharacterBody2D

@onready var collider: CollisionShape2D = $Collider

var character: Character

var axis : Vector2
var sprite_in_turn : Texture
var anim = ''
var stop_anim = 'stop_down'
var direction: String = 'down'
var is_moving: bool = false

func _ready():
	if has_node("Animation"):
		# Initial stoping animation
		$Animation.play(stop_anim)

func _process(_delta):
	# If a leader is also following, it means we are controlling its follower
	# node directly or its moving as part of a predefined path. If the leader is
	# not following, it is being controlled from this function and it must draw
	# its party path as it moves
	if character.is_leader and not character.is_following and is_moving:
		character.party.path.add_point(position)
	
	# If a character is not following the leader then the axis is used to change
	# its velocity and to move it around. If it is following, the axis is just
	# used to change the direction it is looking at
	if not character.is_following:
		# Movement speed of the character models in world
		# Axis is currently only set from the player controler
		# so this code only executes for the character currently
		# controlled by the player
		velocity.x = axis.x * 800
		velocity.y = axis.y * 800
		move_and_slide()
	
	# Animations depending of the player direction
	if axis.y == -1: #Up
		direction = "up"
	if axis.y == 1: # Down
		direction = "down"
	if axis.x == -1: # Left
		direction = "left"
	if axis.x == 1: # Right
		direction = "right"
	
	anim = "walk_" + direction
	stop_anim = "stop_" + direction
	if has_node("Animation"):
		$Animation.play(anim)
	if  axis.x == 0 and axis.y == 0 and has_node("Animation"):
		# Stoping animation depending on the last direction the character was
		# moving
		$Animation.play(stop_anim)

func set_axis(x, y):
	axis = Vector2(x, y).normalized()
	is_moving = axis != Vector2(0, 0)

# Moves this model to a new position in the same zone
# If we want to move it to a different zone, we must use the reposition
# function in the Character object
func reposition(new_position: Vector2, new_direction: String):
	position = new_position
	direction = new_direction

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


func enable_collisions():
	collider.set_deferred("disabled", false)

func disable_collisions():
	collider.set_deferred("disabled", true)
