class_name DamageEffect extends Effect

# Lists the possible types this damage effect can have. Different buffs, 
# debuffs and properties of the target can modify this effect and apply it in
# different ways depending on its type
enum DamageType { PHYSICAL, TRUE, BLEEDING, POISON, FIRE }
@export var type: DamageType

## What percentage of the target's defense is ignored.
##
## This is only used for physical damage, as other types ignore defense.
@export_range(0, 100, 1) var percentage_ignored: float = 0

# Tells if this damage effect has been augmented for being critical damage.
# The target could behave differently or modify this effect depending on if
# it's a critical hit or not
var is_critical: bool = false

func on_cast(caster: Character):
	var c_damage = caster.combat_handler.stats.damage
	value *= c_damage
	# If is_critical was already true we leave it like that to guarantee a crit
	if not is_critical:
		var c_crit = caster.combat_handler.stats.critical
		var rnd = randi_range(1, 100)
		is_critical = c_crit >= rnd

func on_apply(target: Character):
	if type == DamageType.PHYSICAL:
		var defense = target.combat_handler.stats.defense
		value -= defense * (1 - percentage_ignored / 100)
	if is_critical:
		value *= 2
	
	# This guarantees that the value is not greater than the target's health, so
	# that the damage icons show the actual damage done and life steal skills only
	# heal for the damage done.
	value = clampf(value, 0, target.combat_handler.stats.health)
	target.combat_handler.stats.health -= value
