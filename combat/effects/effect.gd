class_name Effect extends Resource

# An effect is anything that causes some change on characters' stats as a result
# of a skill, like causing damage or healing, applying a buff or debuff, etc.
@export var base_data: EffectBaseData

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
var value: float = base_value:
	set(new):
		_before_value_change()
		value = new
		_after_value_change()

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
var skill_targets: Array[Character]

## The specific target this effect is being sent to
##
## This variable is set by the handler before calling on_send and should only
## be modified in custom code if it's going to be executed after the outgoing
## modifier phase, that is, in functions on_send, on_receive, on_apply and
## intercept in lasting effects of type INCOMING
var target: Character

## The skill casted to apply this effect.
##
## Some effects might need to know this so they can monitor when other skills are
## used.
var skill: Skill:
	set(value):
		_set_skill(value)
	get:
		return _skill
var _skill: Skill

## Effects that are nullified will stop being processed by the system.
##
## Some effects might nullify other incoming or outgoing effects and prevent
## them from being applied or from reaching the target
var is_nullified: bool = false

# If this effect doesn't have a predefined data resource, it creates an empty one
# so that it doesn't throw errors when being accesed.
# Effects that must load this data dinamically should override this function.
func init_base_data():
	if base_data == null:
		base_data = EffectBaseData.new()

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

func is_valid() -> bool:
	return caster and target

# By default, two effects have the same type if they inherit the same script.
# Some effects might want to override this to refine how they are compared.
func is_same_type(other: Effect) -> bool:
	return self.get_script() == other.get_script()

# Copies this effect. This is necessary as using the duplicate method doesn't
# copy all fields
func copy() -> Effect:
	var new_effect = self.duplicate(true) as Effect
	new_effect.value = value
	new_effect.caster = caster
	new_effect.target = target
	new_effect.skill = skill
	new_effect.is_nullified = is_nullified
	return new_effect

## Find targets for this effect and all sub effects, and evaluate selection effects
## and conditional effects.
##
## It should return a flattened array, that is when called recursively it will
## append the results in a single 1D array regardless of the depth of the structure.
## If this effect doesn't have a target type, it inherits the found target from
## its parent. If it doesn't have a type and the parent's target is null, it is an error.
func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null) -> Array[Effect]:
	
	# Before processing the skill is set to NEW unless it failed some check.
	# During processing it should still be NEW unless it was manually cancelled
	# or something failed.
	if skill.status != skill.Status.NEW:
		return []
	
	if !target_type:
		var effect = self.copy()
		# We make it null in case it was left with a value from a previous process.
		# If the target type is null, the target is set to the same as the parent.
		if parent_target:
			effect.target = parent_target
			return [effect]
		else:
			printerr("Effect | " + self.to_string() + " doesn't have a target type " + \
				" and its parent target is null.")
			return []
	
	# If we reach this point, this effect must set its own targets.
	var targets: Array[Character] = await _select_targets(allies, enemies, handler)
	
	# This could happen if the player cancels the skill before selecting targets.
	if targets.size() == 0:
		printerr("Effect | " + self.to_string() + " couldn't find any target.")
		return []
	elif targets.size() == 1:
		var effect = self.copy()
		# Change target to no longer recursively update children
		effect.target = targets[0]
		return [effect]
	else:
		var copies: Array[Effect] = []
		# We set the target type to null so that when recursively processing
		# them we don't search for targets again. Because this is a copy, it won't
		# affect the target type of the original effect.
		for target in targets:
			var effect = self.copy()
			effect.target = target
			effect.target_type = null
			copies.append(effect)
		return copies

func _select_targets(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler) -> Array[Character]:
	
	if target_type.is_manual_target():
		return await _select_manual_targets(allies, enemies, handler)
	else:
		return _select_auto_targets(allies, enemies)

func _select_manual_targets(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler) -> Array[Character]:
	
	# The caster should have already been set recursively for all effects of the
	# skill.
	handler.show_possible_targets(self)
	var targets = await handler.finished_targeting
	
	# If targets size is 0, the selection was interrupted
	if targets.size() == 0:
		skill.status == skill.Status.CANCELLED
		return []
	return targets

func _select_auto_targets(allies: Array[Character], enemies: Array[Character]) -> Array[Character]:
	if target_type is TargetSelf:
		return [caster]
	else:
		var possible_targets: Array[Character] = []
		# Same as checking if Friend, Party, Anyone or Everyone
		if not target_type is TargetEnemy and not target_type is TargetEnemyParty:
			possible_targets.append_array(allies)
			if target_type.exclude_self:
				possible_targets.erase(caster)
		# Same as checking if Enemy, EnemyParty, Anyone or Everyone
		if not target_type is TargetFriend and not target_type is TargetParty:
			possible_targets.append_array(enemies)
		# We remove fainted targets and targets with a weight lower than 1.
		possible_targets = possible_targets.filter(func(char: Character):
			return not char.combat_handler.stats.unconscious and \
				char.combat_handler.target_weight > 0)
		# Same as checking if Party, EnemyParty or Everyone
		if target_type is TargetFixed:
			return possible_targets
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
		var targets: Array[Character] = []
		while n_targets > 0 and not possible_targets.is_empty():
			var picked_target = possible_targets.pick_random()
			targets.append(picked_target)
			n_targets -= 1
			if not var_t.allow_repetition:
				possible_targets.erase(picked_target)
		
		return targets

# This should be called as the setter of the caster property. It can be
# overriden by subclasses that have subeffects to set their caster to the same as
# the container.
func _set_caster(_caster: Character):
	self._caster = _caster

# This should be called as the setter of the skill property. It can be
# overriden by subclasses that have subeffects to set their skill to the same as
# the container.
func _set_skill(_skill: Skill):
	self._skill = _skill

func _before_value_change():
	pass
	
func _after_value_change():
	pass
