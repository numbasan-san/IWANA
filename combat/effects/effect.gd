class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.

# Some effects have a fixed value that is set the moment it is added to a skill
# and which should be used without doing any extra calculations. If this value
# is negative it should be ignored and the value should be calculated in the apply
# function based on the caster and target
@export var value: int = -1

# This should be called when the caster's combat handler started processing
# this effect and after being initialized or cloned from the base resource.
# Effects that override this should include here code that assigns the initial
# value and duration. 
func on_cast(caster: Character):
	pass

# This should be called after the effect has been processed by the caster's
# buffs and debuffs and before being sent to the target
func on_send(target: Character):
	pass

# This should be called when the effect has been received by the target, before
# any other processing has been done
func on_receive(caster: Character):
	pass

# This should be called after the effect has been processed by the target's
# buffs and debuffs. This should contain the code that modifies the target, for
# example reducing health or modifying some stat
func on_apply(target: Character):
	pass
