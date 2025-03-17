class_name Riposte extends ChainedEffect

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			intercept_effect.value = intercept_effect.base_value + target.combat_handler.stats.damage
			intercept_effect.target = effect.caster
			interception = true
