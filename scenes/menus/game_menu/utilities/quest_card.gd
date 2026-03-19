# res://scenes/menus/game_menu/utilities/quest_card.gd
extends Control

@onready var panel = $Panel
@onready var name_label = $Panel/Button/Container/QuestTitle
@onready var status_label = $Panel/Button/Container/QuestStatus

var quest: Quest = null
signal pressed(quest: Quest)

func _ready():
	if quest:
		update_quest_display()
	
	# Hacer que el panel sea clickeable
	panel.gui_input.connect(_on_gui_input)
	panel.mouse_entered.connect(_on_mouse_entered)
	panel.mouse_exited.connect(_on_mouse_exited)

func update_quest_display():
	if quest:
		name_label.text = quest.name
		status_label.text = ":P" # quest.status

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(quest)

func _on_mouse_entered():
	panel.modulate = Color(0.9, 0.9, 0.9, 1.0)

func _on_mouse_exited():
	panel.modulate = Color(1, 1, 1, 1)
