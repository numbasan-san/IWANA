extends Node

# Each one of these functions will be associated with a script command, so that
# it is only necessary to add a new function here for the parser to recognize a
# new command.

@onready var dialog_contents: DialogContents = ScreenManager.dialog_screen.get_node("DialogContents")

# ---------------------------------------------------------------------------
# Fondo / escenario
# ---------------------------------------------------------------------------

# Changes the background image of a scene
func fondo(image_name: String):
	_open()
	print("ScriptCommands | Changing scene background to " + image_name)
	dialog_contents.change_background(image_name)

# Shows a pre-made overlay/filter over the background, by name (for example, a
# blue tint used to fake nighttime, the "night" element from the video).
# Uso: [Escenario mostrar: noche]
func escenario_mostrar(nombre: String):
	print("ScriptCommands | Showing scenario overlay " + nombre)
	dialog_contents.show_overlay(nombre)

# Uso: [Escenario ocultar: noche]
func escenario_ocultar(nombre: String):
	print("ScriptCommands | Hiding scenario overlay " + nombre)
	dialog_contents.hide_overlay(nombre)

# ---------------------------------------------------------------------------
# Fundido (fade)
# ---------------------------------------------------------------------------

# Fades in from a color (black by default) over a duration (1.5 seconds by
# default), revealing whatever background/characters were already prepared
# behind it. It's meant to be used as the very first instruction of a unit that
# is going to show a background and characters, so they have time to be set up
# before being revealed, exactly like in the video.
# Uso: [Fundido]
#      [Fundido: negro]
#      [Fundido: negro, 2]
func fundido(args: Array[String]):
	_open()
	var color = Color.BLACK
	var duration = 1.5
	if args.size() >= 1 and args[0] != "":
		color = _color_from_name(args[0])
	if args.size() >= 2 and args[1] != "":
		duration = float(args[1])
	print("ScriptCommands | Fundido color=" + str(color) + " duracion=" + str(duration))
	await dialog_contents.fade_in(color, duration)

func _color_from_name(name: String) -> Color:
	match name.to_lower():
		"negro", "black": return Color.BLACK
		"blanco", "white": return Color.WHITE
		"rojo", "red": return Color.RED
		"azul", "blue": return Color.BLUE
		_: return Color.BLACK

# ---------------------------------------------------------------------------
# Personajes
# ---------------------------------------------------------------------------

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

# Places a character instantly (without any transition) and makes sure it's
# visible. Useful for characters that must "pop" into the scene right away.
# Uso: [Cara instantanea: Victoria, derecha]
func cara_instantanea(args: Array[String]):
	_open()
	if args.size() < 2:
		error("ScriptCommands | 'Cara instantanea' necesita [nombre, posicion]")
		return
	var character = CharacterManager.load(args[0])
	if not character:
		error("ScriptCommands | Can't find a character with name " + args[0])
		return
	var pos = _position_from_name(args[1])
	print("ScriptCommands | Placing " + args[0] + " instantly at " + args[1])
	dialog_contents.place_instantly(character, pos)

# Makes an already-present character invisible without removing it from the
# scene, so it can keep speaking off-screen (like Victoria hiding in the dark).
# Uso: [Cara invisible: Victoria]
func cara_invisible(nombre: String):
	var character = CharacterManager.load(nombre)
	if not character:
		error("ScriptCommands | Can't find a character with name " + nombre)
		return
	print("ScriptCommands | Making " + nombre + " invisible")
	dialog_contents.set_character_visible(character, false)

# Uso: [Cara visible: Victoria]
func cara_visible(nombre: String):
	var character = CharacterManager.load(nombre)
	if not character:
		error("ScriptCommands | Can't find a character with name " + nombre)
		return
	print("ScriptCommands | Making " + nombre + " visible")
	dialog_contents.set_character_visible(character, true)

# Teleports a character off-screen to the given side, ready to be slid into
# view with "Cara mover". Equivalent to "moves out far left/right" in the video.
# Uso: [Cara fuera: Victoria, izquierda]
func cara_fuera(args: Array[String]):
	_open()
	if args.size() < 2:
		error("ScriptCommands | 'Cara fuera' necesita [nombre, lado]")
		return
	var character = CharacterManager.load(args[0])
	if not character:
		error("ScriptCommands | Can't find a character with name " + args[0])
		return
	var pos = _position_from_name(args[1])
	print("ScriptCommands | Placing " + args[0] + " off-screen to the " + args[1])
	dialog_contents.place_offscreen(character, pos)

# Slides a character from its current position (usually off-screen, after
# "Cara fuera") to its proper spot. Blocks until the movement finishes.
# Uso: [Cara mover: Victoria]
func cara_mover(nombre: String):
	var character = CharacterManager.load(nombre)
	if not character:
		error("ScriptCommands | Can't find a character with name " + nombre)
		return
	print("ScriptCommands | Moving " + nombre + " into place")
	await dialog_contents.move_character(character)

