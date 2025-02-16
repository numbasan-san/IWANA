class_name Stun extends LastingEffect

func before_turn(target: Character):
	target.combat_handler.incapacitated = true

func on_unapply(target: Character):
	target.combat_handler.incapacitated = false
