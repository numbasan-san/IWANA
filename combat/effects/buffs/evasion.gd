class_name Evasion extends LastingEffect

func on_intercept(effect: Effect):
	effect.is_nullified = true
	interception = true
