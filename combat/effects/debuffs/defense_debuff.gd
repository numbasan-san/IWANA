## Temporarily lowers the defense of the target.
class_name DefenseDebuff extends LastingEffect

func on_apply(target: Character):
	# The defense modifier is a number that is added directly to the base defense
	# and because we are assuming that value is a percentage we can add it
	# directly. For example, if the initial modifier is 0 and we are
	# buffing for 20%, the final modifier is 20
	target.combat_handler.stats.defense_modifier += value

func on_unapply(target: Character):
	target.combat_handler.stats.defense_modifier -= value
