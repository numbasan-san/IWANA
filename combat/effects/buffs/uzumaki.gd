class_name Uzumaki extends LastingEffect

# The first time this effect is applied, it's target should be the caster
# (self cast). After that, the target type should be changed to TargetEnemy, so
# the next time it's used it can target an enemy to do the damage.
func on_apply(target: Character):
	if target_type is TargetSelf:
		# The default values are 1 target, not random, not repeated
		target_type = TargetEnemy.new()
	elif target_type is TargetEnemy:
		var damage = DamageEffect.new()
		damage.value = value
		value = 0
		damage.type = DamageEffect.DamageType.PHYSICAL
		damage.caster = caster
		damage.target = target
		target_type = TargetSelf.new()
		caster.combat_handler.remove_lasting_effect(self)
		target.combat_handler.receive(damage)
		
func on_skill_used(skill: Skill):
	if self.skill != skill:
		value += 1
