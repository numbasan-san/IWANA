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

func on_apply(target: Character):
	var v = value
	var stats = target.combat_handler.stats
	var stat_var_name = stat.to_snake_case() + "_modifier"
	var stat_value = stats.get(stat_var_name)
	if type == Type.DEBUFF:
		v = -v
	stats.set(stat_var_name, stat_value + v)

func on_unapply(target: Character):
	var v = value
	var stats = target.combat_handler.stats
	var stat_var_name = stat.to_snake_case() + "_modifier"
	var stat_value = stats.get(stat_var_name)
	if type == Type.BUFF:
		v = -v
	stats.set(stat_var_name, stat_value + v)
