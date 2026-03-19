class_name CharacterStatsOverlay extends Panel

@export var stats: VBoxContainer

var character: Character:
	set(value):
		_character = value
		for stat in stats.get_children():
			stat.character = value
	get:
		return _character
var _character: Character
