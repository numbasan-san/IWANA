class_name Burnt extends ChainedEffect

func on_apply(target: Character):
	for effect in target.combat_handler.lasting_effects:
		if effect.type == LastingEffect.Type.BUFF:
			effect.value -= value

func on_incoming(effect: Effect):
	if effect is LastingEffect and effect.type == LastingEffect.Type.BUFF:
		effect.value -= value

func on_unapply(target: Character):
	for effect in target.combat_handler.lasting_effects:
		if effect.type == LastingEffect.Type.BUFF:
			effect.value += value
