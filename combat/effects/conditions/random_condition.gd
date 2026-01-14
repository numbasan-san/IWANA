class_name RandomCondition extends Condition

@export_range(0, 100) var probability:float = 50

func evaluate(caster: Character, target: Character) -> bool:
	# We check this case because the random function includes 0 and 100 as posible
	# outcomes, so p > r will fail on p == 100 if r == 100, and p >= r will
	# succeed on p == 0 if r == 0
	if probability == 100:
		return true
	else:
		var rnd = randf_range(0, 100)
		return probability > rnd
