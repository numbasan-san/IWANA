class_name BocajarroDefenseDebuff extends LastingEffect

func on_apply(target: Character):
	target.combat_handler.stats.defense_modifier -= value


func on_unapply(target: Character):
	target.combat_handler.stats.defense_modifier += value
