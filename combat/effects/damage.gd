class_name DamageEffect extends Effect

# Lists the possible types this damage effect can have. Different buffs, 
# debuffs and properties of the target can modify this effect and apply it in
# different ways depending on its type
enum DamageType { PHYSICAL, TRUE, POISON }
@export var type: DamageType

# Tells if this damage effect has been augmented for being critical damage.
# The target could behave differently or modify this effect depending on if
# it's a critical hit or not
var is_critical: bool = false

func on_cast(caster: Character):
	var c_damage = caster.combat_handler.stats.damage
	var c_crit = caster.combat_handler.stats.critical
	var rnd = randi_range(1, 100)
	value *= c_damage
	is_critical = c_crit >= rnd
	

func on_apply(target: Character):
	# Defense is a value from 0 to 100 that acts as a percentage. We turn into a
	# value from 0 to 1
	var t_defense = float(target.combat_handler.stats.defense) / 100
	# This is the value that we're multiplying by the incoming damage.
	var mod = 1 - t_defense
	value = value * mod
	if is_critical:
		value *= 2
	
	target.combat_handler.stats.health -= value
