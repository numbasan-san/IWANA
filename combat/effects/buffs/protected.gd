class_name ProtectedEffect extends LastingEffect

func intercept(effect: Effect):
	if effect is DamageEffect:
		var redirected = effect.copy()
		# The effect hitting the old target is nullified
		effect.is_nullified = true
		# As we are intercepting an effect, redirected should only have one
		# target, which is the character being protected. It's new target is
		# caster, which is the original caster of this buff
		var new_target: Array[Character] = [caster]
		redirected.targets = new_target
		caster.combat_handler.send(redirected)
		
		duration -= 1
