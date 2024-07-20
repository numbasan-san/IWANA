class_name CombatHandler extends Node

@export var stats: Stats
@export var skills: Array[Skill]

var character: Character

signal added_lasting_effect
signal removed_lasting_effect

# Status effects are effects that apply to the character the moment the skill
# lands on it and are removed when a condition is reached

# These are buffs and debuffs that only modify the character's stats.
# When one of these effects enters the list its on_apply function should be
# called to modify the stats, and when it exits its on_unapply function should
# be called to undo the applied changes
var stat_modifiers: Array[LastingEffect]

# These are buffs and debuffs that intercept the effects coming from
# another character, either friend or enemy, and can modify them before applying
# them, redirect them or even prevent them completely.
var incoming_effect_modifiers: Array[LastingEffect]

# These are buffs and debuffs that intercept the effects of skills used by this
# character and can modify them before sending them to a target
var outgoing_effect_modifiers: Array[LastingEffect]

# These are buffs and debuffs that activate their effects when the affected
# character sends another effect that hits its target
var character_hit_monitors: Array[LastingEffect]

func init():
	stats.fainted.connect(func():
		for eff in stat_modifiers:
			removed_lasting_effect.emit(eff)
		stat_modifiers.clear()
		for eff in outgoing_effect_modifiers:
			removed_lasting_effect.emit(eff)
		outgoing_effect_modifiers.clear()
		for eff in incoming_effect_modifiers:
			removed_lasting_effect.emit(eff)
		incoming_effect_modifiers.clear()
		for eff in character_hit_monitors:
			removed_lasting_effect.emit(eff)
		character_hit_monitors.clear()
	)

func execute(skill: Skill):
	if stats.energy < skill.energy_cost:
		printerr("Skill | " + character.name + " tried to use a skill without having" \
			+ " the required energy of " + str(skill.energy_cost) + ". This shouldn't" \
			+ " happen as this should be prevented in the combat screen before" \
			+ " selecting the skill")
		return
	
	for effect in skill.effects:
		if effect.is_nullified:
			continue
		var copy: Effect = effect.copy()
		send(copy)
		
	stats.energy -= skill.energy_cost

# Calculates the initial value of this effect, modifies it based on the caster
# buffs and debuffs, and sends it to the target
func send(effect: Effect):
	# If everything went correctly, effect.caster == character
	effect.cast(effect.caster)
	# If on_cast nullifies the effect, we interrupt the rest of the process
	if effect.is_nullified:
		return
	for out in outgoing_effect_modifiers:
		out.intercept(effect)
		# We check if the interception reduced the duration of the interceptor
		end_of_duration(out)
		# The effect must survive all interceptions in order to continue
		if effect.is_nullified:
			return
	for t in effect.skill_targets:
		# We copy the effect for each of the target, so modifications to the
		# effect sent to one target doesn't alter effects sent to others
		var copy = effect.copy()
		copy.send(t)
		# If on_send nullifies the effect, it only interrupts the copy being sent
		# to the current target. Other copies might still be sent
		if copy.is_nullified:
			continue
		# We split the effect groups here to send all its sub-effects individually
		# so that the target has the chance to intercept them
		if copy is EffectGroup:
			for eff in copy.effects:
				eff.caster = copy.caster
				t.combat_handler.receive(eff)
		else:
			t.combat_handler.receive(copy)

# Receives an effect sent from a caster, modifies it based on the character's
# buffs and debuffs, and if the effect survives it is applied.
func receive(effect: Effect):
	# We set target here in case this function was called directly and the
	# caller forgot to set it. As the effect was sent to this character, it is
	# assumed that it is the intended target
	effect.target = character
	# We check this here in case this function was called directly.
	# We don't check if the conditional is nullified as its on_receive function 
	# will do nothing anyways
	if effect is ConditionalEffect:
		effect = effect.evaluate()
	effect.receive(effect.caster)
	# If on_receive nullifies the effect, we interrupt the rest of the process
	if effect.is_nullified:
		return
	for inc in incoming_effect_modifiers:
		inc.intercept(effect)
		# We check if the interception reduced the duration of the interceptor
		end_of_duration(inc)
		# The effect must survive all interceptions in order to continue
		if effect.is_nullified:
			return
	# If we have reached this point, the effect has survived and must be applied.
	# If it's a lasting effect, it must be added to the corresponding list
	if effect is LastingEffect:
		var Mod = LastingEffect.Modify
		match effect.modifies:
			Mod.STAT:
				stat_modifiers.append(effect)
			Mod.INCOMING:
				incoming_effect_modifiers.append(effect)
			Mod.OUTGOING:
				outgoing_effect_modifiers.append(effect)
			Mod.CHARACTER_HIT:
				character_hit_monitors.append(effect)
		added_lasting_effect.emit(effect)
	effect.apply(character)
	effect.caster.combat_handler.after_character_hit(character, effect)

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
	for eff in character_hit_monitors:
		eff.character_hit(who, effect)

# Checks if the duration of the effect has been reduced to 0, in which case the
# effect is removed from its list and it's unapplied
func end_of_duration(effect: LastingEffect):
	if effect.duration <= 0:
		var Mod = LastingEffect.Modify
		match effect.modifies:
			Mod.STAT:
				stat_modifiers.erase(effect)
			Mod.INCOMING:
				incoming_effect_modifiers.erase(effect)
			Mod.OUTGOING:
				outgoing_effect_modifiers.erase(effect)
			Mod.CHARACTER_HIT:
				character_hit_monitors.erase(effect)
		removed_lasting_effect.emit(effect)
		effect.unapply(character)

# Calls the given function on all the lasting effects registered for this handler,
# and checks if the duration has decreased. The passed function must be one of
# before_turn, after_turn, before_hit or after_hit
func _perform_on_lasting_effects(function_name: String):
	var lasting: Array[LastingEffect] = stat_modifiers.duplicate()
	lasting.append_array(incoming_effect_modifiers)
	lasting.append_array(outgoing_effect_modifiers)
	lasting.append_array(character_hit_monitors)
	for eff in lasting:
		eff.call(function_name, character)
		# This is checked here in case some effect decreases its duration at the
		# beginning of the turn
		end_of_duration(eff)
