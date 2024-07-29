class_name Evasion extends ChainedEffect

func on_intercept(effect: Effect):
	effect.is_nullified = true
	interception = true
