class_name DevModeCombatControl extends Control

var combat: CombatScreenControl

func _ready() -> void:
	combat = ScreenManager.combat_screen.contents as CombatScreenControl

func _add_character_left(character: Character):
	if combat.left_area:
		pass
