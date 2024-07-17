class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.

## The value of this effect.
##
## Some effects have a fixed value that is set the moment it is added to a skill
## and which should be used without doing any extra calculations. If this value
## is negative it should be ignored and the value should be calculated in the apply
## function based on the caster and target
@export var value: float = -1


## What kind of targets can be selected to apply these effects
@export var target_type: TargetType

## The character that triggered this effect.
##
## It should be filled when processing the skill, and trying to apply the
## effect without a caster should result in an error
var caster: Character

## The characters that will be affected by this effect.
##
## It should be filled when processing the skill, and trying to apply the
## effect without targets should result in an error
var targets: Array[Character]


# This should be called when the caster's combat handler started processing
# this effect and after being initialized or cloned from the base resource.
# Effects that override this should include here code that assigns the initial
# value and duration. 
func on_cast(caster: Character):
	pass

# This should be called after the effect has been processed by the caster's
# buffs and debuffs and before being sent to the target
func on_send(target: Character):
	pass

# This should be called when the effect has been received by the target, before
# any other processing has been done
func on_receive(caster: Character):
	pass

# This should be called after the effect has been processed by the target's
# buffs and debuffs. This should contain the code that modifies the target, for
# example reducing health or modifying some stat
func on_apply(target: Character):
	pass

func select_targets(allies: Party, enemies: Party):
	if target_type.is_manual_target():
		return
	
	targets = []
	if target_type is TargetSelf:
		targets = [caster]
	else:
		var possible_targets = []
		# Same as checking if Friend, Party, Anyone or Everyone
		if not target_type is TargetEnemy and not target_type is TargetEnemyParty:
			possible_targets.append_array(allies.members)
			if target_type.exclude_self:
				possible_targets.erase(caster)
		# Same as checking if Enemy, EnemyParty, Anyone or Everyone
		if not target_type is TargetFriend and not target_type is TargetParty:
			possible_targets.append_array(enemies.members)
		# Same as checking if Party, EnemyParty or Everyone
		if target_type is TargetFixed:
			targets = possible_targets
			return
		# If we reach this condition the type is variable and not manual, so it
		# must be set to random
		var var_t = target_type as TargetVariable
		var n_targets = var_t.number_of_targets
		while n_targets > 0 and not possible_targets.is_empty():
			var target = possible_targets.pick_random()
			targets.append(target)
			n_targets -= 1
			if not var_t.allow_repetition:
				possible_targets.erase(target)
	

func is_valid() -> bool:
	return caster and targets and targets.size() > 0
