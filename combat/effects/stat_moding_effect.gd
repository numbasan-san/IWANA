class_name StatModingEffect extends LastingEffect

# This class should be used to define both buffs and debuffs that directly
# modify the stats of the target

@export_enum(
	"Max Health",
	"Max Energy",
	"Damage",
	"Defense",
	"Speed",
	"Critical",
	"Precision",
	"Evasion"
) var stat: String

# If it's true it means that the corresponding stat's modifier is added to its
# base value. If false, it is multiplied by it.
# TODO: If we change the stat system to be more general and extensible, each stat
# should have an internal variable that says if its additive or not
@export var additive_modifier: bool

func on_apply(target: Character):
	var v = value
	var stats = target.combat_handler.stats
	var stat_var_name = stat.to_snake_case() + "_modifier"
	var stat_value = stats.get(stat_var_name)
	if additive_modifier:
		if type == Type.DEBUFF:
			v = -v
		stats.set(stat_var_name, stat_value + v)
	else:
		if type == Type.DEBUFF:
			v = 1/v
		stats.set(stat_var_name, stat_value * v)

func on_unapply(target: Character):
	var v = value
	var stats = target.combat_handler.stats
	var stat_var_name = stat.to_snake_case() + "_modifier"
	var stat_value = stats.get(stat_var_name)
	if additive_modifier:
		if type == Type.BUFF:
			v = -v
		stats.set(stat_var_name, stat_value + v)
	else:
		if type == Type.BUFF:
			v = 1/v
		stats.set(stat_var_name, stat_value * v)
