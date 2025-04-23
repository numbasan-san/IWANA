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

# A description that is shown to the player in menus or tooltips that explain
# what it does
@export_multiline var description: String

## The list of effect groups to be applied by this skill.
##
## Each group has its own possible targets, and when using this skill it should
## prompt to choose targets for each one that isn't chosen automatically.
@export var effects: Array[Effect]:
	set(new_effects):
		effects = new_effects
		for eff in effects:
			eff.skill = self

## How much energy using this skill consumes.
##
## If the character doesn't have enough energy they can't perform the skill.
@export var energy_cost: int

## Who is the character that is performing the skill.
##
## This value will propagate to every effect and sub-effect in the skill, so if
## any effect should have a different caster it must be changed in its own script.
var caster: Character:
	set(value):
		caster = value
		for eff in effects:
			eff.caster = caster

# If this is false, the skill has been disabled by some other skill, a debuff or
# some other external condition, and it cannot be used.
var enabled: bool = true

enum Status {
	NEW, ## 
	INITIALIZED,
	EXECUTED,
	UNCONSCIOUS,
	LOW_ENERGY,
	DISABLED,
	CANCELLED,
	ERROR
}

var status: Status

# Calling this function will fill caster and target data for each effect. and return
# an array with all the effects and sub effects already processed. All the returned
# effects will be copies so none of the originals will be changed.
func process_effects(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler) -> Array[Effect]:
	
	var result: Array[Effect] = []
	for eff in effects:
		# Note that in this first call, the parent_target argument is null. That means
		# that the first effects in the skill need a target type or it will be an error.
		# In that case, we will return an empty array and let the caller deal with it.
		# TODO: add some kind of error system, maybe emiting error signals that
		# can be listened to.
		var processed = await eff.process_effect(allies, enemies, handler)
		# This status is set while manually selecting targets to indicate the
		# player cancelled the selection.
		if status == Status.CANCELLED:
			return []
		if processed.size() == 0:
			status = Status.ERROR
			return []
		result.append_array(processed)
	
	# We verify that every effect has their caster and target set.
	for eff in result:
		if !eff.is_valid():
			status = Status.ERROR
			return []
	
	status = Status.INITIALIZED
	return result

# Creates a deep copy of this skill and all its effects. This is necesary in case
# the same skill is added to different characters or a character is cloned, so
# that changing the values in one effect don't affect the others.
# We need this custom function because a resource duplicate method won't deep copy
# the effects array, and the array's duplicate method won't deep copy it's effect
# resources.
func copy() -> Skill:
	var new_skill = self.duplicate(true) as Skill
	var new_effects: Array[Effect] = []
	for eff in effects:
		new_effects.append(eff.copy())
	new_skill.effects = new_effects
	return new_skill
