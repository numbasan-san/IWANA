extends Node

signal unpaused

# Because the scenes variable should only be modified from inside this script to
# avoid leaving it in the wrong state, a getter is provided that duplicates the
# dictionary when accessed from outside. When working with the variable from
# this same script, the _scenes variable should be used to avoid duplicating it
# unnecesarily.
var _scenes = {}
var scenes: Dictionary:
	get:
		return _scenes.duplicate()

var _scene_pointer: int = 0

var _current_scene: Escena
var current_scene: Escena:
	get: return _current_scene

var running: bool = false

func _process(_delta):
	if running:
		if _scene_pointer >= _scenes.size():
			running = false
		else:
			await _current_scene.run()
			if _current_scene.done:
				_scene_pointer += 1
				if _scene_pointer < _scenes.size():
					_current_scene = _scenes.values()[_scene_pointer]
					_current_scene.restart()

# Loads the first scene of the script and starts execution if it was paused
func restart():
	_activate(0)

# Loads a scene by name and starts execution if it was paused
func load(name: String):
	var index = _scenes.keys().find(name)
	if index == -1:
		printerr("ScriptManager | A scene with name " + name + "couldn't be found")
	_activate(index)

# Sets the scene with the given index as active, resets it's state and unpauses
# the manager if it wasn't running
func _activate(index: int):
	if not unpaused.is_connected(_on_unpaused):
		unpaused.connect(_on_unpaused)
	if 0 <= index and index < _scenes.size():
		_scene_pointer = index
		_current_scene = _scenes.values()[_scene_pointer]
		_current_scene.restart()
		running = true
	else:
		printerr("ScriptManager | Scene index out of bounds")

# Adds a new scene to the manager if it didn't have one with the same name
# This check is made so that if a different scene with the same name is added by
# accident later, it won't change the state of the manager
func add(scene: Escena):
	if not _scenes.keys().has(scene.name):
		_scenes[scene.name] = scene
	else:
		printerr("ScriptManager | A scene with name " + scene.name \
			+ " already exists")

# Deletes all teh stored scenes in the manager
func clear():
	# Verify if this causes all of the units and instructions to be deleted by
	# the garbage collector or one has to manually iterate over all the elements
	# and delete them
	_scenes.clear()
	_current_scene = null
	_scene_pointer = -1
	# The execution is stopped after deleting the scenes to avoid errors when
	# using null variables
	running = false

func _on_unpaused():
	if _scene_pointer < _scenes.size():
		_scenes.values()[_scene_pointer].pause(false)
	
