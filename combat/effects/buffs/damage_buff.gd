class_name DamageBuff extends LastingEffect

func on_apply(target: Character):
	target.combat_handler.stats.damage_modifier *= value

func on_unapply(target: Character):
	target.combat_handler.stats.damage_modifier /= value

func after_turn(target: Character):
	duration -= 1
