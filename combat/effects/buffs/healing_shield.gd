class_name HealingShield extends LastingEffect

func intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			if effect.value <= value:
				effect.is_nullified
				value -= effect.value
			else:
				effect.value -= value
				value = 0

# This is assuming that the shield can block several attacks. If the heal is
# supposed to trigger after receiving the first attack, this should be moved to
# intercept
func before_turn(target: Character):
	duration -= 1

# TODO: this should be changed so it casts a healing effect instead. This
# could be done by creating a new type of effect called a LinkedEffect that
# triggers a second effect
func on_unapply(target: Character):
	if value > 0:
		target.combat_handler.stats.health += value
