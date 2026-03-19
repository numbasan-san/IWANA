class_name Spikes extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			for inc in incoming_effects:
				# TODO: The incoming branch of Spikes is supposed to be a single damage
				# effect, but chained effect allows several different effects.
				# If we wanted to attach several different effects, this code
				# wouldn't work, and if we wanted to restricts the effects to only
				# damage, we shouldn't use a chained effect.
				# We should consider if these effects shouldn't be a chain, but should
				# have their own dedicated script applying a hard coded effect.
				inc.value = inc.base_value + target.combat_handler.stats.defense
				inc.target = effect.caster
			incoming_intercepted = true
