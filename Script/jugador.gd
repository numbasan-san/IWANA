
extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("anim")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * 200
	move_and_slide()
