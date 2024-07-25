class_name Skill extends Resource

# A skill is the main tool a character has during battle. Each player has 8
# skills and each one can either help the party, harm the enemies, or both.
# They can be improved while playing the game with special items, which will
# replace them with a more advanced version
# Each skill will also request a sequence of player inputs with specific timings
# that in some cases will improve its effects when hit properly, and in others
# it will cause them to fail or have negative effects when missed

# The name of the skill that is shown in menus or during combat in the skill
# selection gui
@export var name: String

# TODO: Only a temporary variable to draw placeholder animations. Remove it when
# the system is ready
@export var anim_name: String

# A description that is shown to the player in menus or tooltips that explain
# what it does
@export_multiline var description: String

## The list of effect groups to be applied by this skill.
##
## Each group has its own possible targets, and when using this skill it should
## prompt to choose targets for each one that isn't chosen automatically.
@export var effects: Array[Effect]

## How much energy using this skill consumes.
##
## If the character doesn't have enough energy they can't perform the skill.
@export var energy_cost: int

# Which is the character that is performing the skill.
var caster: Character:
	set(value):
		caster = value
		for eff in effects:
			eff.caster = caster

# The animation that is played when using the skill.
# TODO: this will probably have to be revised as it's posible we'll need a way
# to control pauses and timings of the animation to sync with the effects and
# inputs
var animation: Animation

# TODO: add variable to represent input presses and their timings that affect
# the results of the skill

# Performs some initialization before applying the skill.
# Some skills might have special conditions and effects that can't be easily
# represented by this system and they need to extend this script and override
# this function
# TODO: For now this assumes one-target skills. It has to be fixed later
func setup(caster: Character, target: Character):
	pass

# Returns a list with all the target types of the groups that require manual
# target selection. This can be used to prompt the player to pick the targets
# Currently, the only types of target that could need to be picked manually are
# of TargetVariable type
func get_manual_targets() -> Array[TargetVariable]:
	var types: Array[TargetVariable] = []
	for eff in effects:
		if eff.target_type.is_manual_target():
			types.append(eff.target_type as TargetVariable)
	return types

# Calling this function will fill caster and target data for each effect group.
# Before calling this, one should get the list of targets by calling
# get_manual_targets.
# targets should be an array of arrays. Each element of targets will be passed
# in order to an effect group that requires manual targeting, while all other
# groups will be processed with caster and parties info.
func process_effects(allies: Party, enemies: Party, targets: Array):
	# If these two sizes don't match, something has gone wrong or a step has been
	# ignored, so we stop the process altogether
	if get_manual_targets().size() != targets.size():
		return
	for eff in effects:
		if eff.target_type.is_manual_target():
			eff.skill_targets = targets.pop_front()
		else:
			eff.select_targets(allies, enemies)
	
# After processing all the groups with target info, this should be called to
# verify if all the caster and target data has been loaded in the groups. If not,
# the skill invocation should be canceled and attempted again.
func is_valid() -> bool:
	for group in effects:
		if not group.is_valid():
			return false
	return true

# Creates a deep copy of this skill and all its effects. This is necesary in case
# the same skill is added to different characters or a character is cloned, so
# that changing the values in one effect don't affect the others
func copy() -> Skill:
	var new_skill = self.duplicate(true) as Skill
	var new_effects: Array[Effect] = []
	for eff in effects:
		new_effects.append(eff.copy())
	new_skill.effects = new_effects
	return new_skill
