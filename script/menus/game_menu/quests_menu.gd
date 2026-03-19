# res://script/menus/game_menu/quests_menu.gd
extends Control

@onready var quest_card_scene : PackedScene = preload("res://scenes/menus/game_menu/utilities/quest_card.tscn")
@onready var quest_bar : GridContainer = $background/bar/margin/Background/Scroll/Grid
@onready var quest_details_panel = $background/quests_details
@onready var quest_title = $background/quests_details/VBoxContainer/HBoxContainer/title
@onready var quest_status = $background/quests_details/VBoxContainer/HBoxContainer/Label
@onready var quest_description = $background/quests_details/VBoxContainer/quests_description
@onready var brief_description = $background/quests_details/VBoxContainer/brief_description

func load_quests():
	
	print("MENÚ DE MISIONES ACTIVADO")

	QuestsManager.quest_changed.connect(load_quests)

	# Limpiar las tarjetas existentes
	for child in quest_bar.get_children():
		child.queue_free()

	# Crear nuevas tarjetas para cada misión activa
	for quest in QuestsManager.active_quests:
		var quest_card = quest_card_scene.instantiate()
		quest_card.quest = quest
		# Conectar la señal de pressed para seleccionar la misión
		quest_card.get_node("Panel/Button").pressed.connect(_on_quest_card_pressed.bind(quest))
		quest_bar.add_child(quest_card)

	clear()

func _on_quest_card_pressed(quest: Quest):
	update_quest_details(quest)

func update_quest_details(current_selected_quest):
	if current_selected_quest:
		quest_title.text = current_selected_quest.name
		quest_status.text = ":P" # current_selected_quest.status
		brief_description.text = current_selected_quest.get_brief_description()
		quest_description.text = current_selected_quest.description
		# quest_details_panel.show()

func clear():
	quest_title.text = ""
	quest_status.text = ""
	quest_description.text = ""
	brief_description.text = ""
	# quest_details_panel.show()

func _on_maps_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var maps_menu = selected_menu.get_node('maps_menu')
	maps_menu.visible = true
	maps_menu.load_maps()

func _on_items_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var items_menu = selected_menu.get_node('items_menu')
	items_menu.visible = true
	items_menu.load_items()

func _on_characters_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('characters_menu')
	characters_menu.visible = true
	characters_menu.load_canditates()
