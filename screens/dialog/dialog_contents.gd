class_name DialogContents
extends Control

enum Position { LEFT, CENTER, RIGHT, NONE = -1 }

@export var background_folder: String
@export var prop_folder: String = "assets/dialog_drawings/props"

# --- Nodos existentes ---
@export var background: TextureRect
@export var left_area: Control
@export var center_area: Control
@export var right_area: Control

@export var name_label: Label
@export var text_label: RichTextLabel

# --- Nodos nuevos, usados por las instrucciones añadidas para implementar el
# sistema de escenas descrito en el vídeo (fundidos, cámara, escenario/filtros,
# objetos, paneo rápido, título) ---

# "Stage" envuelve el fondo, los filtros de escenario y el área de personajes.
# Es sobre este nodo que se aplican los efectos de cámara (zoom) y el temblor
# de pantalla, para que afecten a todo lo que se ve "dentro de la escena" sin
# mover el panel de diálogo ni el título.
@export var stage: Control

# Contiene elementos preparados de antemano (filtros de color, etc.) que se
# muestran/ocultan por nombre, como el filtro azul de "noche" del vídeo.
@export var overlay_layer: Control

# Contiene los objetos (props) que se muestran encima de la escena para dar
# detalle a una acción, como la imagen del batido del vídeo.
@export var prop_layer: Control

# Rectángulo negro (u otro color) que cubre toda la pantalla, usado para los
# fundidos y para el "corte" rápido del paneo (fastp).
@export var curtain: ColorRect

@export var title_card: Control
@export var title_label: Label

# --- Estado interno de cámara ---
var _camera_duration: float = 1.5
var _camera_tween: Tween

func _ready():
	if curtain:
		curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		curtain.color = Color.BLACK
		curtain.modulate.a = 0.0
	if title_card:
		title_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title_card.modulate.a = 0.0
	if text_label:
		text_label.bbcode_enabled = true

# ---------------------------------------------------------------------------
# Personajes
# ---------------------------------------------------------------------------

# Adds the grafic associated with a character to the left, center or right of
# the character area
# If the character had already been added to that side, it does nothing
# If the character had already been added to a different side, it switches sides
func add_character(character: Character, pos: Position):
	var model: DialogModel = character.dialog_model
	
	# If the character doesn't have a dialog model, generally because it isn't
	# designed to appear in dialogs, or it's already in that position, nothing
	# is done
	if not model or model.dialog_position == pos:
		return
	
	# If we reach this point, we have to remove the model from an area. After
	# calling this function the model will be outside of the screen and attached
	# to its character
	remove_character(character)
	character.remove_child(model)
	# TODO: add code to handle animated transitions
	var target_area = Control
	var target_position: Position
	match pos:
		Position.LEFT:
			target_area = left_area
			target_position = Position.LEFT
			model.look_right()
		Position.CENTER:
			target_area = center_area
			target_position = Position.CENTER
			model.look_right()
		Position.RIGHT:
			target_area = right_area
			target_position = Position.RIGHT
			model.look_left()
	
	target_area.add_child(model)
	model.dialog_position = target_position
	model.show()
	_reorder(target_area)

# Removes the model associated with the character if it already is in the
# character area. If reorder is true the remaining characters are moved so that
# they are evenly spread. It can be left as false if one desires to reordem
# later, for example if one wants to remove several before reordering
func remove_character(character: Character, reorder: bool = true):
	var model: DialogModel = character.dialog_model
	if not model or model.dialog_position == Position.NONE:
		return
	var area: Control
	match model.dialog_position:
		Position.LEFT:
			area = left_area
		Position.CENTER:
			area = center_area
		Position.RIGHT:
			area = right_area
	model.hide()
	model.get_parent().remove_child(model)
	if reorder:
		_reorder(area)
	character.add_child(model)
	model.dialog_position = Position.NONE

# Removes all character models present in an area
func empty_area(area: Control):
	for model in area.get_children():
		if model is DialogModel:
			remove_character(model.character, false)
	_reorder(area)

# Removes all characters in the dialog screen
func empty():
	empty_area(left_area)
	empty_area(center_area)
	empty_area(right_area)

# Places a character in a position without going through remove/add, keeping it
# "attached" instantly, and forces it to be visible. It's used by the
# "Cara instantanea" command, for characters that must appear immediately (for
# example, teleported off-screen just before sliding in, or shown at the start
# of a unit without any transition).
func place_instantly(character: Character, pos: Position):
	add_character(character, pos)
	if character.dialog_model:
		character.dialog_model.visible = true

# Makes a character's model invisible without removing it from the scene. The
# character is still "present" (it can keep speaking, its area slot is still
# reserved) but nothing is drawn, exactly like Victoria in the video before the
# light switches on.
func set_character_visible(character: Character, value: bool):
	var model: DialogModel = character.dialog_model
	if not model or model.dialog_position == Position.NONE:
		printerr("DialogContents | Can't change the visibility of " \
			+ character.char_name + " because it isn't present in the scene")
		return
	model.visible = value

