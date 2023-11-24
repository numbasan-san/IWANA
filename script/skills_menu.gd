class_name SkillsMenu extends Control

@export var character_slot: CharacterCombatContainer

func set_to_character(character: Character = null):
	character_slot.set_to_character(character)
