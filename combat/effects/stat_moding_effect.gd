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

func init_base_data():
	if base_data == null:
		base_data = EffectBaseData.new()
		base_data.name = stat + " " + Type.keys()[type]
		if type == Type.BUFF:
			base_data.description = "Increases the " + stat.to_lower() + " stat by " + \
				str(value)
			base_data.icon = load("res://combat/effects/buffs/stat_buff_icon.tres")
		elif type == Type.DEBUFF:
			base_data.description = "Decreases the " + stat.to_lower() + " stat by " + \
				str(value) 
			base_data.icon = load("res://combat/effects/debuffs/stat_debuff_icon.tres")

func on_apply(target: Character):
	var v = value
	if type == Type.DEBUFF:
		v = -v
	_stat_change(v)

func on_unapply(target: Character):
	var v = value
	if type == Type.BUFF:
		v = -v
	_stat_change(v)

func is_same_type(other: Effect) -> bool:
	return super.is_same_type(other) \
	# Here type refers to if the effect is a buff or debuff.
		and type == other.type \
		and stat == other.stat

func _stat_change(v):
	var stats = target.combat_handler.stats
	var stat_var_name = stat.to_snake_case() + "_modifier"
	var stat_value = stats.get(stat_var_name)
	stats.set(stat_var_name, stat_value + v)