# Teleports a character's model off-screen to the given side (LEFT or RIGHT),
# leaving it ready to be slid into place with move_character(). This is the
# "moves out far left/right" step from the video.
func place_offscreen(character: Character, pos: Position):
	add_character(character, pos)
	var model: DialogModel = character.dialog_model
	if not model:
		return
	model._animating_in = true
	var area = _area_for(pos)
	if pos == Position.RIGHT:
		model.position.x = area.size.x + 400
	else:
		model.position.x = -400

# Smoothly slides a character's model from wherever it currently is to its
# proper spot in its area (the one computed the last time the area was
# reordered). Waits for the movement to finish before returning, matching the
# blocking-by-default behaviour described for the dialog system.
func move_character(character: Character, duration: float = 0.6):
	var model: DialogModel = character.dialog_model
	if not model:
		return
	var tween = create_tween()
	tween.tween_property(model, "position", model.target_offset, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	model._animating_in = false

# Changes the image being shown for a given character. The image must be
# associated with a Sprite2D node in the dialog model
func change_image(character: Character, target_image: String):
	character.dialog_model.change_image(target_image)

# Changes the position of the characters in an area depending on how many there
# are. Characters must have been added or removed before calling this function
# or else it won't have any effect
func _reorder(area: Control):
	# We are going to show the characters centered in this area, leaving the
	# left and right edges free
	var segments = area.get_child_count() + 2
	var i = 1
	while i < segments - 1:
		var vector = Vector2(i * area.size.x / segments, area.size.y)
		var child = area.get_child(i - 1)
		child.target_offset = vector
		# If the character is being animated in from off-screen, we don't snap
		# it to its final position; move_character() will tween it there.
		if not child._animating_in:
			child.position = vector
		i += 1

func _area_for(pos: Position) -> Control:
	match pos:
		Position.LEFT: return left_area
		Position.CENTER: return center_area
		Position.RIGHT: return right_area
	return center_area

# ---------------------------------------------------------------------------
# Fondo y escenario (filtros de escenario, tipo el filtro de "noche")
# ---------------------------------------------------------------------------

# Changes the background image of the dialog screen. If empty, it removes the
# background to see through to the screen below. If the image doesn't exist, an
# error is thrown and nothing is changed
func change_background(image_name: String):
	if not image_name:
		background.hide()
		return
	
	# If the image name doesn't have an extension, we assume .png
	if not image_name.get_extension():
		image_name = image_name + ".png"
	var texture = load("res://".path_join(background_folder).path_join(image_name))
	if not texture:
		printerr("DialogContents | Couldn't find an image with name "\
			+ image_name.get_basename().get_file())
		return
	background.texture = texture
	background.show()

# Shows a pre-made overlay node (a filter over the background, like a blue tint
# to fake nighttime) by name. The node must already exist as a child of
# overlay_layer, named after the overlay (in PascalCase), the same convention
# used by character images.
func show_overlay(overlay_name: String):
	var node = overlay_layer.get_node_or_null(overlay_name.to_pascal_case())
	if node:
		node.show()
	else:
		printerr("DialogContents | Couldn't find an overlay with name " + overlay_name)

func hide_overlay(overlay_name: String):
	var node = overlay_layer.get_node_or_null(overlay_name.to_pascal_case())
	if node:
		node.hide()
	else:
		printerr("DialogContents | Couldn't find an overlay with name " + overlay_name)

# ---------------------------------------------------------------------------
# Objetos (props)
# ---------------------------------------------------------------------------

# Shows a prop image over the scene. If a node with that name already exists
# under prop_layer it's simply shown; otherwise we try to load an image with
# that name from prop_folder and create a TextureRect for it on the fly.
func show_prop(prop_name: String):
	var node_name = prop_name.to_pascal_case()
	var node = prop_layer.get_node_or_null(node_name)
	if not node:
		var file_name = prop_name
		if not file_name.get_extension():
			file_name = file_name + ".png"
		var texture = load("res://".path_join(prop_folder).path_join(file_name))
		if not texture:
			printerr("DialogContents | Couldn't find a prop with name " + prop_name)
			return
		var rect = TextureRect.new()
		rect.name = node_name
		rect.texture = texture
		rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		prop_layer.add_child(rect)
		node = rect
	node.show()

func hide_prop(prop_name: String):
	var node = prop_layer.get_node_or_null(prop_name.to_pascal_case())
	if node:
		node.hide()
	else:
		printerr("DialogContents | Couldn't find a prop with name " + prop_name)

# ---------------------------------------------------------------------------
# Fundidos y cortes rápidos (paneo)
# ---------------------------------------------------------------------------

# Covers the screen with "color" and slowly reveals what's behind, over
# "duration" seconds. Used as the opening beat of a unit, once the background
# and characters that should be visible after the fade have already been set up.
func fade_in(color: Color = Color.BLACK, duration: float = 1.5):
	if not curtain:
		return
	curtain.color = color
	curtain.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(curtain, "modulate:a", 0.0, duration)
	await tween.finished

# Quickly covers the screen and quickly reveals it again. Used internally by
# fast_pan() to fake a camera cut, and can also be used on its own for a
# regular fade to black/back.
func fade_out(color: Color = Color.BLACK, duration: float = 1.5):
	if not curtain:
		return
	curtain.color = color
	var tween = create_tween()
	tween.tween_property(curtain, "modulate:a", 1.0, duration)
	await tween.finished

# Implements the "fast pan" (paneo rápido / fastp) trick described in the
# video: the camera doesn't actually move, instead we do a very quick cut,
# during which we swap which character is shown at "side" (from "leaving" to
# "entering") and, optionally, change the background, to sell the illusion of
# a fast pan towards a new subject.
func fast_pan(side: Position, leaving: Character, entering: Character, new_background: String = ""):
	await fade_out(Color.BLACK, 0.12)
	if leaving:
		remove_character(leaving)
	if entering:
		add_character(entering, side)
	if new_background:
		change_background(new_background)
	await fade_in(Color.BLACK, 0.12)

# ---------------------------------------------------------------------------
# Cámara (zoom, velocidad, temblor de pantalla)
# ---------------------------------------------------------------------------

# Sets how long (in seconds) the next camera zoom/reset movements will take.
func camera_set_speed(seconds: float):
	_camera_duration = seconds

# Zooms the camera towards a character's model. If async is true, the movement
# is fired without waiting for it to finish, so following instructions keep
# running in parallel (useful to move the character's eyes while the camera is
# still zooming in, like in the video). If async is false (the default) this
# function blocks until the zoom finishes.
func camera_zoom(character: Character, zoom_amount: float = 1.6, async: bool = false):
	if not stage or not character or not character.dialog_model:
		return
	var target_local: Vector2 = stage.get_global_transform().affine_inverse() \
		* character.dialog_model.global_position
	stage.pivot_offset = target_local
	if _camera_tween and _camera_tween.is_valid():
		_camera_tween.kill()
	_camera_tween = create_tween()
	_camera_tween.tween_property(stage, "scale", Vector2(zoom_amount, zoom_amount), _camera_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if not async:
		await _camera_tween.finished

# Undoes the current zoom, returning the camera to its default framing.
func camera_reset(async: bool = false):
	if not stage:
		return
	if _camera_tween and _camera_tween.is_valid():
		_camera_tween.kill()
	_camera_tween = create_tween()
	_camera_tween.tween_property(stage, "scale", Vector2.ONE, _camera_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_camera_tween.parallel().tween_property(stage, "pivot_offset", stage.size / 2, _camera_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if not async:
		await _camera_tween.finished

# Synchronization point for an asynchronous camera movement: if there is a
# camera tween still running (started with async = true), this waits for it to
# finish. This is the equivalent of the "async Camera stop" line from the video.
func camera_wait():
	if _camera_tween and _camera_tween.is_valid() and _camera_tween.is_running():
		await _camera_tween.finished

# Shakes the whole scene (background, overlays and characters) for "duration"
# seconds, with the given "intensity" in pixels.
func screen_shake(duration: float = 0.5, intensity: float = 6.0):
	if not stage:
		return
	var base_position = stage.position
	var tween = create_tween()
	var steps = max(int(duration / 0.05), 1)
	for i in range(steps):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity))
		tween.tween_property(stage, "position", base_position + offset, 0.05)
	tween.tween_property(stage, "position", base_position, 0.05)
	await tween.finished

# ---------------------------------------------------------------------------
# Título
# ---------------------------------------------------------------------------

func show_title(text: String):
	if not title_card or not title_label:
		return
	title_label.text = text
	title_card.modulate.a = 0.0
	title_card.show()
	var tween = create_tween()
	tween.tween_property(title_card, "modulate:a", 1.0, 0.6)
	await tween.finished

func hide_title():
	if not title_card:
		return
	var tween = create_tween()
	tween.tween_property(title_card, "modulate:a", 0.0, 0.6)
	await tween.finished
	title_card.hide()

# ---------------------------------------------------------------------------
# Diálogo y etiquetas de texto
# ---------------------------------------------------------------------------

# Changes the lines of dialogo on screen and / or who says them.
# The text can contain a couple of light-weight tags that get translated to
# Godot's built-in BBCode RichTextLabel effects:
#   <tiembla>...</tiembla>  -> letters shake      (equivalent to [shake])
#   <ola>...</ola>          -> letters wave        (equivalent to [wave])
# It can also contain the marker <golpe/>, which splits the line in two and
# triggers a screen shake exactly at that point while it's being read, the
# same way the video allows writing "hit" in the middle of a line of dialog.
func change_dialog(who: String, what: String):
	name_label.text = who
	
	var pieces = what.split("<golpe/>")
	var first = true
	for piece in pieces:
		if not first:
			await screen_shake(0.4, 5.0)
		text_label.text = _translate_tags(piece)
		first = false

func _translate_tags(text: String) -> String:
	return text \
		.replace("<tiembla>", "[shake rate=20.0 level=6]") \
		.replace("</tiembla>", "[/shake]") \
		.replace("<ola>", "[wave amp=40.0 freq=5.0]") \
		.replace("</ola>", "[/wave]")
