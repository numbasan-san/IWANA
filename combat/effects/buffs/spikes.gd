class_name Spikes extends ChainedEffect

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			var return_damage = intercept_effect.copy()
			return_damage.value *= 1 + target.combat_handler.stats.defense/100.0
			return_damage.target = effect.caster
			effect.caster.combat_handler.receive(return_damage)
			interception = true
