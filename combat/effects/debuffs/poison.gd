class_name Poison extends ChainedEffect

func on_apply(target: Character):
	target.combat_handler.stats.defense_modifier -= base_value

func on_unapply(target: Character):
	target.combat_handler.stats.defense_modifier += base_value
