class_name StatsOverlay extends Control

# TODO: We only allow one overlay active at a time. When selecting another character
# we reuse the same one. Consider if we have to allow several overlays open at the
# same time
@export var character_overlay: CharacterStatsOverlay

var combat_area: CombatPartyArea

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_character_selected"):
		var position = get_global_mouse_position()
		var containers = combat_area.combat_grid.contents.values()
		for container in containers:
			container = container as SpriteContainer
			var rect = container.get_global_rect()
			if rect.has_point(position):
				character_overlay.character = container.character
				character_overlay.show()
				return
			
	elif event.is_action_pressed("dev_character_deselected"):
		character_overlay.character = null
		character_overlay.hide()
