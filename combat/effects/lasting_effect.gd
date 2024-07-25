class_name LastingEffect extends Effect

# This class should be used  to define both buffs and debuffs, which are
# effects that apply to a character for a extended period of time. They can
# last for a specific amount of turns, or until a condition is reached, like
# getting hit or attacking

@export var icon: AtlasTexture

enum Type { BUFF, DEBUFF }
@export var type: Type

enum Modify { STAT, OUTGOING, INCOMING, CHARACTER_HIT }
@export var modifies: Modify

enum Decrease {
	NEVER,
	ON_APPLY,
	BEFORE_TURN,
	AFTER_TURN,
	ON_INTERCEPT,
	ON_CHARACTER_HIT
}
@export var decrease_duration: Decrease = Decrease.NEVER

# How long it takes before this effect is removed from the target. Instances of
# this class must decide what this number means and how to decrement it
@export var duration: int = 0:
	set(value):
		duration = clampi(value, 0, 9223372036854775807)

# Variable intended to be used in lasting effects that override the on_intercept
# function. As these effects should only be able to intercept specific kinds of
# effects, when that is the case this should be set to true so that the duration
# counter isn't decreased for effects that are being ignored
var interception: bool = false

# Variable intended to be used in lasting effects that override the 
# on_character_hit function. As these effects should only be able to intercept
# specific kinds of effects, when that is the case this should be set to true so
# that the duration counter isn't decreased for effects that are being ignored
var hit: bool = false

func apply(target: Character):
	super.apply(target)
	if decrease_duration == Decrease.ON_APPLY:
		duration -= 1

# When another character has been hit with an effect (after it's on_apply
# function has been called) it will notify back to that effect's caster. At that
# moment this function will be called on the caster's lasting effects.
func on_character_hit(who: Character, effect: Effect):
	pass

func character_hit(who: Character, effect: Effect):
	on_character_hit(who, effect)
	if hit and decrease_duration == Decrease.ON_CHARACTER_HIT:
		duration -= 1
	hit = false

# This is called when the turn of this effect's target has just started
# and before it performs its actions
func before_turn(target: Character):
	pass

func start_turn(target: Character):
	before_turn(target)
	if decrease_duration == Decrease.BEFORE_TURN:
		duration -= 1

# This is called at the end of the target's turn after it has performed
# all its actions. This can be used for example to decrease the effect's
# duration
func after_turn(target: Character):
	pass

func end_turn(target: Character):
	after_turn(target)
	if decrease_duration == Decrease.AFTER_TURN:
		duration -= 1

# This is called after the effect's duration has run out and the changes
# it had on the target have to be reverted.
func on_unapply(target: Character):
	pass

func unapply(target: Character):
	# We don't decrease duration here as this should only be called when the
	# duration has already reached 0
	on_unapply(target)

# If this effect intercepts other incoming or outgoing effects and alters them
# in some way, the code to filter and modify those other effects should go here.
# If this effect's modifies variable is OUTGOING, this function will be called
# on the caster side before sending it. If it's INCOMING, it will be called on
# the target side after receiving it. If it's STAT, this shouldn't be called.
func on_intercept(effect: Effect):
	pass

func intercept(effect: Effect):
	on_intercept(effect)
	if interception and decrease_duration == Decrease.ON_INTERCEPT:
		duration -= 1
	interception = false
