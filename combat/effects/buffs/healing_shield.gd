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
			interception = true

# TODO: this should be changed so it casts a healing effect instead. This
# could be done by creating a new type of effect called a LinkedEffect that
# triggers a second effect
func on_unapply(target: Character):
	unapply_effect.value = value
