## Part of the combat screen in charge of preparing the skills for their execution.
##
## For each effect in the skill this module selects the targets for it if it can,
## or allows the player to select them manually otherwise. Then, if the effect
## requests the selection of other effects or skills, it also selects them or
## prompts the player for them. It finally evaluates conditional effects to pick
## the appropiate branches.
## Once it's all done, the skill has all the information to be executed and its
## effects applied.
class_name SelectionModule extends Control

signal finished_targeting
# Can be null if we attempted to process a character that wasn't in this group.
signal turn_finished(character: Character)

var combat: CombatScreenControl
var left_area: CombatPartyArea
var right_area: CombatPartyArea

var character: Character
var current_area: CombatPartyArea
var enemy_area: CombatPartyArea

var current_state: CombatScreenControl.State

var loop_running = true

# TODO: temporary variable to hold targets. Move to a better place
var current_targets: Array[Character] = []

func _input(_event):
	if current_area.player_controled and Input.is_action_just_released("combat_menu_back"):
		if current_state == combat.State.SELECTING_SKILL:
			combat.skill_selected.emit(null)
		

## Selects targets, skills and effects and returns an effect ready to be applied.
##
## Depending on the nature of the argument or the amount of targets selected,
## this function can return a copy of the given effect or a new one.
func process_effect(effect: Effect) -> Effect:
	
	return effect

## Selects the character actions and skills and fills the data required to execute them.
# TODO: maybe the logic for selecting this stuff should be moved to the characters
# themselves, in an AI module.
func loop(character: Character):
	self.character = character
	current_state = combat.State.SELECTING_ACTION
	loop_running = true
	var skill: Skill
	if left_area.has(character):
		current_area = left_area
		enemy_area = right_area
	else:
		current_area = right_area
		enemy_area = left_area
	# When entering a state, all information previously obtained in that state is
	# reset so that if we go back to that state from a future one, all changes
	# made in those are reverted and we go back to a clean state.
	# When in a specific state and running a function, the execution should pause
	# until we get all the data needed or the action is cancelled.
	# When returning succesfully with the data from a function, we should change
	# the state to the next one, and the loop will continue executing and reach
	# that next state, where it will pause again.
	# If the function fails or the user press the back key, the state will be
	# changed to the previous one and the loop will continue. This will make it
	# go to the next iteration, clean the state and start again.
	while (loop_running):
		if current_state == combat.State.SELECTING_ACTION:
			combat.show_party_menu()
			var action =  await _choose_action(character)
			if action == combat.Action.NONE:
				continue
			elif action == combat.Action.RUN:
				_action_run()
			elif action == combat.Action.DEFEND:
				_action_defend(character)
			elif action == combat.Action.ATTACK:
				_action_attack()

		elif current_state == combat.State.SELECTING_SKILL:
			skill = await _choose_skill(character)
			if !skill:
				current_state = combat.State.SELECTING_ACTION
			else:
				current_state = combat.State.EXECUTING
		
		elif current_state == combat.State.EXECUTING:
			skill.status = skill.Status.NEW
			if !current_area.player_controled:
				# We turn all manual target types into random for computer characters.
				skill = _turn_skill_auto(character, skill)
			await character.combat_handler.execute(
				skill,
				current_area.characters,
				enemy_area.characters,
				combat)
			
			if skill.status == skill.Status.EXECUTED:
				current_state = combat.State.END
			# For now we don't handle exceptional cases and just go back to
			# select another skill.
			else:
				current_state = combat.State.SELECTING_SKILL
		
		elif current_state == combat.State.END:
			_loop_ended(character)

## Choose between attacking, defending or running away.
func _choose_action(character: Character) -> CombatScreenControl.Action:
	if !current_area.player_controled:
		# For now, enemies only attack unless out of skills.
		var skills = character.combat_handler.skills.filter(func(s: Skill):
			return s.enabled
		)
		if skills.size() > 0:
			return combat.Action.ATTACK
		else:
			return combat.Action.DEFEND
	else:
		var action = await combat.action_selected
		return action

## Called when the character has chosen to attack.
func _action_attack():
	current_state = combat.State.SELECTING_SKILL

## Called when the character has chosen to defend.
func _action_defend(character: Character):
	# TODO: maybe turn defense into a skill
	await Defense.new().execute(character)
	current_state = combat.State.END

## Called when the character has chosen to run.
# TODO: we must decide if running only makes the character rescape or the entire
# party (currently party escapes)
func _action_run():
	combat.display_text('Como buen cobarde, huiste.')
	await combat.textbox_closed
	await get_tree().create_timer(0.5).timeout
	combat.request_battle_end.emit()
	current_state = combat.State.END

## Called when the character finished selecting its actions and ended its turn.
func _loop_ended(character: Character):
	character.combat_handler.end_turn()
	loop_running = false

## Called when the character must choose a skill to execute.
# TODO: Currently all the characters in the right area are controlled by the
# player and all the ones in the left area are controlled by the computer.
# Consider changing it so that each individual character can be controlled manually
# or not.
func _choose_skill(character: Character) -> Skill:
	if current_area.player_controled:
		return await _choose_skill_manual(character)
	else:
		return _choose_skill_auto(character)

## Used by characters that are controlled by the computer.
func _choose_skill_auto(character: Character) -> Skill:
	var handler = character.combat_handler
	var available_skills: Array[Skill] = handler.skills.filter(func(skill):
		return skill.enabled
	)
	if available_skills.size() > 0:
		var skill: Skill = available_skills.pick_random()
		handler.last_skill = skill
		return skill
	else:
		return null

