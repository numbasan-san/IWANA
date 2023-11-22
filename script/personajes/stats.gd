class_name Stats extends Node

#The basic stats that every character has and influences combat

# Health influences how long the character can survive
@export var base_max_health: int = 1

# Energy influences how many skills the character can use
@export var base_max_energy: int = 0

# How much damage the character can do with their skills
@export var base_damage: int = 0

# It was desided that the max defense a character can have before applying
# modifiers is 50. We store that in a variable in case we need to change it
var _max_base_defense = 50
# Blocks a percentage of the incoming damage
@export var base_defense: int = 0:
	set(value):
		base_defense = min(value, _max_base_defense)

# Influences the action order during combat. Characters with higher speed act
# first
@export var base_speed: int = 0

# It isn't specified if there should be a max base critical chance, but 100% is
# a reasonable assumption
var _max_base_critical = 100
# Chance of doing a critical hit, which doubles the damage done with the skill
@export var base_critical: int = 0:
	set(value):
		base_defense = min(value, _max_base_critical)

# The following variables are multipliers that are applied to the base values
# and are changed with items and skills
var max_health_modifier: float
var max_energy_modifier: float
var damage_modifier: float
var defense_modifier: float
var speed_modifier: float
var critical_modifier: float

# The following variables are the effective stats of the characters after
# applying the modifiers, and they should be used by the combat code

var max_health: int:
	get:
		return base_max_health * max_health_modifier
var max_energy: int:
	get:
		return base_max_energy * max_energy_modifier
var damage: int:
	get:
		return base_damage * damage_modifier
var defense: int:
	get:
		return base_defense * defense_modifier
var speed: int:
	get:
		return base_speed * speed_modifier
var critical: int:
	get:
		return base_critical * critical_modifier

# Can't go above modified max_health. When this value reaches 0, the character
# is rendered unconcious
var _health: int
var health: int:
	get:
		return _health
	set(value):
		_health = min(value, max_health)

# Can't go above max_energy. If the character has less energy than required by 
# a skill, they can't use it
var _energy: int
var energy: int:
	get:
		return _energy
	set(value):
		_energy = min(value, max_energy)
