class_name SkillsMenu extends Control

@export var combat: CombatScreenControl
@export var character_slot: PortraitContainer
@export var skills_container: Container
@export var button_model: Button

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
			button.show()
			# We can enable or disable the buttons here based on the energy of
			# the selected character. The only way of regaining energy is
			# through defending and possibly using items, and that regeneration
			# happens between turns, so there is no need to change the button
			# status after they have been added
			if skill.energy_cost <= character.combat_handler.stats.energy:
				button.pressed.connect(
					func():
						# TODO: all skills will target the chosen enemy even if
						# it is defeated earlier and the skills will be wasted.
						# Change it later to a system where if the target has
						# already fallen, a new target can be chosen
						var required_targets = skill.get_manual_targets()
						var target_sets = []
						for t_type in required_targets:
							show_possible_targets(t_type, character)
							await finished_targeting
							target_sets.append(current_targets)
							current_targets = []
						hide_targets()
						skill.process_effects(combat.player_party, combat.enemy_party, target_sets)
						if not skill.is_valid():
							printerr("SkillMenu | The selected number of targets don't match " \
								+ "with the required number for skill " + skill.name)
						else:
							character.combat_handler.execute(skill)
							combat.remove_dead()
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
		if t_type.exclude_caster:
			possible_targets.erase(caster)
	
	var callable = _add_target_to_current.bind(t_type.number_of_targets)
	for container in possible_targets:
		if container.character and container.character.combat_handler.stats.health > 0:
			container.targeting_enabled = true
			container.target_selected.connect(callable)

# Clears the target highlighting for every container and blocks the code that
# allows for their selection
func hide_targets():
	var containers: Array[SpriteContainer] = []
	containers.append(combat.enemy_area.get_children())
	containers.append(combat.player_area.get_children())
	
	for container in combat.enemy_area.get_children():
		container.targeting_enabled = false
		if container.target_selected.is_connected(_add_target_to_current):
			container.target_selected.disconnect(_add_target_to_current)

# TODO: temporary function to add targets to current list when receiving a signal
func _add_target_to_current(target: Character, limit: int):
	current_targets.append(target)
	if current_targets.size() == limit:
		finished_targeting.emit()
