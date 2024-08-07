extends Node

# A dictionary with the names of the functions in the ScriptCommands script and
# the types of their arguments, to make it easier to call them and verify the
# commands found by the parser are well written
var _commands: Dictionary = {}

# The folder where the scripts are going to be searched when running the game
var _script_folder: String

# The folder that will contain the scripts when running from the editor
var _editor_script_folder = "res://game_script/"

# Extracts the units from a scene. For the parser to work all the instructions
# must be defined inside an unit, and each unit must have an openning label
# [Unidad: name] and a closing one [Fin: name] or [Fin: Unidad]
# Each unit must belong to a scene.
var _unit_matcher = RegEx.new()
var _unit_regex = "\\s*\\[(?:U|u)nidad:(?: |\\t)*(?<name>.+)\\]\\n(?<contents>(?:.*\\n)*?)\\[Fin:(?: |\\t)*(?:\\k<name>|(?:U|u)nidad)\\]"

# Splits the script into scenes. Each scene must have an openning label
# [Escena: name] and a closing one [Fin: name] or [Fin: Escena]
var _scene_matcher = RegEx.new()
var _scene_regex = "\\s*\\[(?:E|e)scena:(?: |\\t)*(?<name>.+)\\]\\n(?<contents>(?:.*\\n)*?)\\[Fin:(?: |\\t)*(?:\\k<name>|(?:E|e)scena)\\]"

# Extracts the first unit that must be run when loading the scene
var _initial_matcher = RegEx.new()
var _initial_regex = "\\s*\\[(?:I|i)nicial:(?: |\\t)*(?<name>(?:.*)*?)\\]"

# Extracts the last unit that must be run when loading the scene
var _final_matcher = RegEx.new()
var _final_regex = "\\s*\\[(?:F|f)inal:(?: |\\t)*(?<name>(?:.*)*?)\\]"

# Extracts the lists of links between units
var _links_matcher = RegEx.new()
var _links_regex = "\\s*\\[(?:E|e)nlace:(?: |\\t)*(?<contents>(?:.*)*?)\\]"

# Assigns units to npc to speak
# TODO: There are too many regexes here. See if the system can be changed so
# that everything goes through the commands, in which case this should be
# changed by a recursive system that can allow certain commands only in units
# or in scenes, or if this should be changed by some kind of composite parser
# and do everything through regexes
var _asign_matcher = RegEx.new()
var _asign_regex = "\\s*\\[(?:A|a)signar:(?: |\\t)*(?<contents>(?:.*)*?)\\]"

# For now we're assuming that the entire script is going to be read from a
# single file. Although several files can be read and loaded, when parsing the
# links and creating them in the ScriptManager, it will first check if the given
# units are already loaded. That means the links in one file will be parsed
# before the units in other files are. If links are the only part that require
# all files to be parsed, we could delay the link parsing untill the rest is
# done.

# While the game is in development it's better to read the scripts from a folder
# next to the executable, so that people can edit the script easily. If we run
# the game from the editor, we can copy those scripts in the res folder
func _ready():
	# First we read all the functions that correspond to script commands and
	# fill the commands dictionary for easier access
	for dict in ScriptCommands.get_script().get_script_method_list():
		# We ignore function names that start with _ because they are meant to
		# be private functions that don't represent any script command
		if dict["name"].begins_with("_"):
			continue
		if dict["args"].size() > 0:
			_commands[dict["name"]] = dict["args"][0]["type"]
		else:
			_commands[dict["name"]] = 0
	
	_unit_matcher.compile(_unit_regex)
	_scene_matcher.compile(_scene_regex)
	_initial_matcher.compile(_initial_regex)
	_final_matcher.compile(_final_regex)
	_links_matcher.compile(_links_regex)
	_asign_matcher.compile(_asign_regex)
	# If the game is run from the debug executable. We have to decide if this
	# must also work from the release executable
	if OS.has_feature("debug") and not OS.has_feature("editor"):
		_script_folder = OS.get_executable_path().get_base_dir() + "/Guion"
	# If it is running from the editor or from a release executable
	else:
		_script_folder = _editor_script_folder
	
	print("ScriptParser | Script folder: " + _script_folder)
	print("ScriptParser | Commands list: " + str(_commands))
	parse_all()


# Clears the ScriptManager and parses all the files in the script folder
func parse_all():
	ScriptManager.clear()
	var dir = DirAccess.open(_script_folder)
	var script_files = Array(dir.get_files())
	print("ScriptParser | Script files: " + str(script_files))
	for file in script_files:
		_parse_file(_script_folder.path_join(file))
	

# For now we are using FileAccess, because we're assuming that the text files
# are going to be read the same way if they are external files or are in the
# pck. If that's not the case we must add a condition to check from where the
# file is being read.
func _parse_file(file_name: String):
	var file = FileAccess.open(file_name, FileAccess.READ)
	var contents = file.get_as_text(true)
	
	var matches = _scene_matcher.search_all(contents)
	if matches.size() == 0:
		printerr("ScriptParser | No scenes where found with name " + file_name)
	for m in matches:
		var name = m.get_string("name")
		var scene = _create_scene(name, m.get_string("contents"))
		ScriptManager.add(scene)

