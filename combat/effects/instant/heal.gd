class_name Heal extends Effect

func on_apply(target: Character):
	target.combat_handler.stats.health += value
