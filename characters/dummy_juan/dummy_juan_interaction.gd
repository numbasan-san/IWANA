extends GeneralInteractionArea

var dummy_juan: Character
@export var test_quests: Array[Quest]

func _start_battle():
	
	if dummy_juan:
		dummy_juan = $"..".character

func disable():
	$CollisionShape2D.disabled = true
