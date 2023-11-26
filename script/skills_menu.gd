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
						var action = CombatAction.new(skill, character, combat.enemy)
						combat.action_queue.append(action)
						# TODO: Maybe the following code should be performed by the
						# combat control, by emiting a signal when this is done
						await combat.show_party_menu()
						combat.party_menu.select_next_character()
						if not combat.party_menu.selected_character:
							combat.action_phase()
				)
			else:
				button.disabled = true
			skills_container.call_deferred("add_child", button)

func _clear_skill_buttons():
	for button in skills_container.get_children():
		button.call_deferred("free")
