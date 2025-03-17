class_name Bleeding extends ChainedEffect

func on_intercept(effect: Effect):
	if effect is Heal:
		effect.value -= value
