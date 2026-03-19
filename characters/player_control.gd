class_name PlayerControl
extends Node2D

@export var inventory : Inventory

@export var general_interaction_area: Area2D

# It should be set by the Player when this controler is attached to a character
var attached = false

var is_enabled = false

# While the player's GeneralInteraction node is intersecting the
# GeneralInteractionArea node of an object or npc, that node is added to this
# array so that one can perform actions on the target. Only the first element
# will be interacted with, but more can be added in case there is an overlap.
var _target_interaction_areas: Array[GeneralInteractionArea]

func _unhandled_input(event):
	if event.is_action_released("rpg_interact") and is_enabled:
		if not _target_interaction_areas.is_empty():
			_target_interaction_areas[0].interaction(self)

# Avatar movement
func _process(_delta):
	if attached and is_enabled:
		var x = int(Input.is_action_pressed('rpg_right')) - int(Input.is_action_pressed('rpg_left'))
		var y = int(Input.is_action_pressed('rpg_down')) - int(Input.is_action_pressed('rpg_up'))
		
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
	if area.has_method('collect') and is_enabled:
		# Case where there is an empty space in the inventory
		if inventory.count_empty_slot() >= 1:
			area.collect(inventory)
		else: 
			# Case when the last stack has some available room
			if inventory.count_stacks():
				area.collect(inventory)


# Contact with the interaction area of a door
func _on_door_contact(area):
	if area.has_method('change_zone') and is_enabled:
		area.change_zone(get_parent().character)

# Enter the interaction area of an object or npc
func _on_interaction_area_enter(area):
	if area is GeneralInteractionArea and not _target_interaction_areas.has(area):
		_target_interaction_areas.push_front(area)
		
# Exit the interaction area of an object or npc
func _on_interaction_area_exit(area):
	if area is GeneralInteractionArea and _target_interaction_areas.has(area):
		_target_interaction_areas.erase(area)

# Enter the interaction area of an object with transparency
func _on_transparency_enter(area):
	if area is TransparencyControl and area.global_position.y > get_parent().global_position.y:
		area.enable_transparency()

# Exit the interaction area of an object with transparency
func _on_transparency_exit(area):
	if area is TransparencyControl:
		area.disable_transparency()
