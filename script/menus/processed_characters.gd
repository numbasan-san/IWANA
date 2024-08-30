extends Node

var processed_characters = []

func append_char(character):
	if not(character in processed_characters):
		processed_characters.append(character)
	for i in processed_characters:
		print(i.name)
		print(i)
		print('---------------------------------')

func get_processed_characters():
	return processed_characters
