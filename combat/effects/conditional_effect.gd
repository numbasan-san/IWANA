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
		when_true.caster = caster
		when_true.target = target
		if when_true is ConditionalEffect:
			return when_true.evaluate()
		else:
			return when_true
	elif not cond and when_false:
		when_false.caster = caster
		when_false.target = target
		if when_false is ConditionalEffect:
			return when_false.evaluate()
		else:
			return when_false
	# At this point the condition has been evaluated but the corresponding effect
	# was missing, which means a path with no effect was chosen and the
	# conditional effect must be nullified
	else:
		is_nullified = true
		return self

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

# Recursively sets the caster of all sub-effects
func _set_caster(_caster: Character):
	super._set_caster(_caster)
	if when_true:
		when_true.caster = _caster
	if when_false:
		when_false.caster = _caster

# Recursively sets the targets of all sub-effects
func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	if when_true:
		when_true.skill_targets = _targets
	if when_false:
		when_false.skill_targets = _targets
