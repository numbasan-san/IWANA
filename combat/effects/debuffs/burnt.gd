class_name Burnt extends ChainedEffect

func on_intercept(effect: Effect):
	if effect is LastingEffect and effect.Type == LastingEffect.Type.BUFF:
		effect.is_nullified = true
