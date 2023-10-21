
extends CharacterBody2D

@export var inventario : Inventory

var axis : Vector2
<<<<<<< Updated upstream
var last_vector : String
var sprite_in_turn : Texture
var anim = 'stop_player_down'

@export var inventory : Inventory
=======
var anim = ''
var stop_anim = 'stop_player_down'
>>>>>>> Stashed changes

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Animation".play(anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	if get_axis().y == -1:
		anim = "walk_player_up_2"
		last_vector = 'u'
	if get_axis().y == 1:
		anim = "walk_player_down_2"
		last_vector = 'd'
	if get_axis().x == -1:
		anim = "walk_player_left_2"
		last_vector = 'l'
	if get_axis().x == 1:
		anim = "walk_player_right_2"
		last_vector = 'r'
	$"Animation".play(anim)
	
	if  get_axis().x == 0 and get_axis().y == 0:
		$"Animation".stop()
<<<<<<< Updated upstream
		var stop_anim = {"u": "stop_player_up", "d": "stop_player_down", "r": "stop_player_right", 	"l": "stop_player_left"}
		for i in stop_anim:
			if last_vector == i:
				$Animation.play(stop_anim[last_vector])
	
=======
		$Animation.play(stop_anim)

>>>>>>> Stashed changes
func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed('ui_right') or Input.is_key_pressed(KEY_D)) - int(Input.is_action_pressed('ui_left') or Input.is_key_pressed(KEY_A))
	axis.y =  int(Input.is_action_pressed('ui_down') or Input.is_key_pressed(KEY_S)) - int(Input.is_action_pressed('ui_up') or Input.is_key_pressed(KEY_W))
	return axis.normalized()

func _on_hurt_box_area_entered(area):
	if area.has_method('collect'):
<<<<<<< Updated upstream
		area.collect(inventory)
=======
		area.collect(inventario)
>>>>>>> Stashed changes
