class_name ReverseProtectionEffect extends LastingEffect

# Who will protect the character with this buff when it's attacked.
var protector: Character:
	set(value):
		protector = value
		base_data = base_data.duplicate()
		# This only works if the target is correctly set before the protector.
		base_data.description = target.char_name + " is being protected by " + \
			protector.char_name

# In here we nullify this instance and send a copy directly to the caster, which
# will bypass this step on its side and apply it. This allows us to select a
# target other than the caster, but still apply the buff to the caster.
func on_send(target: Character):
	var copy = self.copy()
	copy.target = caster
	copy.protector = target
	copy.target.combat_handler.receive(copy)
	self.is_nullified = true

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		
		var redirected = effect.copy()
		# The effect hitting the old target is nullified
		effect.is_nullified = true
		# As we are intercepting an effect, redirected should only have one
		# target, which is the character being protected. It's new target is
		# caster, which is the original caster of this buff
		redirected.target = protector
		protector.combat_handler.receive(redirected)
		incoming_intercepted = true