## Used to show the player the skill menu to select a skill manually.
func _choose_skill_manual(character: Character) -> Skill:
	combat.skills_menu.set_character(character)
	combat.show_skills_menu()
	return await combat.skill_selected

func _turn_skill_auto(character: Character, skill: Skill) -> Skill:
	var altered_skill = skill.copy()
	for eff in altered_skill.effects:
		if eff.target_type.is_manual_target():
			var t_type = eff.target_type as TargetVariable
			t_type.random = true
	return altered_skill

func _fill_skill_data_manual(character: Character, skill: Skill):
	var altered_skill = skill.copy()
	for effect in altered_skill.effects:
		var t_type = effect.target_type
		# Select manual targets
		if t_type.is_manual_target():
			show_possible_targets(effect, t_type, character)
			await finished_targeting
			effect.skill_targets = current_targets
			current_targets = []
		# Select automatic targets
		else:
			effect.select_targets(combat.right_area.characters, combat.left_area.characters)
		hide_targets()
		# Choose effects from selection list
		# TODO: this doesn't work if the selection effect is inside
		# another effect, like a group.
		if effect is SelectionEffect:
			effect_selection_box.fill_effects_list(effect)
			effect_selection_box.start_selection()
			var complete = false
			# If selecting randomly, we can't wait to receive a signal.
			
			if effect.select_random:
				# If we didn't make a selection or there was an error,
				# the chosen array will be empty.
				complete = effect.chosen.size() > 0
			else:
				complete = await effect_selection_box.selection_ended
			# If the selection was canceled, the effect processing stops
			# and the skill's is_valid function will return false.
			if not complete:
				break
		# Choose skills from selection list
		# TODO: this doesn't work if the selection effect is inside
		# another effect, like a group.
		if effect is SkillSelectionEffect:
			skill_selection_box.fill_skills_list(effect)
			skill_selection_box.start_selection()
			var complete = await skill_selection_box.selection_ended
			# If the selection was canceled, the effect processing stops
			# and the skill's is_valid function will return false.
			if not complete:
				break
		# TODO: change this code. This is only temporary until I
		# think of something better. For now there are only a few
		# skills that allow effect selection, and it is either on the
		# top level or inside a group, so this should work. However
		# this must be changed to work correctly for conditional and
		# chained effects, and we must think how we will handle when 
		# there are several selections in a group.
		elif effect is EffectGroup:
			for eff in effect.effects:
				# This only works for the first selection effect found
				# in the group, and it doesn't search recursively. That
				# is enough for the current skills but it's not robust.
				if eff is SelectionEffect:
					effect_selection_box.fill_effects_list(eff)
					effect_selection_box.start_selection()
					var complete = await effect_selection_box.selection_ended
					# If the selection was canceled, the effect processing stops
					# and the skill's is_valid function will return false.
					if not complete:
						break
				# This only works for the first selection effect found
				# in the group, and it doesn't search recursively. That
				# is enough for the current skills but it's not robust.
				if eff is SkillSelectionEffect:
					skill_selection_box.fill_skills_list(eff)
					skill_selection_box.start_selection()
					var complete = await skill_selection_box.selection_ended
					# If the selection was canceled, the effect processing stops
					# and the skill's is_valid function will return false.
					if not complete:
						break
	
	if not skill.is_valid():
		printerr("SkillMenu | The selected number of targets don't match " \
			+ "with the required number for skill " + skill.name)
	else:
		await character.combat_handler.execute(skill)
		character.combat_handler.end_turn()
		await combat.show_party_menu()
		combat.next_turn()
	
# For skills that allow the selection of one or more targets, this function
# highlights the possible targets and enables their selection to feed them to
# the skill execution code. For skills that select the target automatically this
# function should do nothing. The caster argument is checked when we need to
# exclude the caster from the targets
func show_possible_targets(effect: Effect, t_type: TargetVariable, caster: Character):
	hide_targets()
	if not effect.t_type.is_manual_target():
		return
		
	var possible_targets: Array[SpriteContainer] = []
	if effect.t_type is TargetEnemy or effect.t_type is TargetAnyone:
		possible_targets.append_array(left_area.get_children())
	if t_type is TargetFriend or t_type is TargetAnyone:
		possible_targets.append_array(right_area.get_children())
		if t_type.exclude_self:
			possible_targets = possible_targets.filter(func(container):
				return not (container.character == caster)
			)
	
	var callable = _add_target_to_current.bind(t_type.number_of_targets)
	for container in possible_targets:
		if container.character and not container.character.combat_handler.stats.unconscious:
			container.targeting_enabled = true
			container.target_selected.connect(callable)

# Clears the target highlighting for every container and blocks the code that
# allows for their selection
func hide_targets():
	var containers: Array[SpriteContainer] = []
	containers.append_array(left_area.get_children())
	containers.append_array(right_area.get_children())
	
	for container in containers:
		container.targeting_enabled = false
		if container.target_selected.is_connected(_add_target_to_current):
			container.target_selected.disconnect(_add_target_to_current)

# TODO: temporary function to add targets to current list when receiving a signal
func _add_target_to_current(target: Character, limit: int):
	current_targets.append(target)
	if current_targets.size() == limit:
		finished_targeting.emit()
