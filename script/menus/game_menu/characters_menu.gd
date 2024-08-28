extends Control

var processed_characters = []
@onready var char_card_scene : PackedScene = load("res://scenes/menus/game_menu/utilities/character_card.tscn")
@onready var chars_bar : GridContainer = $background/NinePatchRect/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_maps_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var maps_menu = selected_menu.get_node('maps_menu')
	maps_menu.visible = true
	maps_menu.load_maps()

	
	print('char_menu usado.')
	
	var char_card_instance = char_card_scene.instantiate()
	var character_node = create_character_card(char_card_instance)
	chars_bar.add_child(character_node)
#	if character != null and not is_character_already_processed(character):
#		print("Cargando personaje: ", character.name)
#		var char_card_instance = character_card_scene.instantiate()  # Create an instance of the character_card scene
#		var character_node = create_character_card(character, char_card_instance)
#		characters_bar.add_child(character_node)
#		processed_characters.append(character)  # Mark the character as processed
#	else:
#		print("Personaje ya procesado o nulo")


# Helper function to create a node for a character card
func create_character_card(char_card_instance):
	# Set the portrait, name, and description of the character in the character_card instance
	var portrait = char_card_instance.get_node("container/button/portrait")
	portrait.texture = load("res://assets/Assests de Pruebas/Sin título.jpg")
#	portrait.texture = character.texture  # Assuming the character has a texture property

#	char_card_instance.portrait = character.texture
	char_card_instance.char_name = 'character.name'
	char_card_instance.description = 'character.description'
	
	return char_card_instance

func is_character_already_processed(character):
	return character in processed_characters

func _on_items_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var items_menu = selected_menu.get_node('items_menu')
	items_menu.visible = true
	items_menu.load_items()

