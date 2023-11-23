class_name Stats extends Node

# These signals are used mainly to update labels in the different screens, so
# for now we only need to signal changes in the effective values, which means
# that when a change happens in the base or the modifier, we must emit the value
# of the product
signal update_max_health
signal update_max_energy
signal update_damage
signal update_defense
signal update_speed
signal update_critical
signal update_health
signal update_energy

#The basic stats that every character has and influences combat

# Health influences how long the character can survive
@export var base_max_health: int = 1:
	set(value):
		var old = max_health
		base_max_health = value
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
		base_max_energy = value
		var new = max_energy
		update_max_energy.emit(old, new)
		# This ensures that energy stays at or below the max energy, and it also
		# triggers an update_energy signal
		if energy > new:
			energy = new

# How much damage the character can do with their skills
@export var base_damage: int = 0:
	set(value):
		var old = damage
		base_damage = value
		var new = damage
		update_damage.emit(old, new)

# It was desided that the max defense a character can have before applying
# modifiers is 50. We store that in a variable in case we need to change it
var _max_base_defense = 50
# Blocks a percentage of the incoming damage
@export var base_defense: int = 0:
	set(value):
		var old = defense
		base_defense = min(value, _max_base_defense)
		var new = defense
		update_defense.emit(old, new)

# Influences the action order during combat. Characters with higher speed act
# first
@export var base_speed: int = 0:
	set(value):
		var old = speed
		base_speed = value
		var new = speed
		update_speed.emit(old, new)

# It isn't specified if there should be a max base critical chance, but 100% is
# a reasonable assumption
var _max_base_critical = 100
# Chance of doing a critical hit, which doubles the damage done with the skill
@export var base_critical: int = 0:
	set(value):
		var old = critical
		base_critical = min(value, _max_base_critical)
		var new = critical
		update_critical.emit(old, new)

# The following variables are multipliers that are applied to the base values
# and are changed with items and skills
var max_health_modifier: float = 1:
	set(value):
		var old = max_health
		max_health_modifier = value
		var new = max_health
		update_max_health.emit(old, new)
		# This ensures that health stays at or below the max health, and it also
		# triggers an update_health signal
		if health > new:
			health = new
		
var max_energy_modifier: float = 1:
	set(value):
		var old = max_energy
		max_energy_modifier = value
		var new = max_energy
		update_max_energy.emit(old, new)
		# This ensures that energy stays at or below the max energy, and it also
		# triggers an update_energy signal
		if energy > new:
			energy = new
		
var damage_modifier: float = 1:
	set(value):
		var old = damage
		damage_modifier = value
		var new = damage
		update_damage.emit(old, new)
		
var defense_modifier: float = 1:
	set(value):
		var old = defense
		defense_modifier = value
		var new = defense
		update_defense.emit(old, new)
		
var speed_modifier: float = 1:
	set(value):
		var old = speed
		speed_modifier = value
		var new = speed
		update_speed.emit(old, new)
		
var critical_modifier: float = 1:
	set(value):
		var old = critical
		critical_modifier = value
		var new = critical
		update_critical.emit(old, new)

# The following variables are the effective stats of the characters after
# applying the modifiers, and they should be used by the combat code

var max_health: int:
	get:
		return round(base_max_health * max_health_modifier)
var max_energy: int:
	get:
		return round(base_max_energy * max_energy_modifier)
var damage: int:
	get:
		return round(base_damage * damage_modifier)
var defense: int:
	get:
		return round(base_defense * defense_modifier)
var speed: int:
	get:
		return round(base_speed * speed_modifier)
var critical: int:
	get:
		return round(base_critical * critical_modifier)

# Can't go above modified max_health. When this value reaches 0, the character
# is rendered unconcious
var health: int:
	set(value):
		var old = health
		health = min(value, max_health)
		var new = health
		update_health.emit(old, new)

# Can't go above max_energy. If the character has less energy than required by 
# a skill, they can't use it
var energy: int:
	set(value):
		var old = energy
		energy = min(value, max_energy)
		var new = energy
		update_energy.emit(old, new)

func _ready():
	health = max_health
	energy = max_energy
