class_name Taunt extends LastingEffect

func on_apply(target: Character):
	target.combat_handler.target_weight += value

func on_unapply(target: Character):
	target.combat_handler.target_weight -= value