# Creates a new scene with the given name and a string with the contents between
# the openning and closing tags, which will be parsed in this function.
# If a scene with that name already exists, the contents are added to that one
# instead to allow for scenes defined across multiple files
func _create_scene(scene_name: String, scene_contents: String) -> Scene:
	print("ScriptParser | Creating scene with name " + scene_name)
	var units: Array[Unit] = []
	var unit_matches = _unit_matcher.search_all(scene_contents)
	if unit_matches.size() == 0:
		printerr("ScriptParser | No units were found in this scene")
	for m in unit_matches:
		var unit_name = m.get_string("name")
		var contents = m.get_string("contents")
		units.append(_create_unit(unit_name, contents))
	
	var initial_matches = _initial_matcher.search_all(scene_contents)
	var initial: String = ""
	if initial_matches.size() > 1:
		printerr("ScriptParser | There must be at most 1 initial unit")
	elif initial_matches.size() == 1:
		initial = initial_matches[0].get_string("name")
	
	var final_matches = _final_matcher.search_all(scene_contents)
	var final: String = ""
	if final_matches.size() > 1:
		printerr("ScriptParser | There must be at most 1 final unit")
	elif final_matches.size() == 1:
		final = final_matches[0].get_string("name")
		
	var scene: Scene
	# If the scene already existed, we must the newly found contets to it. This
	# way we allow for a scene to be split amongst several files.
	if ScriptManager.scenes.has(scene_name):
		scene = ScriptManager.scenes[scene_name]
	else:
		scene = Scene.new(scene_name)
	
	scene.add_all(units)
	scene.name_first = initial
	scene.name_last = final
	
	var link_matches = _links_matcher.search_all(scene_contents)
	if link_matches.size() == 0:
		printerr("ScriptParser | No links were found")
	for m in link_matches:
		print("ScriptParser | Adding link " + m.get_string("contents"))
		var split = m.get_string("contents").split("->", false)
		var array = Array(split).map(func(s): return s.strip_edges())
		if array.size() > 1:
			var i = 1
			while i < array.size():
				scene.link(array[i - 1], array[i])
				i += 1
	
	# TODO: this should go somewhere else, this is just temporary
	var asign_matches = _asign_matcher.search_all(scene_contents)
	for m in asign_matches:
		var list = m.get_string("contents").split(",", false)
		for split in list:
			var pair = split.split("->", false)
			var unit_name = pair[0].strip_edges()
			var character_name = pair[1].strip_edges()
			var character = CharacterManager.load(character_name) as Character
			if not character:
				printerr("ScriptParser | Can't find a character with unit_name " + character_name)
				continue
			character.dialog_unit = unit_name
	return scene

# Creates a new unit with the given name and a string with the contents between
# the openning and closing tags, which will be parsed in this function
func _create_unit(unit_name: String, contents: String) -> Unit:
	print("ScriptParser | Creating a unit with name " + unit_name)
	
	# The way the instruction parser is as follow:
	# 1 - A line is read
	# 2 - If the line begins with [ and ends with ], it's a command.
	# 3 - If it only begins with [ or it only ends with ], but not both,
	# 		it's assumed the intention was to write a command but the line was
	#		badly written and an error is thrown.
	# 4 - If it doesn't begin with [ and it doesn't end with ], it's a dialog line
	
	var instructions: Array[Instruction] = []
	var lines = contents.split("\n", false)
	for line in lines:
		if line.begins_with("[") and line.ends_with("]"):
			instructions.append(extract_command(line.trim_prefix("[").trim_suffix("]").strip_edges()))
		elif not line.begins_with("[") and not line.ends_with("]"):
			instructions.append(extract_dialog(line.strip_edges()))
			instructions.append(Instruction.new("esperar"))
		else:
			instructions.append(Instruction.new("error", "The instruction was \
				badly written.\n Line: " + line))
		
	return Unit.new(unit_name, instructions)
	

# Receibes a line and extracts the name of a command and its arguments
func extract_command(line: String) -> Instruction:
	# If the line begins with #, it's a comment and it's ignored
	if line.begins_with("#"):
		return
	# The name is split from it's arguments. Only a single ':' is allowed
	var components = line.split(":")
	if components.size() > 2:
		return Instruction.new("error", "The command must be of the form <name>: <args>")
	# As the functions are written in lower case, we convert the name
	var command_name = components[0].strip_edges().to_snake_case()
	
	var args = null
	if components.size() > 1:
		args = components[1].strip_edges()
	
	# The command specified in the script must be defined in the command list
	if _commands.keys().find(command_name) >= 0:
		# This is the case for the commands that don't receive arguments
		if _commands[command_name] == Variant.Type.TYPE_NIL:
			if args == null:
				return Instruction.new(command_name)
			else:
				return Instruction.new("error", "The command " + command_name + \
					" must not receive arguments, but received " + args)
		# From this point, the commands must receive arguments. If not, it's an error
		var split_args: PackedStringArray = PackedStringArray([])
		if args != null:
			split_args = args.split(",")
		# This is the case for the commands that only receibe one argument
		if _commands[command_name] == Variant.Type.TYPE_STRING:
			if split_args.size() == 1:
				return Instruction.new(command_name, split_args[0] as String)
			else:
				return Instruction.new("error", "The command " + command_name + \
					" must receive an argument of type String, but received " + \
					split_args)
		# Finally, this is the case for the commands that receive several arguments
		var temp: Array[String] = []
		for string in split_args:
			temp.append(string.strip_edges())
		return Instruction.new(command_name, temp)
	else:
		return Instruction.new("error", "There isn't a command with name: " + command_name)

# Extracts a line of dialog and who says it, if any
func extract_dialog(line: String):
	# The name of the speaker is split from the text. Only one ':' is allowed
	var components = line.split(":")
	if components.size() > 2:
		return Instruction.new("error", "The line must be of the form <name>: <text> or <text>")
	var name = ""
	var text = ""
	
	if components.size() == 1:
		text = components[0].strip_edges()
	else:
		name = components[0].strip_edges()
		text = components[1].strip_edges()
	return Instruction.new("dialogo", [name, text] as Array[String])
