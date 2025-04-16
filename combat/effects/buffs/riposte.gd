class_name Riposte extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			incoming_effect.value = incoming_effect.base_value + target.combat_handler.stats.damage
			incoming_effect.target = effect.caster
			incoming_intercepted = true
