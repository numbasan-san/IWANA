extends Node

# Each one of these functions will be associated with a script command, so that
# it is only necessary to add a new function here for the parser to recognize a
# new command.

@onready var dialog_contents: DialogContents = ScreenManager.dialog_screen.get_node("DialogContents")

# Changes the background image of a scene
func fondo(image_name: String):
	_open()
	print("ScriptCommands | Changing scene background to " + image_name)
	dialog_contents.cambiar_fondo(image_name)

# Changes the images of one or more characters
func imagen(args: Array[String]):
	_open()
	print("ScriptCommands | Changing character images:")
	for pair in args:
		var split = pair.split("->")
		var name = split[0].strip_edges()
		var character = CharacterManager.load(name)
		if not character:
			error("ScriptCommands | Can't find a character with name " + name)
			continue
		var image = split[1].strip_edges()
		print(name + " to " + image)
		dialog_contents.change_image(character, image)
	
func derecha(args: Array[String]):
	_open()
	for name in args:
		_place(name, DialogContents.Position.RIGHT)

func centro(args: Array[String]):
	_open()
	for name in args:
		_place(name, DialogContents.Position.CENTER)

func izquierda(args: Array[String]):
	_open()
	for name in args:
		_place(name, DialogContents.Position.LEFT)

func quitar(args: Array[String]):
	for name in args:
		var character = CharacterManager.load(name)
		dialog_contents.remove_character(character)

func quitar_todos():
	dialog_contents.empty()


func dialogo(args: Array[String]):
	_open()
	dialog_contents.change_dialog(args[1], args[0])


# This instruction does nothing by itself, but it's used as a tag by units so
# they know to pause their execution and wait for user input when encountering it
func esperar():
	pass


func error(message: String):
	printerr(message)


func _place(name: String, position: DialogContents.Position):
	var character = CharacterManager.load(name)
	if not character:
		error("ScriptCommands | Couldn't find a character with name " + name\
			+ " to change its position")
	else:
		dialog_contents.add_character(character, position)
		print("ScriptCommands | Placing " + name + " in " + str(position))

# Opens the dialog screen. This function should be called by some or all
# functions that make some change on the dialog screen, like showing dialog,
# placing characters or changing their image, because it's assumed that if there
# is some dialog instruction in a unit, it's cause one wants to show them on
# screen. Instructions that aren't related with the dialog screen shouldn't open
# it so that there can be units that modify some game state or the rpg mode
func _open():
	if ScreenManager.current_screen != ScreenManager.dialog_screen:
		await ScreenManager.push(ScreenManager.dialog_screen)

# If the last unit of the current link is completed, this function should be
# called to close the dialog screen and allow the game to progress.
func _close():
	if ScreenManager.current_screen == ScreenManager.dialog_screen:
		await ScreenManager.pop(ScreenManager.dialog_screen)
		# We remove all characters and clear the background so that the next time
		# the dialog screen is open it starts in a clean state and we don't have to
		# write instructions to manually clean it at the beginning of each unit or
		# scene
		ScriptCommands.quitar_todos()
		ScriptCommands._remove_background()

# This functions is different to calling "fondo" with an empty string, as this
# one doesn't try to open the dialog screen. The fondo function assumes that one
# wants to change the background because it is going to be shown in a dialog,
# while this function is meant to be used in the _close function to remove the 
# background after closing the screen to leave it in a clean state for the next
# unit. Using the fondo function to clear the background after waiting for the
# screen to be closed will trigger it to open again, thus leaving one stuck in
# a loop
func _remove_background():
	dialog_contents.cambiar_fondo("")
