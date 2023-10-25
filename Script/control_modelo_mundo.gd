
extends CharacterBody2D

var axis : Vector2
var last_vector : String
var sprite_in_turn : Texture
var anim = 'stop_player_down'

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Animation".play(anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
