class_name Burnt extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is LastingEffect and effect.type == LastingEffect.Type.BUFF:
		effect.is_nullified = true
