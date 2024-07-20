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
		return when_true
	elif not cond and when_false:
		when_false.caster = caster
		when_false.target = target
		return when_false
	# At this point the condition has been evaluated but the corresponding effect
	# was missing, which means a path with no effect was chosen and the
	# conditional effect must be nullified
	else:
		is_nullified = true
		return self
