class_name ProtectedEffect extends LastingEffect

func intercept(effect: Effect):
	if effect is DamageEffect:
		var redirected = effect.copy()
		# The effect hitting the old target is nullified
		effect.is_nullified = true
		# As we are intercepting an effect, redirected should only have one
		# target, which is the character being protected. It's new target is
		# caster, which is the original caster of this buff
		
		redirected.target = caster
		caster.combat_handler.receive(redirected)
		
		duration -= 1
