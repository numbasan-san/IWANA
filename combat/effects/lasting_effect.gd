class_name LastingEffect extends Effect

# This class should be used  to define both buffs and debuffs, which are
# effects that apply to a character for a extended period of time. They can
# last for a specific amount of turns, or until a condition is reached, like
# getting hit or attacking

enum Type { BUFF, DEBUFF }
@export var type: Type

enum Modify { STAT, OUTGOING, INCOMING }
@export var modifies: Modify

# How long it takes before this effect is removed from the target. Instances of
# this class must decide what this number means and how to decrement it
@export var duration: int = 0

# This function should be called when the character is going to be hit by some 
# other effect, for example a damage effect from an attack. This can be used 
# for example to nullify the incoming effect
func before_hit(target: Character):
	pass

# This function should be called after the character has been hit by some other 
# effect, for example a damage effect from an attack. This can be used to
# retaliate or decrease the effect's duration
func after_hit(target: Character):
	pass

# This should be called when the turn of this effect's target has just started
# and before it performs its actions
func before_turn(target: Character):
	pass

# This should be called at the end of the target's turn after it has performed
# all its actions. This can be used for example to decrease the effect's
# duration
func after_turn(target: Character):
	pass

# This should be called after the effect's duration has run out and the changes
# it had on the target have to be reverted.
func on_unapply(target: Character):
	pass

# If this effect intercepts other incoming or outgoing effects and alters them
# in some way, the code to filter and modify those other effects should go here.
# If this effect's modifies variable is OUTGOING, this function will be called
# on the caster side before sending it. If it's INCOMING, it will be called on
# the target side after receiving it. If it's STAT, this shouldn't be called.
func intercept(effect: Effect):
	pass
