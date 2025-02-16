class_name ConsumePoison extends InstantEffect

func on_apply(target: Character):
	var poison_stacks = 0
	for eff in target.combat_handler.other_modifiers:
		if eff is Poison:
			poison_stacks += 1
			target.combat_handler.remove_lasting_effect(eff)
	var damage = DamageEffect.new()
	damage.type = DamageEffect.DamageType.TRUE
	damage.value = value * poison_stacks
	target.combat_handler.receive(damage)
