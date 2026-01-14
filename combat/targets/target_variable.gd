## Superclass of all target types that can't know all possible targets.
##
## Subclasses are TargetFriend, TargetEnemy and TargetAnyone
class_name TargetVariable extends TargetType

## The number of targets that can be chosen.
@export var number_of_targets: int = 1

## Targets will be chosen at random.
@export var random: bool = false

## Allows a target to be chosen multiple times.
##
## This only has an effect if number_of_targets is greater than 1
@export var allow_repetition: bool = false

func is_manual_target() -> bool:
	# If random is true we can select automatically
	return not random
