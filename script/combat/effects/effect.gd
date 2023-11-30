class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.

# Some effects have a fixed value that is set the moment it is added to a skills
# and which should be used without doing any extra calculations. If this value
# is 0 it should be ignored and the value should be calculated in the apply
# function based on the user and target
@export var value: int = 0

# Some effects have a fixed duration that is set the moment it is added to a
# skill.
# TODO: some effects have a definite duration and some last until a condition is
# met (for example being hit). Consider if they have to be represented differently
# or an int is enough
@export var duration: int = 0

func apply(_user: Character, _target: Character):
	pass
