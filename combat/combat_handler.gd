class_name CombatHandler extends Node

@export var stats: Stats
@export var skills: Array[Skill]

var character: Character

# Last skill used by the character. Currently used in effects that block the last
# skill.
var last_skill: Skill

# Used to determine how likely is this character to be targeted by a skill selecting
# random targets.
var target_weight: int = 1

# This indicate if the character is stuned, asleep, or under some other effect
# that forces it to skip a turn. This is different to being unconscious (0 hp)
# as this doesn't prevent the character from being targeted and don't count
# towards a victory condition.
var incapacitated: bool = false

signal added_lasting_effect
signal removed_lasting_effect
signal showing_graphic(anim: String)
signal moving_towards(target: Character)

# Lasting effects are effects that apply to the character the moment the skill
# lands on it and are removed when a condition is reached
var lasting_effects: Array[LastingEffect]

# These are special effects that instead of modifying the stats of the character
# and the effects of skills, play some animation or create some graphical effect
# when they intercept some other effect. For example, they could trigger
# an animation on the target when receiving a damage effect.
# This list should be filled when loading the game and there shouldn't be a reason
# to change its elements later.
var hit_animations: Array[LastingEffect]

func init():
	# We duplicate skills here because even when they're set to "local to resource",
	# it seems the array itself isn't being duplicated on instantiation, so all
	# clones share the same skills and mess with caster and target assignation.
	var new_skills: Array[Skill] = []
	for s in skills:
		var new_skill = s.copy()
		new_skill.caster = character
		new_skills.append(new_skill)
	skills = new_skills
	
	stats.raised.connect(func():
		character.combat_model.set_sprite("idle"))
	
	stats.fainted.connect(func():
		character.combat_model.set_sprite("fainted")
		for eff in lasting_effects:
			removed_lasting_effect.emit(eff)
		lasting_effects.clear()
	)
	var hit = load("res://combat/effects/animation_effects/graphical_hit_effect.tres").duplicate()
	hit.target = self.character
	hit_animations.append(hit)

## Processes all the effects of the skill and sends them to their targets.
##
## This function doesn't check that the executed skill actually belongs in the
## character's skill list, which allows it to execute slightly modified skills,
## skills that are available in cutscenes or specific parts of the story, or
## or for any other situation one can think of.
func execute(
		skill: Skill,
		allies: Array[Character],
		enemies: Array[Character],
		combat: CombatScreenControl):
	if stats.unconscious:
		skill.status = skill.Status.UNCONSCIOUS
		return
	if stats.energy < skill.energy_cost:
		printerr("Skill | " + character.name + " tried to use a skill without having" \
			+ " the required energy of " + str(skill.energy_cost) + ". This shouldn't" \
			+ " happen as this should be prevented in the combat screen before" \
			+ " selecting the skill")
		skill.status = skill.Status.LOW_ENERGY
		return
	# If the skill is disabled, it shouldn't have been selected in the first place
	# and the code shouldn't reach this point, but this is here just in case something
	# failed somewhere else.
	if not skill.enabled:
		skill.status = skill.Status.DISABLED
		return
	
	for eff in lasting_effects:
		await eff.skill_used(skill)
		end_of_duration(eff)
	
	var processed: Array[Effect] = skill.process_effects(allies, enemies, combat)
	
	for effect in processed:
		if effect.is_nullified:
			continue
		await send(effect)
		
	character.combat_model.set_sprite("idle")
	stats.energy -= skill.energy_cost
	skill.status = skill.Status.EXECUTED

# Calculates the initial value of this effect, modifies it based on the caster
# buffs and debuffs, and sends it to the target
func send(effect: Effect):
	# If everything went correctly, effect.caster == character
	await effect.cast(effect.caster)
	
	for out in lasting_effects:
		await out.outgoing(effect)
		# We check if the interception reduced the duration of the interceptor
		end_of_duration(out)
	
	if effect.is_nullified:
		return
	for t in effect.skill_targets:
		# We calculate here if the target evades the effect as this allows for
		# each target to evade independently.
		# If the evasion is succesful the rest of the code is ignored, but maybe
		# this should be changed to trigger some special animation or graphical
		# effect to give feedback.
		if not _hit(effect.caster, t):
			# TODO: Change this so it isn't a dedicated code for the dodge effect.
			# Maybe we should add an on_evade event that triggers on the caster
			# and the target when an effect is evaded.
			var dodge = t.combat_handler.lasting_effects.filter(func(eff):
				return eff is Dodge)
			if dodge.size() > 0:
				t.combat_handler.remove_lasting_effect(dodge[0])
			continue
		
		# We copy the effect for each of the target, so modifications to the
		# effect sent to one target doesn't alter effects sent to others
		var copy = effect.copy()
		await copy.send(t)
		
		await t.combat_handler.receive(copy)

