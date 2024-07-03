class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.

# Some effects have a fixed value that is set the moment it is added to a skill
# and which should be used without doing any extra calculations. If this value
# is 0 it should be ignored and the value should be calculated in the apply
# function based on the user and target
@export var value: int = 0

func apply(_user: Character, _target: Character):
	pass

# For effects that don't have a predefined value, for example if it depends on
# a stat of the user, this function should be called to compute that value
# before sending it to the target
func user_side_process(user: Character):
	pass

# This function will be called by the target's combat handler to further modify
# the effect before applying it.
func target_side_process(target: Character):
	pass
