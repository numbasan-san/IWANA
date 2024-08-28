## Temporarily raises the damage of the target by a percent of the initial value.
class_name DamageBuff extends LastingEffect

func on_apply(target: Character):
	# The damage modifier is a number that is multiplied by the base damage, and
	# because we are assuming that value is a percentage, we divide by 100
	# before adding it. For example, if the initial modifier is 1 and we are
	# buffing for 50%, value/100 = 0.5 so the final modifier is 1.5
	target.combat_handler.stats.damage_modifier += value/100

func on_unapply(target: Character):
	target.combat_handler.stats.damage_modifier -= value/100
