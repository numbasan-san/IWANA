class_name StatCondition extends Condition

## The character type from which the stats are being taken
@export_enum("Caster", "Target") var character: String = "Target"

## The name of the stat
@export_enum(
	"Health",
	"Max health",
	"Energy",
	"Max energy",
	"Damage",
	"Defense",
	"Speed",
	"Critical",
	"Precision",
	"Evasion"
) var stat: String = "Health"

## The operation used to compare the values
@export_enum(
	"<",
	"<=",
	">",
	">=",
	"="
) var operation: String = "<="

## The value to compare with the stat
@export var value: float

## If the value should be taken as a percentage or a direct number.
##
## For health and energy this determines if the value should be taken as is or
## as a percentage of the max health and max energy respectively. Damage and
## speed are always taken as a value, defense and critical are always taken as a
## percentage.
@export var percent: bool = false

func evaluate(caster: Character, target: Character) -> bool:
	var char: Character
	match character:
		"Caster":
			char = caster
		"Target":
			char = target
		_:
			return false
	var stats = char.combat_handler.stats
	var stat_var_name = stat.to_snake_case()
	var stat_value = stats.get(stat_var_name)
	if percent:
		if stat_var_name == "health":
			stat_value *= (100.0 / stats.max_health)
		elif stat_var_name == "energy":
			stat_value *= (100.0 / stats.max_energy)
	
	if stat_value == null:
		return false
	var op: Callable
	match operation:
		"<":
			return stat_value < value
		"<=":
			return stat_value <= value
		">":
			return stat_value > value
		">=":
			return stat_value >= value
		"=":
			return stat_value == value
		_:
			return false
