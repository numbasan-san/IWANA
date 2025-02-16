class_name SleepRegen extends ChainedEffect

func before_turn(target: Character):
	for eff in target.combat_handler.other_modifiers:
		if eff is Sleep:
			return
	# The target isn't sleeping, so we stop regen
	target.combat_handler.remove_lasting_effect(self)
