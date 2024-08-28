class_name LifeSwitch extends Effect

func on_apply(target: Character):
	var caster_health = caster.combat_handler.stats.health
	var target_health = target.combat_handler.stats.health
	caster.combat_handler.stats.health = target_health
	target.combat_handler.stats.health = caster_health
