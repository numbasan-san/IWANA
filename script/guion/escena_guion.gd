class_name Escena

# A scene contains a set of units and links between them to determine when they
# should be executed

# The name of the scene, it can be used to refer to this scene from other parts
# of the code
var name: String

# All units defined for this scene. Each entry is a pair (name, instance)
var units: Dictionary

# The links between units which determine in which order they should be executed.
# Each entry is a pair (name_current, name_next), with the names of the unit
# currently running and the name of the unit that should be run when this one
# finishes, respectively
var _links: Dictionary

# The name of the first unit in the current chain of links. It's used to send
# signals when the chain is started and finished
# TODO: replace with a better system
var _current_chain_head: String

# The name of the first unit that should be run when loading this scene. If this
# value is empty, then no unit will be automatically loaded and they must be
# called from some other code
var name_first: String:
	get:
		return name_first
	set(value):
		# We only allow this value to be set once, as changing it is pointless.
		# Changing it while the game is running will either generate errors or 
		# do nothing; if two files define the same scene with different values
		# for this, it's most likely a mistake
		if not name_first:
			name_first = value
		else:
			printerr("ScriptScene | The first unit of the scene can't be " \
				+ "changed after set")

# The name of the last unit of the scene. If this has some value, after
# executing the unit with that name the scene will be marked as ready and the
# next scene will start
var name_last: String:
	get:
		return name_last
	set(value):
		# We only allow this value to be set once, as changing it is pointless.
		# Changing it while the game is running will either generate errors or 
		# do nothing; if two files define the same scene with different values
		# for this, it's most likely a mistake
		if not name_last:
			name_last = value
		else:
			printerr("ScriptScene | The last unit of the scene can't be " \
				+ "changed after set")

# The unit being executed at this moment
var current_unit: Unit

# The units will only run while this value is true. This can be changed to pause
# the scene when some event happens
var _running = false

# It's true when this scene has finished running its last unit and is ready to
# give control to the next scene
var done = false

# Builds a new scene with a name, list of units, first and last units
func _init(
		name: String,
		units: Array[Unit] = [],
		first: String = "",
		last: String = ""):
	self.name = name
	self.units = {}
	self.name_first = first
	self.name_last = last
	add_all(units)

func run():
	if _running and not done:
		current_unit.run()
		if current_unit.is_done():
			# If the unit that just finished is the last one, the scene is
			# marked done so that the script manager will switch to the next one
			if current_unit.name == name_last:
				done = true
				ScriptManager.chain_ended.emit(self.name, _current_chain_head)
				_current_chain_head = ""
			# If it's linked to another unit, we switch to that one
			elif _links.has(current_unit.name):
				var name_next = _links[current_unit.name]
				# If the linked unit exists, we change to that
				if units.has(name_next):
					current_unit = units[name_next]
					current_unit.restart()
				# If not, that is an error and we interrupt the link. We must
				# allow links to units that aren't defined if we want to spread
				# a scene among several files, as some units can be loaded after
				# their links
				else:
					_running = false
					await ScriptCommands._close()
					ScriptManager.chain_ended.emit(self.name, _current_chain_head)
					_current_chain_head = ""
			# If there is no linked unit, but this isn't the last one of the
			# scene, this scene stops running and we close the dialog screen
			# but the scene isn't marked as done, so that another unit can be
			# loaded later
			else:
				_running = false
				await ScriptCommands._close()
				ScriptManager.chain_ended.emit(self.name, _current_chain_head)
				_current_chain_head = ""

# Loads the first unit of this scene, if it has any defined, and marks it as
# not done so that other units can also be run. If there is no
# first unit, another one must be loaded manually
func restart():
	if name_first:
		self.load(name_first)
	else:
		done = false
		printerr("Scene | This scene doesn't have an initial unit, so nothing is done")

# Loads a unit and runs the scene
func load(name: String):
	if units.has(name):
		current_unit = units[name]
		# We assume that chains are only started by loading the first unit, and
		# every unit that isn't mentioned in any chain can be considered to be
		# in a chain with only one element
		_current_chain_head = name
		current_unit.restart()
		done = false
		pause(false)
		ScriptManager.chain_started.emit(self.name, _current_chain_head)
	else:
		printerr("Scene | Can't find a unit with name " + name)

# Adds a new unit to the scene.
func add(unit: Unit):
	if not units.has(unit.name):
		units[unit.name] = unit
	else:
		printerr("Scene | The scene already has an unit named " + unit.name)

# Adds all the units in the list to the scene
func add_all(units: Array[Unit]):
	for unit in units:
		add(unit)

# Links two units so that when the first one finishes running, control passes to
# the next one. We allow links between undefined units so that a scene can be
# spread among several files
func link(source: String, target: String):
	_links[source] = target

func pause(pausa = true):
	_running = not pausa
	current_unit.pause(pausa)

