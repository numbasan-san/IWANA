## Part of the combat screen in charge of preparing the skills for their execution.
##
## For each effect in the skill this module selects the targets for it if it can,
## or allows the player to select them manually otherwise. Then, if the effect
## requests the selection of other effects or skills, it also selects them or
## prompts the player for them. It finally evaluates conditional effects to pick
## the appropiate branches.
## Once it's all done, the skill has all the information to be executed and its
## effects applied.
class_name TurnHandler extends Control

signal finished_targeting(targets: Array[Character])
# Can be null if we attempted to process a character that wasn't in this group.
signal turn_finished(character: Character)

@export var effect_selection_panel: EffectSelectionPanel
@export var skill_selection_panel: SkillSelectionPanel

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

# TODO: this doesn't behave correctly if one presses the action keys while some
# processing is already happened. We should only enable this when the player is
# actually supposed to have control.
func _input(_event):
	if Input.is_action_just_released("combat_menu_back") and current_area.player_controled:
		if current_state == combat.State.SELECTING_SKILL:
			combat.skill_selected.emit(null)
		elif current_state == combat.State.EXECUTING:
			_cancel_target_selection()
		

## Selects the character actions and skills and fills the data required to execute them.
# TODO: maybe the logic for selecting this stuff should be moved to the characters
# themselves, in an AI module.
func run_turn(character: Character):
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
			combat.party_menu.select_character(character)
			await combat.show_party_menu()
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
				self)
			
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
	loop_running = false

## Called when the character must choose a skill to execute.
# TODO: Currently all the characters in the right area are controlled by the
# player and all the ones in the left area are controlled by the computer.
# Consider changing it so that each individual character can be controlled manually
# or not.
func _choose_skill(character: Character) -> Skill:
	combat.skills_menu.set_character(character)
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
	await combat.show_skills_menu()
	return await combat.skill_selected

func _turn_skill_auto(character: Character, skill: Skill) -> Skill:
	var altered_skill = skill.copy()
	for eff in altered_skill.effects:
		if eff.target_type.is_manual_target():
			var t_type = eff.target_type as TargetVariable
			t_type.random = true
	return altered_skill

# For skills that allow the selection of one or more targets, this function
# highlights the possible targets and enables their selection to feed them to
# the skill execution code. For skills that select the target automatically this
# function should do nothing. The caster argument is checked when we need to
# exclude the caster from the targets
func show_possible_targets(effect: Effect):
	hide_targets()
	current_targets = []
	
	if not effect.target_type.is_manual_target():
		return
	
	var t_type = effect.target_type as TargetVariable
	var n_targets = t_type.number_of_targets
	
	var add_target = _add_target_to_current.bind(n_targets)
	
	if t_type is TargetEnemy or t_type is TargetAnyone:
		enemy_area.target_selected.connect(add_target)
		enemy_area.show_targets()
	if t_type is TargetFriend or t_type is TargetAnyone:
		current_area.target_selected.connect(add_target)
		if t_type.exclude_self:
			var callable = func(char: Character): return char == effect.caster
			current_area.show_targets(callable)
		else:
			current_area.show_targets()

# Clears the target highlighting for every container and blocks the code that
# allows for their selection
func hide_targets():
	# TODO: We connected to the signals the _add_target_to_current function bound
	# to an int. If that is a different callable than the unbound function, it
	# won't disconnect here and we'll have to think of something else.
	if current_area.target_selected.is_connected(_add_target_to_current):
		current_area.target_selected.disconnect(_add_target_to_current)
	current_area.hide_targets()
	if enemy_area.target_selected.is_connected(_add_target_to_current):
		enemy_area.target_selected.disconnect(_add_target_to_current)
	enemy_area.hide_targets()
	
# TODO: temporary function to add targets to current list when receiving a signal
func _add_target_to_current(target: Character, limit: int):
	current_targets.append(target)
	if current_targets.size() == limit:
		finished_targeting.emit(current_targets)
		current_targets = []
		hide_targets()

# Called when we manually cancel target selection, we return an empty array to
# signal this.
func _cancel_target_selection():
	current_targets = []
	finished_targeting.emit(current_targets)
	hide_targets()
