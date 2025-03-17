class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.

## The base value of this effect.
##
## If the actual value of the effect is modified before being applied, this base
## value can be used to restore the original value.
@export var base_value: float = 1:
	set(new_value):
		base_value = clampf(new_value, 0, 9223372036854775807)
		value = base_value

## What kind of targets can be selected to apply these effects
@export var target_type: TargetType

## The value that will be used when applying the effect.
##
## What this number means and how it is calculated depends on the specifics of
## the effect. That script is responsible of calculating this value correctly and
## restoring it if the base value changes.
var value: float = base_value

## The character that triggered this effect.
##
## It should be filled when processing the skill, and trying to apply the
## effect without a caster should result in an error
var caster: Character:
	set(value):
		_set_caster(value)
	get:
		return _caster
var _caster: Character

## The characters that will be affected by this effect.
##
## It should be filled when processing the skill, and trying to apply the
## effect without targets should result in an error
var skill_targets: Array[Character]:
	set(value):
		_set_skill_targets(value)
	get:
		return _skill_targets
var _skill_targets: Array[Character]

## The specific target this effect is being sent to
##
## This variable is set by the handler before calling on_send and should only
## be modified in custom code if it's going to be executed after the outgoing
## modifier phase, that is, in functions on_send, on_receive, on_apply and
## intercept in lasting effects of type INCOMING
var target: Character

## Effects that are nullified will stop being processed by the system.
##
## Some effects might nullify other incoming or outgoing effects and prevent
## them from being applied or from reaching the target
var is_nullified: bool = false

# This will be called when the caster's combat handler starts processing
# this effect and after being initialized or cloned from the base resource.
# Effects that override this should include here code that assigns the initial
# value and duration. 
func on_cast(caster: Character):
	pass

func cast(caster: Character):
	if not is_nullified:
		await on_cast(caster)

# This will be called after the effect has been processed by the caster's
# buffs and debuffs and before being sent to the target
func on_send(target: Character):
	pass

func send(target: Character):
	if not is_nullified:
		await on_send(target)

# This will be called when the effect has been received by the target, before
# any other processing has been done
func on_receive(caster: Character):
	pass

func receive(caster: Character):
	if not is_nullified:
		await on_receive(caster)

# This will be called after the effect has been processed by the target's
# buffs and debuffs. This should contain the code that modifies the target, for
# example reducing health or modifying some stat
func on_apply(target: Character):
	pass

func apply(target: Character):
	if not is_nullified:
		await on_apply(target)

func select_targets(allies: Party, enemies: Party):
	if target_type.is_manual_target():
		return
	
	skill_targets = []
	if target_type is TargetSelf:
		skill_targets = [caster]
	else:
		var possible_targets: Array[Character] = []
		# Same as checking if Friend, Party, Anyone or Everyone
		if not target_type is TargetEnemy and not target_type is TargetEnemyParty:
			possible_targets.append_array(allies.members)
			if target_type.exclude_self:
				possible_targets.erase(caster)
		# Same as checking if Enemy, EnemyParty, Anyone or Everyone
		if not target_type is TargetFriend and not target_type is TargetParty:
			possible_targets.append_array(enemies.members)
		# We remove fainted targets and targets with a weight lower than 1.
		possible_targets = possible_targets.filter(func(char: Character):
			return not char.combat_handler.stats.unconscious and \
				char.combat_handler.target_weight > 0)
		# Same as checking if Party, EnemyParty or Everyone
		if target_type is TargetFixed:
			skill_targets = possible_targets
			return
		# If we reach this point the type is variable and not manual, so it
		# must be set to random
		var var_t = target_type as TargetVariable
		var n_targets = var_t.number_of_targets
		# If a character has a target weight greater than 1, we add more instances
		# of that character to the array so it is more likely to be selected.
		var extra_targets: Array[Character] = []
		for char in possible_targets:
			var n = char.combat_handler.target_weight
			if n > 1:
				while n - 1 > 0:
					extra_targets.append(char)
					n = n - 1
		possible_targets.append_array(extra_targets)
		while n_targets > 0 and not possible_targets.is_empty():
			var picked_target = possible_targets.pick_random()
			skill_targets.append(picked_target)
			n_targets -= 1
			if not var_t.allow_repetition:
				possible_targets.erase(picked_target)
	
func is_valid() -> bool:
	return caster and skill_targets and skill_targets.size() > 0

# Copies this effect. This is necessary as using the duplicate method doesn't
# copy all fields
func copy() -> Effect:
	var new_effect = self.duplicate(true) as Effect
	new_effect.value = value
	new_effect.caster = caster
	new_effect.skill_targets = skill_targets.duplicate()
	new_effect.target = target
	new_effect.is_nullified = is_nullified
	return new_effect

# This should be called as the setter of the caster property. It can be
# overriden by subclasses that have subeffects to set their caster to the same as
# the container.
func _set_caster(_caster: Character):
	self._caster = _caster

# This should be called as the setter of the skill_targets property. It can be
# overriden by subclasses that have subeffects to set their targets to the same as
# the container.
func _set_skill_targets(_targets: Array[Character]):
	self._skill_targets = _targets
