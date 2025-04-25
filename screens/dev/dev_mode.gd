class_name DevMode extends Control

@export var tab_container: TabContainer
@export var dialog_mode: DevModeDialogControl
@export var rpg_mode: DevModeRPGControl
@export var combat_mode: DevModeCombatControl

func show_dev():
	var tab_index: int
	if ScreenManager.current_screen == ScreenManager.dialog_screen:
		tab_index = 0
	elif ScreenManager.current_screen == ScreenManager.rpg_screen:
		tab_index = 1
	elif ScreenManager.current_screen == ScreenManager.combat_screen:
		tab_index = 2
	tab_container.current_tab = tab_index
	_on_tab_container_tab_selected(tab_index)

func _on_tab_container_tab_selected(tab: int) -> void:
	match tab:
		0: dialog_mode.enable()
		1: rpg_mode.enable()
		2: combat_mode.enable()
