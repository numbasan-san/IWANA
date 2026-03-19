class_name Marked extends LastingEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			effect.is_critical = true
			
			incoming_intercepted = true
