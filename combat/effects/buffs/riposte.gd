class_name Riposte extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			for inc in incoming_effects:
				inc.value = inc.base_value + target.combat_handler.stats.damage
				inc.target = effect.caster
			incoming_intercepted = true
