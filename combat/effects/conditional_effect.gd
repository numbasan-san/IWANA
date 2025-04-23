## Apply different effects depending on the truth value of a condition
##
## If the effect has several targets, the condition is evaluated independently
## for each one of them.

class_name ConditionalEffect extends Effect

## The condition to evaluate
@export var condition: Condition

## Effect to select when the condition is true
@export var when_true: Effect

## Effect to select when the condition is false
@export var when_false: Effect

# This function will be called before calling on_send
func evaluate() -> Effect:
	var cond = condition.evaluate(caster, target)
	if cond and when_true:
		return when_true
	elif not cond and when_false:
		return when_false
	# At this point the condition has been evaluated but the corresponding effect
	# was missing, which means a path with no effect was chosen and the
	# conditional effect must be nullified
	else:
		is_nullified = true
		return null

func on_cast(caster: Character):
	if when_true:
		when_true.cast(caster)
	if when_false:
		when_false.cast(caster)

func on_send(target: Character):
	if when_true:
		when_true.send(caster)
	if when_false:
		when_false.send(caster)

func search_effect_selections() -> Array[SelectionEffect]:
	var found: Array[SelectionEffect] = []
	var temp: Array[SelectionEffect]
	if when_true:
		temp = when_true.search_effect_selections()
		for e in temp:
			found.append(e)
	if when_false:
		temp = when_false.search_effect_selections()
		for e in temp:
			found.append(e)
	
	return found

func search_skill_selections() -> Array[SkillSelectionEffect]:
	var found: Array[SkillSelectionEffect] = []
	var temp: Array[SkillSelectionEffect]
	if when_true:
		temp = when_true.search_skill_selections()
		for e in temp:
			found.append(e)
	if when_false:
		temp = when_false.search_skill_selections()
		for e in temp:
			found.append(e)
	
	return found

func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		combat: CombatScreenControl,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = await super.process_effect(allies, enemies, combat, parent_target)
	# Before processing the skill is set to NEW unless it failed some check.
	# During processing it should still be NEW unless it was manually cancelled
	# or something failed.
	if skill.status != skill.Status.NEW:
		return []
	
	var processed: Array[Effect] = []
	for eff  in copies:
		var eval = eff.evaluate()
		eval.caster = caster
		processed.append_array(await eval.process_effect(allies, enemies, combat, eff.target))
		
	return processed
	
# Recursively sets the caster of all sub-effects
func _set_caster(_caster: Character):
	super._set_caster(_caster)
	if when_true:
		when_true.caster = _caster
	if when_false:
		when_false.caster = _caster

# Recursively sets the skill of all sub-effects
func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	if when_true:
		when_true.skill = _skill
	if when_false:
		when_false.skill = _skill
