## Every condition that is true will apply its corresponding effect.
class_name MultiConditionalEffect extends Effect

## The pairs condition -> effect
@export var effect_pairs: Array[EffectConditionPair]

func evaluate() -> Effect:
	var evaluated_effects = effect_pairs.map(func(pair: EffectConditionPair):
		if pair.effect_condition.evaluate(caster, target):
			return pair.effect
		else:
			return null
	)
	# We remove all failed evaluations
	evaluated_effects = evaluated_effects.filter(func(eff: Effect):
		return eff != null
	)
	
	if evaluated_effects.size() == 0:
		return null
	elif evaluated_effects.size() == 1:
		return evaluated_effects[0]
	else:
		var group = EffectGroup.new()
		group.effects = evaluated_effects
		group.caster = caster
		group.skill_targets = skill_targets
		group.target = target
		return group

func on_cast(caster: Character):
	for pair in effect_pairs:
		pair.effect.cast(caster)

func on_send(target: Character):
	for pair in effect_pairs:
		pair.effect.send(caster)

# Recursively sets the caster of all sub-effects
func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for pair in effect_pairs:
		pair.effect.caster = _caster

# Recursively sets the target of all sub-effects
func _set_target(_target: Character):
	super._set_target(_target)
	for pair in effect_pairs:
		pair.effect.target = _target

# Recursively sets the targets of all sub-effects
func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	for pair in effect_pairs:
		pair.effect.skill_targets = _targets
		
func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for pair in effect_pairs:
		pair.effect.skill = _skill

func _flatten() -> Array[Effect]:
	var eval = evaluate()
	if eval != null:
		return eval._flatten()
	else:
		return []
