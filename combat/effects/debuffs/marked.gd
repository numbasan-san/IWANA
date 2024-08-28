class_name Marked extends LastingEffect

func intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL and not effect.is_critical:
			# This assumes that a critical always multiplies by 2, which won't
			# be the case (some skills can increase critical damage). Does the
			# critical damage depend on the character doing the damage?
			effect.value *= 2
			effect.is_critical = true
			
			interception = true
