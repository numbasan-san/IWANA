class_name Wounded extends ChainedEffect

# TODO: when wounded (or any chained effect) is intercepted, the chained instance
# is sent directly to the target, without copying. When that sent effect is a
# lasting effect, that is, an icon should be placed over the target's sprite,
# because the exact same instance is sent, if there was already an icon for that
# effect, because it had already been triggered, no new icon is drawn. This means
# that there are less icons than effects currently active.
# Also, when the effect's duration is 0 it still tries to remove the icon because it
# assumes there is one for each instance. This leads to more icons being removed
# than the ones being added and it triggers an error.
# The system must be changed so that only one icon is ever shown with the info
# of all the related effects, and when all of them have been removed, the icon can
# be removed.
func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			for inc in incoming_effects:
				inc.target = effect.target
			incoming_intercepted = true
