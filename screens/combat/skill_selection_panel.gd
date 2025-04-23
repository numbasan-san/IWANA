# TODO: This is a duplicate of the EffectSelectionBox. Make it so they inherit
# from the same superclass, or change the code so that it works for any selection
class_name SkillSelectionPanel extends Panel

@export var grid: GridContainer

# The effect that is currently loaded to the grid.
var selection_effect: SkillSelectionEffect

var selection: Array[Skill] = []

signal selection_ended(selected: bool)

func fill_skills_list(effect: SkillSelectionEffect):
	_clear_grid()
	selection_effect = effect
	for skill in selection_effect.list:
		var button = Button.new()
		button.text = skill.name
		button.tooltip_text = skill.description
		button.add_theme_font_size_override("font_size", 30)
		# Disabled to avoid accidentally selecting effects.
		# TODO: Make the style changing code better
		button.disabled = true
		button.pressed.connect(func():
			if selection.size() >= selection_effect.quantity:
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
	selection_effect = null
	selection = []

func _select_random():
	if selection_effect == null:
		printerr("SkillSelectionBox | No SkillSelectionEffect to select from")
		return
	var list = selection_effect.list.duplicate()
	var n = selection_effect.quantity
	if n > list.size():
		printerr("SkillSelectionBox | Trying to select " + str(n) + " skills " + \
			"from a list of " + str(list.size()))
		return
	
	selection = []
	while n > 0:
		var skill = list.pick_random()
		list.erase(skill)
		selection.append(skill)
		n -= 1

func start_selection():
	if selection_effect.select_random:
		_select_random()
		on_accept_pressed()
	else:
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
	selection_effect.chosen = selection
	selection = []
	hide_selection()
	selection_ended.emit(true)
	
func on_cancel_pressed():
	selection = []
	selection_effect.chosen = []
	hide_selection()
	selection_ended.emit(false)
