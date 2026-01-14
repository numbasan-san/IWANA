extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var collider = get_node("CollisionShape2D") as CollisionShape2D
	var viewport = get_viewport_rect()
	collider.shape.size = viewport.size
	print("Collider shape: " + str(collider.shape.get_rect()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
