class_name Sleep extends ChainedEffect

func before_turn(target: Character):
	target.combat_handler.incapacitated = true

func on_unapply(target: Character):
	target.combat_handler.incapacitated = false

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		target.combat_handler.remove_lasting_effect(self)
		
