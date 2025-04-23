# TODO: This is a duplicate of the EffectSelectionBox. Make it so they inherit
# from the same superclass, or change the code so that it works for any selection
class_name SkillSelectionPanel extends Panel

@export var grid: GridContainer

var selection: Array[Effect] = []

signal selection_ended(selected: Array[Effect])

func fill_skills_list(effect: SkillSelectionEffect):
	_clear_grid()
	for skill in effect.list:
		var button = Button.new()
		button.text = skill.name
		button.tooltip_text = skill.description
		button.add_theme_font_size_override("font_size", 30)
		# Disabled to avoid accidentally selecting effects.
		# TODO: Make the style changing code better
		button.disabled = true
		button.pressed.connect(func():
			if selection.size() >= effect.quantity:
				var old_skill = selection.pop_front()
				for child in grid.get_children():
					var skill_button = child as Button
					if skill_button.text == old_skill.name:
						var style = skill_button.get_theme_stylebox("normal").duplicate()
						style.border_color = Color(0.18, 0.18, 0.18)
						skill_button.add_theme_stylebox_override("normal", style)
				selection.remove_at(0)
			selection.push_back(skill)
			var style = button.get_theme_stylebox("normal").duplicate()
			style.border_color = Color(0.85, 0.75, 0)
			button.add_theme_stylebox_override("normal", style)
		)
		grid.add_child(button)
	
func _clear_grid():
	for child in grid.get_children():
		grid.remove_child(child)
		child.free()
	selection = []

func start_selection(effect: SkillSelectionEffect):
	selection = []
	fill_skills_list(effect)
	show_selection()

func show_selection():
	if not self.visible:
		for button in grid.get_children():
			button.disabled = false
		self.show()

func hide_selection():
	if self.visible:
		self.hide()
		for button in grid.get_children():
			button.disabled = true

func on_accept_pressed():
	selection_ended.emit(selection)
	selection = []
	hide_selection()
	
func on_cancel_pressed():
	selection = []
	selection_ended.emit(selection)
	hide_selection()
