class_name CharacterContainer
extends Panel

@export var fill_bars: FillBars

# The character associated to this container whose stats and textures are going
# to be shown
var character: Character

# Assigns a character to this character slot in the gui to monitor its stats
func set_character(new_character: Character = null):
	# We must first remove the previous character, if any, and then we can add
	# the new one if it's not null.
	remove_character()
	if new_character:
		character = new_character
		
		if fill_bars:
			var handler = character.combat_handler
			fill_bars._update_max_health(0, handler.stats.max_health)
			handler.stats.update_max_health.connect(fill_bars._update_max_health)
			fill_bars._update_health(0, handler.stats.health)
			handler.stats.update_health.connect(fill_bars._update_health)
			fill_bars._update_max_energy(0, handler.stats.max_energy)
			handler.stats.update_max_energy.connect(fill_bars._update_max_energy)
			fill_bars._update_energy(0, handler.stats.energy)
			handler.stats.update_energy.connect(fill_bars._update_energy)
			fill_bars.show()
# If this container has a character registered, it removes it and disconnects
# all signals
func remove_character():
	if character:
		if fill_bars:
			var handler = character.combat_handler
			handler.stats.update_max_health.disconnect(fill_bars._update_max_health)
			handler.stats.update_health.disconnect(fill_bars._update_health)
			handler.stats.update_max_energy.disconnect(fill_bars._update_max_energy)
			handler.stats.update_energy.disconnect(fill_bars._update_energy)
			fill_bars.hide()
		character = null
