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
				# TODO: when the new system is implemented, we must remove this and
				# make it so it triggers the skill selection in the selection module.
				#button.pressed.connect(
				#	func():
				#		combat.skill_selected.emit(skill)
				#)
				button.pressed.connect(func(): combat.skill_selected.emit(skill))
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