func dialogo(args: Array[String]):
	_open()
	print("ScriptCommands | Dialog -> " + args[0] + ": " + args[1])
	await dialog_contents.change_dialog(args[0], args[1])

# ---------------------------------------------------------------------------
# Cámara
# ---------------------------------------------------------------------------

# Sets the duration (in seconds) of the next camera movements.
# Uso: [Camara velocidad: 2]
func camara_velocidad(segundos: String):
	print("ScriptCommands | Camera speed set to " + segundos + " seconds")
	dialog_contents.camera_set_speed(float(segundos))

# Resets the camera speed to a fast default value, useful to quickly undo a
# zoom, as shown in the video.
# Uso: [Camara velocidad por defecto]
func camara_velocidad_por_defecto():
	print("ScriptCommands | Camera speed reset to default")
	dialog_contents.camera_set_speed(0.4)

# Zooms the camera towards a character. Add "asincrono" as a second argument to
# fire the movement without waiting for it, so the following instructions
# (for example, changing the character's eyes) run while the camera is still
# moving.
# Uso: [Camara zoom: Sierra]
#      [Camara zoom: Sierra, asincrono]
func camara_zoom(args: Array[String]):
	if args.size() < 1:
		error("ScriptCommands | 'Camara zoom' necesita el nombre de un personaje")
		return
	var character = CharacterManager.load(args[0])
	if not character:
		error("ScriptCommands | Can't find a character with name " + args[0])
		return
	var async = args.size() > 1 and args[1].to_lower() == "asincrono"
	print("ScriptCommands | Camera zooming to " + args[0] + (" (async)" if async else ""))
	await dialog_contents.camera_zoom(character, 1.6, async)

# Uso: [Camara reiniciar]
#      [Camara reiniciar: asincrono]
func camara_reiniciar(args: Array[String] = []):
	var async = args.size() > 0 and args[0].to_lower() == "asincrono"
	print("ScriptCommands | Camera reset" + (" (async)" if async else ""))
	await dialog_contents.camera_reset(async)

# Synchronization point for an asynchronous camera movement, equivalent to the
# "async Camera stop" line in the video: waits until the last asynchronous
# camera movement (zoom or reset) finishes before continuing.
# Uso: [Camara esperar]
func camara_esperar():
	print("ScriptCommands | Waiting for the camera to finish moving")
	await dialog_contents.camera_wait()

# ---------------------------------------------------------------------------
# Paneo rápido (fastp) y pantalla
# ---------------------------------------------------------------------------

# Fakes a fast camera pan towards a new subject: a very quick cut during which
# the character shown at "lado" is swapped and, optionally, the background is
# changed.
# Uso: [Paneo: izquierda, Sierra, Victoria]
#      [Paneo: izquierda, Sierra, Victoria, entrada casa]
func paneo(args: Array[String]):
	if args.size() < 3:
		error("ScriptCommands | 'Paneo' necesita [lado, personaje_que_sale, personaje_que_entra, (fondo_nuevo)]")
		return
	var pos = _position_from_name(args[0])
	var leaving = CharacterManager.load(args[1])
	var entering = CharacterManager.load(args[2])
	var new_background = args[3] if args.size() > 3 else ""
	print("ScriptCommands | Fast pan " + args[0] + ": " + args[1] + " -> " + args[2])
	await dialog_contents.fast_pan(pos, leaving, entering, new_background)

# Shakes the screen. Useful either as its own instruction between dialog lines,
# or automatically triggered from the middle of a line of dialog by writing the
# <golpe/> marker inside the text (see DialogContents.change_dialog).
# Uso: [Pantalla sacudir]
#      [Pantalla sacudir: 0.5, 8]
func pantalla_sacudir(args: Array[String] = []):
	var duration = 0.5
	var intensity = 6.0
	if args.size() >= 1 and args[0] != "":
		duration = float(args[0])
	if args.size() >= 2 and args[1] != "":
		intensity = float(args[1])
	print("ScriptCommands | Screen shake duration=" + str(duration) + " intensity=" + str(intensity))
	await dialog_contents.screen_shake(duration, intensity)

# ---------------------------------------------------------------------------
# Objetos (props)
# ---------------------------------------------------------------------------

# Uso: [Objeto mostrar: ejemplo]
func objeto_mostrar(nombre: String):
	print("ScriptCommands | Showing prop " + nombre)
	dialog_contents.show_prop(nombre)

# Uso: [Objeto ocultar: ejemplo]
func objeto_ocultar(nombre: String):
	print("ScriptCommands | Hiding prop " + nombre)
	dialog_contents.hide_prop(nombre)

# ---------------------------------------------------------------------------
# Título
# ---------------------------------------------------------------------------

