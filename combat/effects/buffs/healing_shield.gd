class_name HealingShield extends ChainedEffect

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			if effect.value <= value:
				effect.is_nullified
				value -= effect.value
			else:
				effect.value -= value
				value = 0
				target.combat_handler.remove_lasting_effect(self)
			interception = true

func on_unapply(target: Character):
	unapply_effect.value = value
