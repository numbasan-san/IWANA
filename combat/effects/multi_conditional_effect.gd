## Every condition that is true will apply its corresponding effect.
class_name MultiConditionalEffect extends Effect

## The pairs condition -> effect
@export var effect_pairs: Array[EffectConditionPair]

## Returns the list of effects for which their condition is true
##
## This function is only called from inside process_effect, so it doesn't need
## to set the target of the evaluated effects. If the function is called somewhere
## else, the targets must be manually sent or it'll be an error.
func evaluate() -> Array[Effect]:
	var evaluated_effects = effect_pairs.map(func(pair: EffectConditionPair):
		if pair.effect_condition.evaluate(caster, target):
			return pair.effect
		else:
			return null
	)
	# We remove all failed evaluations
	return evaluated_effects.filter(func(eff: Effect):
		return eff != null
	)
	
func on_cast(caster: Character):
	for pair in effect_pairs:
		pair.effect.cast(caster)

func on_send(target: Character):
	for pair in effect_pairs:
		pair.effect.send(caster)

func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		combat: CombatScreenControl,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = super.process_effect(allies, enemies, combat, parent_target)
	var processed = copies.reduce(func(prev, next):
		var eval = next.evaluate()
		var arr: Array[Effect] = []
		for eff in eval:
			eff.caster = caster
			arr.append_array(eff.process_effect(allies, enemies, combat, next.target))
		return prev.append_array(arr),
	[])
	
	return processed

# Recursively sets the caster of all sub-effects
func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for pair in effect_pairs:
		pair.effect.caster = _caster

func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for pair in effect_pairs:
		pair.effect.skill = _skill
