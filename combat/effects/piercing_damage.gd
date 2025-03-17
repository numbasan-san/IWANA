class_name PiercingDamage extends DamageEffect

@export_range(0, 100, 1) var percentage_ignored: float = 0

func on_apply(target: Character):
	if _hit(target):
		# In theory this type of effect should only be physical.
		if type == DamageType.PHYSICAL:
			var defense = target.combat_handler.stats.defense
			value -= defense * (1 - percentage_ignored / 100)
		if is_critical:
			value *= 2
		
		target.combat_handler.stats.health -= value
