class_name Shield extends LastingEffect

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			if effect.value <= value:
				effect.is_nullified
				value -= effect.value
			else:
				effect.value -= value
				value = 0
			interception = true
