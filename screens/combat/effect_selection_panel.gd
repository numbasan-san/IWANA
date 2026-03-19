class_name EffectSelectionPanel extends Panel

@export var grid: GridContainer

var selection: Array[Effect] = []

signal selection_ended(selected: Array[Effect])

func fill_effects_list(effect: SelectionEffect):
	_clear_grid()
	for eff in effect.list:
		var button = Button.new()
		eff.init_base_data()
		button.icon = eff.base_data.icon
		button.tooltip_text = eff.base_data.name + "\n" + \
			eff.base_data.description
		button.add_theme_font_size_override("font_size", 30)
		# Disabled to avoid accidentally selecting effects.
		# TODO: Make the style changing code better
		button.disabled = true
		button.pressed.connect(func():
			if selection.size() >= effect.quantity:
				var old_effect = selection.pop_front()
				for child in grid.get_children():
					var eff_button = child as Button
					if eff_button.text == old_effect.name:
						var style = eff_button.get_theme_stylebox("normal").duplicate()
						style.border_color = Color(0.18, 0.18, 0.18)
						eff_button.add_theme_stylebox_override("normal", style)
				selection.remove_at(0)
			selection.push_back(eff)
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

func start_selection(effect: SelectionEffect):
	selection = []
	fill_effects_list(effect)
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
