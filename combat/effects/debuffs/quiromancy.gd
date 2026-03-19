class_name Quiromancy extends LastingEffect

@export var damage_per_turn: float = 1

func on_receive(caster: Character):
	var instances = target.combat_handler.lasting_effects.filter(func(e):
		return self.is_same_type(e)
	)
	if instances.size() > 0:
		# In theory only one instance of this effect should be present at a time.
		# If that's not the case, we only process the first one found.
		var instance = instances[0]
		var damage = DamageEffect.new()
		damage.value = instance.value
		damage.type == DamageEffect.DamageType.PHYSICAL
		damage.caster = caster
		target.combat_handler.remove_lasting_effect(instance)
		target.combat_handler.receive(damage)
		is_nullified = true
	else:
		value = base_value
func after_turn(target: Character):
	value += damage_per_turn
