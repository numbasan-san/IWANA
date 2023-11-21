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

# The name of the first unit that should be run when loading this scene. If this
# value is empty, then no unit will be automatically loaded and they must be
# called from some other code
var _name_first: String
var name_first: String:
	get:
		return _name_first

# The name of the last unit of the scene. If this has some value, after
# executing the unit with that name the scene will be marked as ready and the
# next scene will start
var _name_last: String
var name_last: String:
	get:
		return _name_last

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
		units: Array[Unit],
		first: String = "",
		last: String = ""):
	self.name = name
	self.units = {}
	self._name_first = first
	self._name_last = last
	for unit in units:
		_add(unit)
	restart()

func run():
	if _running and not done:
		current_unit.run()
		if current_unit.is_done():
			# If the unit that just finished is the last one, the scene is
			# marked done so that the script manager will switch to the next one
			if current_unit.name == name_last:
				done = true
			# If it's linked to another unit, we switch to that one
			elif _links.has(current_unit.name):
				var name_next = _links[current_unit.name]
				current_unit = units[name_next]
				current_unit.restart()
			# If there is no linked unit, but this isn't the last one of the
			# scene, this scene stops running and we close the dialog screen
			# but the scene isn't marked as done, so that another unit can be
			# loaded later
			else:
				_running = false
				await ScriptCommands._close()

# Loads the first unit of this scene, if it has any defined, and marks it as
# not done so that other units can also be run. If there is no
# first unit, another one must be loaded manually
func restart():
	if _name_first:
		self.load(_name_first)
	else:
		done = false
		printerr("Scene | This scene doesn't have an initial unit, so nothing is done")

# Loads a unit and runs the scene
func load(name: String):
	if units.has(name):
		current_unit = units[name]
		current_unit.restart()
		done = false
		pause(false)
	else:
		printerr("Scene | Can't find a unit with name " + name)

# Adds a new unit to the scene. It should only be called in the constructor to
# ensure the scene is in a valid state
func _add(unit: Unit):
	if not units.has(unit.name):
		units[unit.name] = unit
	else:
		printerr("Scene | The scene already has an unit named " + unit.name)

# Links two units so that when the first one finishes running, control passes to
# the next one
func link(source: String, target: String):
	if not units.has(source):
		printerr("Scene | The scene doesn't have an unit named " + source)
	elif not units.has(target):
		printerr("Scene | The scene doesn't have an unit named " + target)
	else:
		_links[source] = target
		

func pause(pausa = true):
	_running = not pausa
	current_unit.pause(pausa)

