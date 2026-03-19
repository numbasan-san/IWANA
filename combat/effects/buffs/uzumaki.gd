class_name Uzumaki extends LastingEffect

# The first time this effect is applied, it's target should be the caster
# (self cast). After that, the target type should be changed to TargetEnemy, so
# the next time it's used it can target an enemy to do the damage.
# TODO: Every time we apply this effect, we actually have a different copy of it,
# so if we are going to change the target type, it must be done at the
# skill level, but we can't find the effect in the skill if it is inside other
# effects. We must change the effect_process to not return copies of the effects,
# and instead copy them before applying them.
func on_apply(target: Character):
	if target_type is TargetSelf:
		value = base_value
		# The default values are 1 target, not random, not repeated
		target_type = TargetEnemy.new()
	elif target_type is TargetEnemy:
		var damage = DamageEffect.new()
		damage.value = value
		value = base_value
		damage.type = DamageEffect.DamageType.PHYSICAL
		damage.caster = caster
		damage.target = target
		target_type = TargetSelf.new()
		caster.combat_handler.remove_lasting_effect(self)
		target.combat_handler.receive(damage)
		
func on_skill_used(skill: Skill):
	if self.skill != skill:
		value += 1
