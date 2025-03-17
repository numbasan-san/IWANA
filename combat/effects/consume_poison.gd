class_name ConsumePoison extends InstantEffect

func on_apply(target: Character):
	var poison_stacks = 0
	var to_remove: Array[Poison] = []
	for eff in target.combat_handler.other_modifiers:
		if eff is Poison:
			poison_stacks += 1
			to_remove.append(eff)
	for p in to_remove:
		target.combat_handler.remove_lasting_effect(p)
	var damage = DamageEffect.new()
	damage.caster = caster
	damage.type = DamageEffect.DamageType.PHYSICAL
	damage.value = value * poison_stacks
	target.combat_handler.receive(damage)