# Shows a title card, like the "Fin" chapter screen from the video. The
# "sin numero" argument is kept for when the game adds chapter numbering; for
# now it's just accepted and ignored so scripts already using it don't error.
# Uso: [Titulo mostrar: Fin]
#      [Titulo mostrar: Fin, sin numero]
func titulo_mostrar(args: Array[String]):
	if args.size() < 1:
		error("ScriptCommands | 'Titulo mostrar' necesita un texto")
		return
	print("ScriptCommands | Showing title '" + args[0] + "'")
	await dialog_contents.show_title(args[0])

# Uso: [Titulo ocultar]
func titulo_ocultar():
	print("ScriptCommands | Hiding title")
	await dialog_contents.hide_title()

# ---------------------------------------------------------------------------
# Audio
# ---------------------------------------------------------------------------

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

# Plays a one-shot sound effect (as opposed to "audio", which is for music).
# The name must match one of the SFXResource entries registered in the dialog
# screen's SFX player.
# Uso: [Audio efecto: cajon]
func audio_efecto(nombre: String):
	if ScreenManager.dialog_screen.sfx:
		print("ScriptCommands | Playing sound effect '" + nombre + "'")
		ScreenManager.dialog_screen.sfx.play(nombre)
	else:
		error("ScriptCommands | The dialog screen doesn't have an SFX player configured")

# ---------------------------------------------------------------------------
# Espera
# ---------------------------------------------------------------------------

# This instruction does nothing by itself, but it's used as a tag by units so
# they know to pause their execution and wait for user input when encountering it
func esperar():
	pass

# Unlike "esperar" (which waits for the player to press a button), this waits a
# fixed amount of time before letting the unit continue, without needing any
# input. Useful for timing an action to a sound effect, like the drawer sound
# in the video.
# Uso: [Esperar segundos: 2]
func esperar_segundos(segundos: String):
	print("ScriptCommands | Waiting " + segundos + " seconds")
	await ScreenManager.dialog_screen.get_tree().create_timer(float(segundos)).timeout


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

func mision(args: Array[String]):
	_open()
	if args.size() < 1:
		error("ScriptCommands | El comando 'mision' requiere al menos un argumento")
		return
	var quest_id = args[0]
	print("ScriptCommands | Activando misión: " + quest_id)

	# Buscar el recurso de la misión
	var quest_path = "res://script/quests/resources/" + quest_id + ".tres"
	var quest = load(quest_path)

	if quest:
		QuestsManager.add_quest(quest)
		print("ScriptCommands | Misión activada: ", quest.name if quest.has_method("get_quest_name") else quest_id)
	else:
		error("ScriptCommands | No se encontró la misión: " + quest_id + " en " + quest_path)

# Completa una misión activa
# Uso en diálogo: [CompletarMision: nombre_de_la_mision]
# Ejemplo: [CompletarMision: recolectar_manzanas]
func completar_mision(args: Array[String]):
	_open()
	if args.size() < 1:
		error("ScriptCommands | El comando 'completar_mision' requiere al menos un argumento")
		return
	
	var quest_id = args[0]
	print("ScriptCommands | Completando misión: " + quest_id)
	
	# Buscar la misión en las misiones activas
	var quest = QuestsManager.get_active_quest_by_id(quest_id)
	
	if quest:
		QuestsManager.complete_quest(quest)
		print("ScriptCommands | Misión completada: ", quest.name if quest.has_method("get_quest_name") else quest_id)
	else:
		error("ScriptCommands | No se encontró la misión activa: " + quest_id)


# Avanza el progreso de una misión (para misiones de recolección, etc.)
# Uso en diálogo: [ProgresoMision: nombre_de_la_mision, cantidad]
# Ejemplo: [ProgresoMision: recolectar_manzanas, 3]
func progreso_mision(args: Array[String]):
	_open()
	if args.size() < 2:
		error("ScriptCommands | El comando 'progreso_mision' requiere 2 argumentos: [nombre_mision, cantidad]")
		return
	
	var quest_id = args[0]
	var amount = int(args[1])
	
	print("ScriptCommands | Añadiendo " + str(amount) + " de progreso a misión: " + quest_id)
	
	var quest = QuestsManager.get_active_quest_by_id(quest_id)
	if quest:
		QuestsManager.update_quest_progress(quest_id, amount)
		print("ScriptCommands | Progreso actualizado")
	else:
		error("ScriptCommands | No se encontró la misión activa: " + quest_id)


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

func _position_from_name(name: String) -> DialogContents.Position:
	match name.strip_edges().to_lower():
		"izquierda", "left": return DialogContents.Position.LEFT
		"derecha", "right": return DialogContents.Position.RIGHT
		"centro", "center": return DialogContents.Position.CENTER
		_:
			error("ScriptCommands | Posición desconocida: " + name + ". Usando 'centro' por defecto")
			return DialogContents.Position.CENTER

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
