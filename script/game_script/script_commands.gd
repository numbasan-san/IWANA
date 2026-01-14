extends Node

# Each one of these functions will be associated with a script command, so that
# it is only necessary to add a new function here for the parser to recognize a
# new command.

@onready var dialog_contents: DialogContents = ScreenManager.dialog_screen.get_node("DialogContents")

# Changes the background image of a scene
func fondo(image_name: String):
	_open()
	print("ScriptCommands | Changing scene background to " + image_name)
	dialog_contents.change_background(image_name)

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
		print("ScriptCommands | Moving character " + name + " to the right")
		_place(name, DialogContents.Position.RIGHT)

func centro(args: Array[String]):
	_open()
	for name in args:
		print("ScriptCommands | Moving character " + name + " to the center")
		_place(name, DialogContents.Position.CENTER)

func izquierda(args: Array[String]):
	_open()
	for name in args:
		print("ScriptCommands | Moving character " + name + " to the left")
		_place(name, DialogContents.Position.LEFT)

func quitar(args: Array[String]):
	for name in args:
		var character = CharacterManager.load(name)
		if character:
			print("ScriptCommands | Removing character " + name)
			dialog_contents.remove_character(character)
		else:
			printerr("ScriptCommands | Couldn't remove character " + name \
				+ " because it doesn't exist")

func quitar_todos():
	print("ScriptCommands | Removing all characters")
	dialog_contents.empty()


func dialogo(args: Array[String]):
	_open()
	print("ScriptCommands | Dialog -> " + args[0] + ": " + args[1])
	dialog_contents.change_dialog(args[0], args[1])

# For now we only accept one argument, either the name of a song to play or an
# instruction to silence the audio
func audio(args: String):
	if ScreenManager.dialog_screen.audio:
		if args == "stop":
			print("ScriptCommands | Stopping audio")
			ScreenManager.dialog_screen.audio.stop()
		else:
			print("ScriptCommands | Playing track '" + args + "'")
			ScreenManager.dialog_screen.audio.play("1 sec", args)

# By default slowly fades out the previous screen and fades in the dialog screen.
# It is best used as the first instruction in a unit that will show backgrounds
# and characters, to give them time to be drawn before being shown.
func entrada(args: Array[String]):
	if args.size() == 0:
		_open("Out", "In")
	# For now, this only expects 0 arguments, or 1 with the name of an animation
	# to show the dialog. Consider expanding it with more arguments for more complex
	# behaviour
	else:
		_open("Out", args[0])

# By default slowly fades out the dialog screen and fades in the screen below that.
# It is best used as the last instruction in a unit to end a story bit
func salida(args: Array[String]):
	if args.size() == 0:
		await _close("Out", "In")
	# For now, this only expects 0 arguments, or 1 with the name of an animation
	# to hide the dialog. Consider expanding it with more arguments for more complex
	# behaviour
	else:
		await _close(args[0], "In")

func iniciar_rpg(args: Array[String]):
	if ScreenManager.current_screen != ScreenManager.rpg_screen:
		_close("Out", "Hide")
		await ScreenManager.push(ScreenManager.rpg_screen, "Hide", "In")

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
# "leaving" is the name of an animation to play to hide the screen before the dialog
# appears, while "entering" is the animation to show the dialog screen. The
# default values make it so that the dialog screen quickly slides up but doesn't
# hide the previous screen, to show the dialog as an overlay.
func _open(leaving: String = "Show", entering: String = "Slide Up"):
	
	if ScreenManager.current_screen != ScreenManager.dialog_screen:
		await ScreenManager.push(ScreenManager.dialog_screen, leaving, entering)
	
	
# If the last unit of the current link is completed, this function should be
# called to close the dialog screen and allow the game to progress. The default
# values assume that the dialog is showing as an overlay over another screen that
# is still visible, so this slides down the dialog without affecting the other one
func _close(leaving: String = "Slide Down", entering: String = "Show"):
	# We stop the ScriptManager before the transition and start it again after
	# to give time to the screen to appear
	ScriptManager.running = false
	if ScreenManager.current_screen == ScreenManager.dialog_screen:
		await ScreenManager.pop(ScreenManager.dialog_screen, leaving, entering)
		# We remove all characters and clear the background so that the next time
		# the dialog screen is open it starts in a clean state and we don't have to
		# write instructions to manually clean it at the beginning of each unit or
		# scene
		ScriptCommands.quitar_todos()
		ScriptCommands._remove_background()
	ScriptManager.running = true
	
# This functions is different to calling "fondo" with an empty string, as this
# one doesn't try to open the dialog screen. The fondo function assumes that one
# wants to change the background because it is going to be shown in a dialog,
# while this function is meant to be used in the _close function to remove the 
# background after closing the screen to leave it in a clean state for the next
# unit. Using the fondo function to clear the background after waiting for the
# screen to be closed will trigger it to open again, thus leaving one stuck in
# a loop
func _remove_background():
	dialog_contents.change_background("")
