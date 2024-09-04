extends Control

@onready var char_card_scene : PackedScene = load("res://scenes/menus/game_menu/utilities/character_card.tscn")
@onready var chars_bar : GridContainer = $background/NinePatchRect/GridContainer
var selected_char : Character

var members_list = ['noby', 'maria_jose', 'carla', 'lucia', 'rebeca', 'guillermo', 'daniela']
func load_canditates():
	for i in members_list:
		var member = CharacterManager.load(i)
		if member != null:
			# Check if character already exists in chars_bar
			var exists = false
			for existing_card in chars_bar.get_children():
				if existing_card.char_name == member.name:
					exists = true
					break

			if not exists:
				var char_card_instance = char_card_scene.instantiate()
				var character_node = create_character_card(member, char_card_instance)
				chars_bar.add_child(character_node)
	update_party_display()

# Helper function to create a node for a character card
func create_character_card(char, char_card_instance):
	# Set the portrait, name, and description of the character in the character_card instance
	var portrait = char_card_instance.get_node("container/button/portrait")
	portrait.texture = char.char_info.portrait
	char_card_instance.portrait = char.char_info.portrait
	char_card_instance.char_name = char.char_info.name
	char_card_instance.description = char.char_info.description
	char_card_instance.character = char
	
	return char_card_instance

# Updates the party display
func update_party_display():
	for card in chars_bar.get_children():
		var character = card.character
		if Player.party.has(character): # Party members
			card.get_node("container/button").modulate = Color(5, 5, 5)
		if not(Player.party.has(character)): # No party members
			card.get_node("container/button").modulate = Color(1, 1, 1)
		if  Player.party.leader == character: # Party leader
			card.get_node("container/button").modulate = Color(1, 0, 0)

	# Disable buttons if no selection
	$background/HBoxContainer/ascend_btn.disabled = true
	$background/HBoxContainer/accept_btn.disabled = true
	$background/HBoxContainer/get_out_btn.disabled = true
	selected_char = null
	$background/char_portrait/portrait.texture = null
	$background/bar2/character_info.text = ""


# Party buttons
func _on_ascend_btn_pressed():
	if selected_char != null:
		Player.party.leader = selected_char
		Player.control(selected_char)
		update_party_display()

func _on_accept_btn_pressed():
	if selected_char != null:
		if len(Player.party.members) > 4:
			Player.party.remove(Player.party.members[-1])
		Player.party.add(selected_char, true)
		update_party_display()

func _on_get_out_btn_pressed():
	for member in Player.party.members:
		if selected_char != null and selected_char == member:
			if Player.party.leader != selected_char:
				Player.party.remove(selected_char)
				update_party_display()


# Menu buttons
func _on_contacts_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var contacts_menu = selected_menu.get_node('contacts_menu')
	contacts_menu.visible = true
	contacts_menu.load_characters()

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
