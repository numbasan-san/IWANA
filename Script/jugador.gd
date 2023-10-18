
extends CharacterBody2D

var axis : Vector2
var sprite_in_turn : Texture
var anim = ''
var stop_anim = 'stop_player_down'

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play(stop_anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	if get_axis().y == -1:
		anim = "walk_player_up"
		stop_anim = 'stop_player_up'
	elif get_axis().y == 1:
		anim = "walk_player_down"
		stop_anim = 'stop_player_down'
	elif get_axis().x == -1:
		anim = "walk_player_left"
		stop_anim = 'stop_player_left'
	elif get_axis().x == 1:
		anim = "walk_player_right"
		stop_anim = 'stop_player_right'
	$"Animation".play(anim)
	if  get_axis().x == 0 and get_axis().y == 0:
		$"Animation".stop()
		$Animation.play(stop_anim)
	
func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed('ui_right') or Input.is_key_pressed(KEY_D)) - int(Input.is_action_pressed('ui_left') or Input.is_key_pressed(KEY_A))
	axis.y =  int(Input.is_action_pressed('ui_down') or Input.is_key_pressed(KEY_S)) - int(Input.is_action_pressed('ui_up') or Input.is_key_pressed(KEY_W))
	return axis.normalized()
