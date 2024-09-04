extends Control

@onready var char_card_scene : PackedScene = load("res://scenes/menus/game_menu/utilities/character_card.tscn")
@onready var chars_bar : GridContainer = $background/NinePatchRect/GridContainer

# Called when the node enters the scene tree for the first time.
func load_characters():
	for char in ProcessedCharacters.get_processed_characters():
		if char != null:
			# Verificar si el personaje ya existe en chars_bar
			var exists = false
			for existing_card in chars_bar.get_children():
				if existing_card.char_name == char.name:
					exists = true
					break

			if not exists:
				var char_card_instance = char_card_scene.instantiate()
				var character_node = create_character_card(char, char_card_instance)
				chars_bar.add_child(character_node)


# Helper function to create a node for a character card
func create_character_card(resource, char_card_instance):
	# Set the portrait, name, and description of the character in the character_card instance
	var portrait = char_card_instance.get_node("container/button/portrait")
	portrait.texture = resource.portrait
	char_card_instance.portrait = resource.portrait
	char_card_instance.char_name = resource.name
	char_card_instance.description = resource.description
	
	return char_card_instance


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
