class_name Shield extends LastingEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.value <= value:
			effect.is_nullified = true
			value -= effect.value
		else:
			effect.value -= value
			value = 0
		if value == 0:
			target.combat_handler.remove_lasting_effect(self)
		incoming_intercepted = true
