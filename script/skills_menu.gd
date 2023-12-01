class_name SkillsMenu extends Control

@export var combat: CombatControl
@export var character_slot: CharacterCombatContainer
@export var skills_container: Container
@export var button_model: Button

# This is temporary, it might go somewhere more global
@onready var font = load("res://assets/combat_sprites/font/IWANA.ttf")

func set_to_character(character: Character = null):
	character_slot.set_to_character(character)
	_clear_skill_buttons()
	if character:
		var buttons: Array[Button] = []
		for skill in character.skills:
			var button = button_model.duplicate() as Button
			button.text = skill.name
			button.show()
			# We can enable or disable the buttons here based on the energy of
			# the selected character. The only way of regaining energy is
			# through defending and possibly using items, and that regeneration
			# happens between turns, so there is no need to change the button
			# status after they have been added
			if skill.energy_cost <= character.stats.energy:
				button.pressed.connect(
					func():
						# TODO: all skills will target the chosen enemy even if
						# it is defeated earlier and the skills will be wasted.
						# Change it later to a system where if the target has
						# already fallen, a new target can be chosen
						var target: Character
						for enemy in combat.enemy_party.members:
							if enemy.stats.health > 0:
								target = enemy
								break
						var action = CombatAction.new(skill, character, target)
						combat.action_queue.append(action)
						# TODO: Maybe the following code should be performed by the
						# combat control, by emiting a signal when this is done
						combat.party_menu.select_next_character()
						await combat.show_party_menu()
						if not combat.party_menu.selected_character:
							combat.action_phase()
				)
			else:
				button.disabled = true
			buttons.append(button)
			skills_container.add_child(button)
		if buttons.size() > 0:
			buttons[0].grab_focus()
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
