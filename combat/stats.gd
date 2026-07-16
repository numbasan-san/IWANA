class_name Stats extends Resource

# These signals are used mainly to update labels in the different screens, so
# for now we only need to signal changes in the effective values, which means
# that when a change happens in the base or the modifier, we must emit the value
# of the product
signal update_max_health
signal update_max_energy
signal update_max_satiation
signal update_damage
signal update_defense
signal update_speed
signal update_critical
signal update_precision
signal update_evasion
signal update_health
signal update_energy
signal update_satiation

signal damage_received
signal health_recovered
signal energy_spent
signal energy_recovered

# Emitted when health reaches 0 or the character is affected by some other
# condition that prevents it from fighting
signal fainted
# Emitted when health goes from 0 to a higher value or is no longer affected by
# a condition that prevents it from fighting
signal raised

#The basic stats that every character has and influences combat
# Most values are clamped between a min and/or a max value for the base stats,
# the modifiers and the effective stats. Even though it would only be necessary
# to clamp the effective stats, we also clamp the others so they don't show
# forbiden values in menus or stat screens and because improving a stat that is
# under the minimum value would waste the improvement

# Health influences how long the character can survive
@export var base_max_health: int = 1:
	set(value):
		var old = max_health
		# This guarantees a minimum value of 1. If max_health where 0 or less, a
		# character would spawn dead and wouldn't be able to recover
		base_max_health = _clampi_min(value, 1)
		var new = max_health
		update_max_health.emit(old, new)
		# This ensures that health stays at or below the max health, and it also
		# triggers an update_health signal
		if health > new:
			health = new

# Energy influences how many skills the character can use
@export var base_max_energy: int = 0:
	set(value):
		var old = max_energy
		# This guarantees a minimum value of 0. If max_energy where less than 0,
		# there could be errors when executing skills or recovering energy
		base_max_energy = _clampi_min(value, 0)
		var new = max_energy
		update_max_energy.emit(old, new)
		# This ensures that energy stays at or below the max energy, and it also
		# triggers an update_energy signal
		if energy > new:
			energy = new

# Satiation influences how many items the character can consume
@export var base_max_satiation: int = 0:
	set(value):
		var old = max_satiation
		# This guarantees a minimum value of 0. If max_energy where less than 0,
		# there could be errors when executing skills or recovering energy
		base_max_satiation = _clampi_min(value, 0)
		var new = max_satiation
		update_max_satiation.emit(old, new)
		# This ensures that energy stays at or below the max energy, and it also
		# triggers an update_energy signal
		if satiation > new:
			satiation = new

# How much damage the character can do with their skills
@export var base_damage: int = 0:
	set(value):
		var old = damage
		# This guarantees a minimum value of 0. If damage where less than 0, 
		# when attacking it would heal the oponent
		base_damage = _clampi_min(value, 0)
		var new = damage
		update_damage.emit(old, new)

# Blocks a percentage of the incoming damage.
@export var base_defense: int = 0:
	set(value):
		var old = defense
		base_defense = _clampi_min(value, 0)
		var new = defense
		update_defense.emit(old, new)

# Influences the action order during combat. Characters with higher speed act
# first.
@export var base_speed: int = 0:
	set(value):
		var old = speed
		# We don't need to clamp this to positive values because speed
		# determines order, and negative values would always act after positive
		# ones, so it is consistent
		base_speed = value
		var new = speed
		update_speed.emit(old, new)

# Chance of doing a critical hit, which doubles the damage done with the skill.
@export var base_critical: int = 0:
	set(value):
		var old = critical
		base_critical = _clampi_min(value, 0)
		var new = critical
		update_critical.emit(old, new)

# Raw chance of hitting the target.
@export var base_precision: int = 100:
	set(value):
		var old = precision
		base_precision = _clampi_min(value, 0)
		var new = precision
		update_precision.emit(old, new)

# Raw chance of evading an attack.
@export var base_evasion: int = 0:
	set(value):
		var old = evasion
		base_evasion = _clampi_min(value, 0)
		var new = evasion
		update_evasion.emit(old, new)

# The following variables are additive modifiers that are applied to the base values
# and are changed with items and skills
var max_health_modifier: float = 0:
	set(value):
		var old = max_health
		# We don't clamp this value as negative values could be allowed to decrease
		# the max health from its initial value.
		max_health_modifier = value
		var new = max_health
		update_max_health.emit(old, new)
		# This ensures that health stays at or below the max health, and it also
		# triggers an update_health signal
		if health > new:
			health = new
		
var max_energy_modifier: float = 0:
	set(value):
		var old = max_energy
		max_energy_modifier = value
		var new = max_energy
		update_max_energy.emit(old, new)
		# This ensures that energy stays at or below the max energy, and it also
		# triggers an update_energy signal
		if energy > new:
			energy = new

