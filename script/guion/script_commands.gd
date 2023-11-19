extends Node

# Each one of these functions will be associated with a script command, so that
# it is only necessary to add a new function here for the parser to recognize a
# new command.

@onready var dialog_contents: DialogContents = ScreenManager.dialog_screen.get_node("DialogContents")

# Changes the background image of a scene
func fondo(image_name: String):
	print("ScriptCommands | Changing scene background to " + image_name)
	dialog_contents.cambiar_fondo(image_name)

# Changes the images of one or more characters
func imagen(args: Array[String]):
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
	for name in args:
		_place(name, DialogContents.Position.RIGHT)

func centro(args: Array[String]):
	for name in args:
		_place(name, DialogContents.Position.CENTER)

func izquierda(args: Array[String]):
	for name in args:
		_place(name, DialogContents.Position.LEFT)

func quitar(args: Array[String]):
	for name in args:
		var character = CharacterManager.load(name)
		dialog_contents.remove_character(character)

func quitar_todos():
	dialog_contents.empty()

func _place(name: String, position: DialogContents.Position):
	var character = CharacterManager.load(name)
	if not character:
		error("ScriptCommands | Couldn't find a character with name " + name\
			+ " to change its position")
	else:
		dialog_contents.add_character(character, position)
		print("ScriptCommands | Placing " + name + " in " + str(position))

func dialogo(args: Array[String]):
	if args[0]:
		print("ScriptCommands | " + args[0] + ": " + args[1])
	else:
		print("ScriptCommands | " + args[1])
	dialog_contents.change_dialog(args[1], args[0])

# This instruction does nothing by itself, but it's used as a tag by units so
# they know to pause their execution and wait for user input when encountering it
func esperar():
	pass

# Opens the dialog screen. Reconsider if it should be a command or the system
# should know when to open the screen automatically
func abrir():
	print("ScriptCommands | Openning dialog screen")
	if ScreenManager.current_screen != ScreenManager.dialog_screen:
		await ScreenManager.push(ScreenManager.dialog_screen)

# Closes the dialog screen. Reconsider if it should be a command or the system
# should know when to close the screen automatically
func cerrar():
	print("ScriptCommands | Closing dialog screen")
	if ScreenManager.current_screen == ScreenManager.dialog_screen:
		await ScreenManager.pop(ScreenManager.dialog_screen)

func error(message: String):
	printerr(message)
