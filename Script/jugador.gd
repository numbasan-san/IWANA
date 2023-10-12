
extends CharacterBody2D

var axis : Vector2
var last_vector : String
var sprite_in_turn : Texture
var anim = ''

@export var inventory : Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Animation".play("stop_player_down")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#	velocity = direccion * 200
#	move_and_slide()

	velocity.x = get_axis().x * 200
	velocity.y = get_axis().y * 200
	move_and_slide()
	
	if get_axis().y == -1:
		anim = "up_2"
		last_vector = 'u'
	if get_axis().y == 1:
		anim = "down_2"
		last_vector = 'd'
	if get_axis().x == -1:
		anim = "left_2"
		last_vector = 'l'
	if get_axis().x == 1:
		anim = "right_2"
		last_vector = 'r'
	$"Animation".play("walk_player_" + anim)
	
	if  get_axis().x == 0 and get_axis().y == 0:
		$"Animation".stop()
		var stop_anim = {"u": "stop_player_up", "d": "stop_player_down", "r": "stop_player_right", 	"l": "stop_player_left"}
		for i in stop_anim:
			if last_vector == i:
				$Animation.play(stop_anim[last_vector])
	
func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed('ui_right') or Input.is_key_pressed(KEY_D)) - int(Input.is_action_pressed('ui_left') or Input.is_key_pressed(KEY_A))
	axis.y =  int(Input.is_action_pressed('ui_down') or Input.is_key_pressed(KEY_S)) - int(Input.is_action_pressed('ui_up') or Input.is_key_pressed(KEY_W))
	return axis.normalized()

func _on_hurt_box_area_entered(area):
	if area.has_method('collect'):
		area.collect(inventory)