var max_satiation_modifier: float = 0:
	set(value):
		var old = max_satiation
		max_satiation_modifier = value
		var new = max_satiation
		update_max_satiation.emit(old, new)
		# This ensures that satiation stays at or below the max satiation, and it also
		# triggers an update_satiation signal
		if satiation > new:
			satiation = new
		
var damage_modifier: float = 0:
	set(value):
		var old = damage
		damage_modifier = value
		var new = damage
		update_damage.emit(old, new)

var defense_modifier: float = 0:
	set(value):
		var old = defense
		defense_modifier = value
		var new = defense
		update_defense.emit(old, new)
		
var speed_modifier: float = 0:
	set(value):
		var old = speed
		speed_modifier = value
		var new = speed
		update_speed.emit(old, new)

var critical_modifier: float = 0:
	set(value):
		var old = critical
		critical_modifier = value
		var new = critical
		update_critical.emit(old, new)

var precision_modifier: float = 0:
	set(value):
		var old = precision
		precision_modifier = value
		var new = precision
		update_precision.emit(old, new)

var evasion_modifier: float = 0:
	set(value):
		var old = evasion
		evasion_modifier = value
		var new = evasion
		update_evasion.emit(old, new)

# The following variables are the effective stats of the characters after
# applying the modifiers, and they should be used by the combat code
var max_health: int:
	get:
		return _clampi_min(round(base_max_health + max_health_modifier), 1)
var max_energy: int:
	get:
		return _clampi_min(round(base_max_energy + max_energy_modifier), 0)
var max_satiation: int:
	get:
		return _clampi_min(round(base_max_satiation + max_satiation_modifier), 0)
var damage: int:
	get:
		return _clampi_min(round(base_damage + damage_modifier), 0)
var defense: int:
	get:
		return _clampi_min(round(base_defense + defense_modifier), 0)
		
var speed: int:
	get:
		return round(base_speed + speed_modifier)
# Because critical is a percentage from 0 to 100, the modifier is additive
# instead of multiplicative
var critical: int:
	get:
		return clampi(round(base_critical + critical_modifier), 0, 100)

var precision: int:
	get:
		return _clampi_min(round(base_precision + precision_modifier), 0)

var evasion: int:
	get:
		return _clampi_min(round(base_evasion + evasion_modifier), 0)

# Can't go above modified max_health or under 0. When this value reaches 0, the
# character is rendered unconscious
var health: int:
	set(value):
		var old = health
		health = clampi(value, 0, max_health)
		var new = health
		# If the values are the same we return to prevent emitting signals. We
		# don't use value as that doesn't include the clamping.
		if old == new:
			return
		update_health.emit(old, new)
		if new < old:
			# We use value in case the character received more damage than its
			# current hp to show the full damage taken
			damage_received.emit(old - value)
		if new > old:
			# We use value in case the character healed beyond its max health
			# to show the full recovery value
			health_recovered.emit(value - old)
		if new == 0:
			unconscious = true
			fainted.emit()
		# Because we return immediately when old == new, we only reach this
		# condition when we are going above 0 health
		if old == 0:
			unconscious = false
			raised.emit()

# Can't go above max_energy or below 0. If the character has less energy than
# required by a skill, they can't use it
var energy: int:
	set(value):
		var old = energy
		energy = clamp(value, 0, max_energy)
		var new = energy
		# If the values are the same we return to prevent emitting signals. We
		# don't use value as that doesn't include the clamping.
		if old == new:
			return
		update_energy.emit(old, new)
		if new < old:
			# We use value in case the character lost more energy than its
			# current value to show the full amount subtracted. This should only
			# be possible when losing energy because of an item, enemy skill or
			# story event, as when using a skill it should prevent spending more
			# energy than available
			energy_spent.emit(old - value)
		if new > old:
			# We use value in case the character recovered beyond its max energy
			# to show the full recovery value
			energy_recovered.emit(value - old)

# Can't go above max_satiation or below 0. If the character has less satiation than
# required by an item, they can't use it
var satiation: int:
	set(value):
		var old = satiation
		satiation = clamp(value, 0, max_satiation)
		var new = satiation
		# If the values are the same we return to prevent emitting signals. We
		# don't use value as that doesn't include the clamping.
		if old == new:
			return
		update_satiation.emit(old, new)

# When a character's health has reached 0 or is affected by some equivalent
# condition, the fainted signal is emited and this is set to true. When recovered
# and can fight again this is set to false. unconscious characters shouldn't be
# able to execute skills or be targeted by most skills, but can be the target of
# items
var unconscious: bool = false

# Restores health and energy
func replenish():
	health = max_health
	energy = max_energy

# The clamp function from godot requires both a min value and a max value, so it
# isn't useful if we only want a min OR a max. Furthermore, godot doesn't
# provide constant for an int's minimal and maximal possible values, so we must
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
