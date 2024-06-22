class_name PlayerControl
extends Node2D

@export var inventory : Inventory

@export var general_interaction_area: Area2D

# It should be set by the Player when this controler is attached to a character
var attached = false

# While the player's GeneralInteraction node is intersecting the
# GeneralInteractionArea node of an object or npc, this variable is set to that
# node so that one can perform actions on the target
var _target_interaction_area: GeneralInteractionArea

func _unhandled_input(event):
	if event.is_action_released("rpg_interact") and _target_interaction_area:
		_target_interaction_area.interaction(self)

# Avatar movement
func _process(_delta):
	if attached:
		var x = int(Input.is_action_pressed('rpg_right')) - int(Input.is_action_pressed('rpg_left'))
		var y = int(Input.is_action_pressed('rpg_down')) - int(Input.is_action_pressed('rpg_up'))
		
		Player.party_path.add_point(Player.character.rpg_model.position)
		
		# When moving in different directions we want to rotate the interaction area
		# so that it is always protruding towards the front of the character
		if y == -1: # Up
			general_interaction_area.rotation_degrees = 180
		if y == 1: # Down
			general_interaction_area.rotation_degrees = 0
		if x == -1: # Left
			general_interaction_area.rotation_degrees = 90
		if x == 1: # Right
			general_interaction_area.rotation_degrees = 270
		get_parent().set_axis(x, y)
	
# The collision with items on the ground
func _on_item_contact(area):
	# Collision with a ground item
	if area.has_method('collect'):
		# Case where there is an empty space in the inventory
		if inventory.count_empty_slot() >= 1:
			area.collect(inventory)
		else: 
			# Case when the last stack has some available room
			if inventory.count_stacks():
				area.collect(inventory)


# Contact with the interaction area of a door
func _on_door_contact(area):
	if area.has_method('change_zone'):
		area.change_zone(get_parent().character)

# Enter the interaction area of an object or npc
func _on_interaction_area_enter(area):
	if area is GeneralInteractionArea:
		_target_interaction_area = area
		
# Exit the interaction area of an object or npc
func _on_interaction_area_exit(area):
	if area is GeneralInteractionArea:
		_target_interaction_area = null

# Enter the interaction area of an object with transparency
func _on_transparency_enter(area):
	if area is TransparencyControl and area.global_position.y > get_parent().global_position.y:
		area.enable_transparency()

# Exit the interaction area of an object with transparency
func _on_transparency_exit(area):
	if area is TransparencyControl:
		area.disable_transparency()
