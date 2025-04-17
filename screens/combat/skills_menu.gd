class_name SkillsMenu extends Control

@export var combat: CombatScreenControl
@export var character_slot: PortraitContainer
@export var skills_container: Container
@export var button_model: Button
@export var effect_selection_box: EffectSelectionBox
@export var skill_selection_box: SkillSelectionBox

# TODO: This is temporary, it might go somewhere more global
@onready var font = load("res://assets/combat_sprites/font/IWANA.ttf")

# TODO: temporary variable to hold targets. Move to a better place
var current_targets: Array[Character] = []
signal finished_targeting

func set_character(character: Character = null):
	character_slot.set_character(character)
	_clear_skill_buttons()
	if character:
		var buttons: Array[Button] = []
		for skill in character.combat_handler.skills:
			var button = button_model.duplicate() as Button
			button.text = skill.name
			button.tooltip_text = skill.description
			button.show()
			# We can enable or disable the buttons here based on the energy of
			# the selected character. The only way of regaining energy is
			# through defending and possibly using items, and that regeneration
			# happens between turns, so there is no need to change the button
			# status after they have been added
			if skill.enabled and skill.energy_cost <= character.combat_handler.stats.energy:
				button.pressed.connect(
					func():
						combat.selecting_action = false
						combat.selecting_skill = false
						combat.selecting_target = true
						var required_targets = skill.get_manual_targets()
						var target_sets = []
						# TODO: see if there is a better way to execute this code,
						# maybe from inside the skill class.
						for effect in skill.effects:
							var t_type = effect.target_type
							# Select manual targets
							if t_type.is_manual_target():
								show_possible_targets(t_type, character)
								await finished_targeting
								effect.skill_targets = current_targets
								current_targets = []
							# Select automatic targets
							else:
								effect.select_targets(combat.player_party, combat.enemy_party)
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
				)
			else:
				button.disabled = true
			buttons.append(button)
			skills_container.add_child(button)
		# We link each skill button to its next and previous buttons, so we can
		# change focus with the keyboard
		if buttons.size() > 1:
			var i = 0
			while i < buttons.size():
				# We use modulo so that when we are at the last element, the
				# next one will be element 0
				var next = buttons[(i + 1) % buttons.size()]
				# When we are at element 0, the previous element will be the
				# last one
				var prev = buttons[i - 1]
				buttons[i].focus_neighbor_bottom = next.get_path()
				buttons[i].focus_neighbor_top = prev.get_path()
				i += 1

func _clear_skill_buttons():
	for button in skills_container.get_children():
		button.free()

# For skills that allow the selection of one or more targets, this function
# highlights the possible targets and enables their selection to feed them to
# the skill execution code. For skills that select the target automatically this
# function should do nothing. The caster argument is checked when we need to
# exclude the caster from the targets
func show_possible_targets(t_type: TargetVariable, caster: Character):
	hide_targets()
	if not t_type.is_manual_target():
		return
		
	var possible_targets: Array[SpriteContainer] = []
	if t_type is TargetEnemy or t_type is TargetAnyone:
		possible_targets.append_array(combat.enemy_area.get_children())
	if t_type is TargetFriend or t_type is TargetAnyone:
		possible_targets.append_array(combat.player_area.get_children())
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
	containers.append_array(combat.enemy_area.get_children())
	containers.append_array(combat.player_area.get_children())
	
	for container in containers:
		container.targeting_enabled = false
		if container.target_selected.is_connected(_add_target_to_current):
			container.target_selected.disconnect(_add_target_to_current)

# TODO: temporary function to add targets to current list when receiving a signal
func _add_target_to_current(target: Character, limit: int):
	current_targets.append(target)
	if current_targets.size() == limit:
		finished_targeting.emit()
