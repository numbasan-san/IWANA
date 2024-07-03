class_name LastingEffect extends Effect

# This class should be used  to define both buffs and debuffs, which are
# effects that apply to a character for a extended period of time. They can
# last for a specific amount of turns, or until a condition is reached, like
# getting hit or attacking

# How long it takes before this effect is removed from the target. Instances of
# this class must decide what this number means and how to decrement it
@export var duration: int = 0

# This defines the changes that this effect will have on the target
#TODO: this should be replaced with apply() in the parent class when it is
# better defined
func apply_temp():
	pass
