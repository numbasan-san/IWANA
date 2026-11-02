class_name CleanseBurntEffect extends Effect

func on_apply(target: Character):
	var handler = target.combat_handler

	for eff in handler.lasting_effects.duplicate():
		if eff is Burnt:
			handler.remove_lasting_effect(eff)
