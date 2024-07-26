class_name CombatHandler extends Node

@export var stats: Stats
@export var skills: Array[Skill]

# Status effects are effects that apply to the character the moment the skill
# lands on it and are removed when a condition is reached

# These effects last for a set number of turns and the condition is checked
# after the character performs its actions. If the effect duration is 0 when the
# character's turn ends, the effect is removed
var end_of_turn: Array[LastingEffect]

# This will call the effect's target_side_process function to modify it's value
# If the effect is immediate, it will call it'
func apply(effect: Effect):
	pass

# This function should be called by the caster of the skill that will impact
# this character. Here it is decided how to handle each effect, if it will be
# applied immediately, if it will be added to the status effect lists, if some
# preprocessing must be performed before applying it, etc.
func process(effect: Effect):
	pass
