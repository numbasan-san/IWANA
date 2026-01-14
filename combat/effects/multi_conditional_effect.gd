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
	var evaluated_effects: Array[Effect]
	for pair in effect_pairs:
		if pair.effect_condition.evaluate(caster, target):
			evaluated_effects.append(pair.effect)
	
	return evaluated_effects
	
func on_cast(caster: Character):
	for pair in effect_pairs:
		pair.effect.cast(caster)

func on_send(target: Character):
	for pair in effect_pairs:
		pair.effect.send(caster)

func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = await super.process_effect(allies, enemies, handler, parent_target)
	# Before processing the skill is set to NEW unless it failed some check.
	# During processing it should still be NEW unless it was manually cancelled
	# or something failed.
	if skill.status != skill.Status.NEW:
		return []
	
	var processed: Array[Effect]
	for copy in copies:
		for eff in copy.evaluate():
			processed.append_array(await eff.process_effect(allies, enemies, handler, copy.target))
	
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
