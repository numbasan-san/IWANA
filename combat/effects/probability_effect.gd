## Apply different effects depending on the truth value of a condition
##
## If the effect has several targets, the condition is evaluated independently
## for each one of them.

class_name ProbabilityEffect extends Effect

# An array of pairs (prob, effect). If the sum of probabilities is less than 100,
# the difference is the chance that none of the effects happen. If the sum is
# greater than 100, the number that just goes over 100 will be truncated and the
# following effects will be ignored.
@export var probabilities: Array[ProbabilityPair]

# This function will be called before calling on_send
func evaluate() -> Effect:
	var rnd = randf_range(0, 100)
	var sum = 0
	for pair in probabilities:
		sum += pair.probability
		# 0 is a possible value of rnd, so if the posibility is 0 we skip this
		# effect
		if sum != 0 and sum >= rnd:
			return pair.effect
		
	# At this point the condition has been evaluated but the corresponding effect
	# was missing, which means a path with no effect was chosen and the
	# conditional effect must be nullified
	is_nullified = true
	return null

# The effect is only evaluated after it is received by the target, so when the
# following functions are called we don't know what effect will be actually
# chosen, so we must call the functions on all possibilities. Although this might
# be less efficient than calling them only on the evaluated effect, these functions
# will rarely be called so it doesn't matter.
func on_cast(caster: Character):
	for pair in probabilities:
		pair.effect.cast(caster)

func on_send(target: Character):
	for pair in probabilities:
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
	
	var processed = copies.reduce(func(prev, next):
		var eval = next.evaluate()
		eval.caster = caster
		return prev.append_array(await eval.process_effect(allies, enemies, handler, next.target)),
	[])
	return processed

# Recursively sets the caster of all sub-effects
func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for pair in probabilities:
		pair.effect.caster = _caster

func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for pair in probabilities:
		pair.effect.skill = _skill
