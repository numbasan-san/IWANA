class_name EffectSelectionBox extends Panel

@export var grid: GridContainer

@export var accept: Button
@export var cancel: Button

# The effect that is currently loaded to the grid.
var selection_effect: SelectionEffect

var selection: Array[Effect] = []

signal selection_ended(selected: bool)

func fill_effects_list(effect: SelectionEffect):
	_clear_grid()
	selection_effect = effect
	for eff in selection_effect.list:
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
			if selection.size() >= selection_effect.quantity:
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
	selection_effect = null

func _select_random():
	if selection_effect == null:
		printerr("EffectSelectionBox | No SelectionEffect to select from")
		return
	var list = selection_effect.list.duplicate()
	var n = selection_effect.quantity
	if n > list.size():
		printerr("EffectSelectionBox | Trying to select " + str(n) + " effects " + \
			"from a list of " + str(list.size()))
		return
	
	selection = []
	while n > 0:
		var eff = list.pick_random()
		list.erase(eff)
		selection.append(eff)
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
	hide_selection()
	selection_ended.emit(false)
