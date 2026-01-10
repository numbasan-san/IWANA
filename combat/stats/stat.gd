class_name Stat extends Resource

# Signal triggered when the value of this stat changes
signal updated

@export_group("Limits")
@export var min_base: int = -9223372036854775808
@export var min_mod: float = -9223372036854775808
@export var min_value: int = -9223372036854775808
@export var max_base: int = 9223372036854775807
@export var max_mod: float = 9223372036854775807
@export var max_value: int = 9223372036854775807

@export_group("")

# The base value of the stat, without any modifiers or effects.
@export var base: int = 0:
	set(new_base):
		var old = value
		base = clampi(new_base, min_base, max_base)
		if old != value:
			updated.emit(old, value)

# The modifier applied to the stat. It depends on buffs and debuffs applied to
# the character.
var modifier: float = 1:
	set(new_mod):
		var old = value
		modifier = clampf(new_mod, min_mod, max_mod)
		if old != value:
			updated.emit(old, value)

# The final value of the stat, after applying modifiers.
var value: int:
	get:
		return get_value()

func _init(
	min_base = -9223372036854775808,
	max_base = 9223372036854775807,
	min_mod = -9223372036854775808,
	max_mod = 9223372036854775807,
	min_value = -9223372036854775808,
	max_value = 9223372036854775807
) -> void:
	self.min_base = min_base
	self.max_base = max_base
	self.min_mod = min_mod
	self.max_mod = max_mod
	self.min_value = min_value
	self.max_value = max_value

func get_value():
	return clampi(round(base * modifier), min_value, max_value)

# The clamp function from godot requires both a min value and a max value, so it
# isn't useful if we only want a min OR a max. Furthermore, godot doesn't
# provide constants for an int's minimal and maximal possible values, so we must
# write them directly. These functions help fix both those problems. If we had
# only one function with default values for min and max, when we only wanted to
# clamp to the max value we still would have to provide the int min value 
func _clampi_min(value: int, min: int):
	return clampi(value, min, 9223372036854775807)

func _clampi_max(value: int, max: int):
	return clampi(value, -9223372036854775808, max)

func _clampf_min(value: float, min: float):
	return clampf(value, min, 9223372036854775807)

func _clampf_max(value: float, max: float):
	return clampf(value, -9223372036854775808, max)

func _clamp_min():
	pass
func _clamp_max():
	pass
func _clamp(value, min, max):
	pass
