class_name ReverseProtectionEffect extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		incoming_effect = effect.copy()
		var redirected = effect.copy()
		# The effect hitting the old target is nullified
		effect.is_nullified = true
		# As we are intercepting an effect, redirected should only have one
		# target, which is the character being protected. It's new target is
		# caster, which is the original caster of this buff
		incoming_effect.target = caster
		caster.combat_handler.receive(redirected)
		incoming_intercepted = true