# Receives an effect sent from a caster, modifies it based on the character's
# buffs and debuffs, and if the effect survives it is applied.
func receive(effect: Effect):
	# We set target here in case this function was called directly and the
	# caller forgot to set it. As the effect was sent to this character, it is
	# assumed that it is the intended target
	effect.target = character
	
	# We flatten the received effect so that we don't have to recursively iterate
	# over its possible sub effects.
	var all_effects = effect._flatten()
	
	for eff in all_effects:
		await eff.receive(eff.caster)
		for inc in lasting_effects:
			await inc.incoming(eff)
			# We check if the interception reduced the duration of the interceptor
			end_of_duration(inc)
		if eff.is_nullified:
			continue
		# If we have reached this point, the effect has survived and must be applied.
		# If it's a lasting effect, it must be added to the corresponding list
		if eff is LastingEffect:
			if not eff.stacks:
				# We create a copy to safely remove elements from the original.
				var copy = lasting_effects.duplicate()
				for e in copy:
					if eff.is_same_type(e):
						remove_lasting_effect(e)
			add_lasting_effect(eff)
			
		await eff.apply(character)
		for hit in hit_animations:
			await hit.incoming(eff)
		eff.caster.combat_handler.after_character_hit(character, eff)

# This function should be called when the character's turn has just begun, and
# it will trigger the before_turn function in all lasting effects
func start_turn():
	_perform_on_lasting_effects("start_turn")

# This function should be called when the character's turn has just ended, and
# it will trigger the after_turn function in all lasting effects
func end_turn():
	_perform_on_lasting_effects("end_turn")

# This function is called on the caster of an effect when it's been applied on
# it's target
func after_character_hit(who: Character, effect: Effect):
	for hit in lasting_effects:
		hit.character_hit(who, effect)

# Checks if the duration of the effect has been reduced to 0, in which case the
# effect is removed from its list and it's unapplied
func end_of_duration(effect: LastingEffect):
	if effect.duration <= 0:
		remove_lasting_effect(effect)

# Adds an effect to the corresponding array and sends a signal. This can be called
# from outside this class to ensure an effect is properly added.
func add_lasting_effect(effect: LastingEffect):
	lasting_effects.append(effect)
	added_lasting_effect.emit(effect)
	
# Removes an effect from the corresponding array and sends a signal. This can be called
# from outside this class to ensure an effect is properly removed.
func remove_lasting_effect(effect: LastingEffect):
	var removed: bool = false
	if lasting_effects.find(effect) >= 0:
		removed = true
		lasting_effects.erase(effect)
		
	if removed:
		removed_lasting_effect.emit(effect)
		effect.unapply(character)

func clear_lasting_effects():
	var _clear = func(array: Array[LastingEffect]):
		for eff in array:
			removed_lasting_effect.emit(eff)
			eff.unapply(character)
		array.clear()
	for eff in lasting_effects:
		removed_lasting_effect.emit(eff)
		eff.unapply(character)
	lasting_effects.clear()
	
# Calls the given function on all the lasting effects registered for this handler,
# and checks if the duration has decreased. The passed function must be one of
# before_turn, after_turn, before_hit or after_hit
func _perform_on_lasting_effects(function_name: String):
	for eff in lasting_effects:
		eff.call(function_name, character)
		# This is checked here in case some effect decreases its duration at the
		# beginning of the turn
		end_of_duration(eff)

# Calculates if the target can be hit by the effects, given by the precision and
# evasion values.
func _hit(caster: Character, target: Character) -> bool:
	if caster == target:
		return true
	var precision = caster.combat_handler.stats.precision
	var evasion = target.combat_handler.stats.evasion
	var chance = clampi(precision - evasion, 0, 100)
	var rnd = randi_range(1, 100)
	return chance >= rnd
