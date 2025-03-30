class_name Marked extends InModingEffect

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL and not effect.is_critical:
			effect.is_critical = true
			
			interception = true
