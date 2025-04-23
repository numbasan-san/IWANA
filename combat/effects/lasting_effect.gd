class_name LastingEffect extends Effect

# This class should be used to define both buffs and debuffs, which are
# effects that apply to a character for a extended period of time. They can
# last for a specific amount of turns, or until a condition is reached, like
# getting hit or attacking

enum Type {
	BUFF, ## This effect has a positive outcome for the target.
	DEBUFF ## This effect has a negative outcome for the target.
}

## Used to identify a lasting effect as being positive or negative towards
## the target.
##
## Some skills might target only one of these types, and enhance or
## diminish them.
@export var type: Type = Type.BUFF

enum Decrease {
	NEVER, ## The duration can only be reduced in a script or the effect must be removed directly.
	BEFORE_TURN, ## The duration will be reduced when the character's turn starts.
	AFTER_TURN, ## The duration will be reduced when the character's turn ends.
	ON_OUTGOING_INTERCEPT, ## The duration will be reduced when intercepting an outgoing effect (on the caster).
	ON_INCOMING_INTERCEPT, ## The duration will be reduced when intercepting an incoming effect (on the target).
	ON_CHARACTER_HIT, ## The duration will be reduced when an effect is successfully applied (on the target).
	ON_SKILL_USED ## The duration will be reduced when a skill is used.
}

## When should the duration of this effect be reduced.
@export var decrease_duration: Decrease = Decrease.NEVER

## How long it takes before this effect is removed from the target.
@export var duration: int = 0:
	set(value):
		duration = clampi(value, 0, 9223372036854775807)

# If true several buffs of the same type can be applied at the same time. If not,
# when applying the same kind of buff twice the oldest one is removed.
@export var stacks: bool = false

# Variable intended to be used in lasting effects that override the on_incoming
# function. As these effects should only be able to intercept specific kinds of
# effects, when that is the case this should be set to true so that the duration
# counter isn't decreased for effects that are being ignored
var incoming_intercepted: bool = false

# Variable to be used in lasting effects that override the on_outgoing function
var outgoing_intercepted: bool = false

# Variable intended to be used in lasting effects that override the 
# on_character_hit function. As these effects should only be able to intercept
# specific kinds of effects, when that is the case this should be set to true so
# that the duration counter isn't decreased for effects that are being ignored
var hit: bool = false

func apply(target: Character):
	super.apply(target)

# When another character has been hit with an effect (after it's on_apply
# function has been called) it will notify back to that effect's caster. At that
# moment this function will be called on the caster's lasting effects.
func on_character_hit(who: Character, effect: Effect):
	pass

func character_hit(who: Character, effect: Effect):
	# We check this here because if on_character_hit sends another effect to the
	# target that will also trigger this effect on hit, it could enter an
	# infinite loop. Because hit is always made false at the end of this
	# function, if it is true at this point it's because we are calling this
	# recursively. If the second call wouldn't trigger the effect anyways, this
	# makes no difference, and if it would trigger it, this prevents the loop
	# from starting. This only prevents looping hits. If more than one effect of
	# the same type are sent from outside this function, it will still work as
	# intended.
	if not is_nullified and not hit:
		on_character_hit(who, effect)
		if hit and decrease_duration == Decrease.ON_CHARACTER_HIT:
			duration -= 1
	hit = false

# This is called when the turn of this effect's target has just started
# and before it performs its actions
func before_turn(target: Character):
	pass

func start_turn(target: Character):
	if not is_nullified:
		before_turn(target)
		if decrease_duration == Decrease.BEFORE_TURN:
			duration -= 1

# This is called at the end of the target's turn after it has performed
# all its actions. This can be used for example to decrease the effect's
# duration
func after_turn(target: Character):
	pass

func end_turn(target: Character):
	if not is_nullified:
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

# If this effect intercepts other incoming effects and alters them in some way,
# the code to filter and modify those other effects should go here.
func on_incoming(effect: Effect):
	pass

func incoming(effect: Effect):
	# Nullified effects won't trigger an interception and won't decrease the
	# duration.
	# We check interception here because if on_incoming sends another effect to
	# the target that will also be intercepted by this effect, it could enter an
	# infinite loop. Because interception is always made false at the
	# end of this function, if it is true at this point it's because we are
	# calling this recursively. If the second call wouldn't intercept the
	# effect anyways, this makes no difference, and if it would intercept,
	# this prevents the loop from starting. This only prevents looping
	# interceptions. If more than one effect of the same type are sent from
	# outside this function, it will still work as intended.
	if not is_nullified and not effect.is_nullified and not incoming_intercepted:
		on_incoming(effect)
		if incoming_intercepted and decrease_duration == Decrease.ON_INCOMING_INTERCEPT:
			duration -= 1
	incoming_intercepted = false

# If this effect intercepts other outgoing effects and alters them in some way,
# the code to filter and modify those other effects should go here.
func on_outgoing(effect: Effect):
	pass

func outgoing(effect: Effect):
	# Nullified effects won't trigger an interception and won't decrease the
	# duration.
	# We check interception here because if on_outgoing sends another effect to
	# the target that will also be intercepted by this effect, it could enter an
	# infinite loop. Because interception is always made false at the
	# end of this function, if it is true at this point it's because we are
	# calling this recursively. If the second call wouldn't intercept the
	# effect anyways, this makes no difference, and if it would intercept,
	# this prevents the loop from starting. This only prevents looping
	# interceptions. If more than one effect of the same type are sent from
	# outside this function, it will still work as intended.
	if not is_nullified and not effect.is_nullified and not outgoing_intercepted:
		on_outgoing(effect)
		if outgoing_intercepted and decrease_duration == Decrease.ON_OUTGOING_INTERCEPT:
			duration -= 1
	outgoing_intercepted = false

# This is called when the caster uses a skill, before its effects have been sent
# to the target.
func on_skill_used(skill: Skill):
	pass

func skill_used(skill: Skill):
	if not is_nullified:
		on_skill_used(skill)
		if decrease_duration == Decrease.ON_SKILL_USED:
			duration -= 1
