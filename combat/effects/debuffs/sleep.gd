class_name Sleep extends LastingEffect

func before_turn(target: Character):
	target.combat_handler.incapacitated = true

func on_unapply(target: Character):
	target.combat_handler.incapacitated = false

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		target.combat_handler.remove_lasting_effect(self)
		
