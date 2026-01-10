extends GeneralInteractionArea

var dummy_juan: Character

func _start_battle():
	dummy_juan = $"..".character

func disable():
	$CollisionShape2D.disabled = true
