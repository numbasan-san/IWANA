class_name Instruction

# Represents a script instruccion, which can be a command, show a line of dialog
# or raise an error


enum { COMMAND, DIALOG, ERROR, WAIT }

# The name of the instruction, mainly used for debugging
var name: String

# The arguments that the instruction will receive when running, mainly used for
# debugging
var arguments: Variant

# Callable that's going to be executed when calling this instruction
var _callable: Callable

# One of COMMAND, DIALOG, ERROR or WAIT
var _type: int
var type: int:
	get:
		return _type

# Builds a new isntruction that can be called in the future. It's the job of the
# parser to ensure that only defined instructions are built
func _init(name_arg: String, args: Variant = null):
	self.name = name_arg
	self.arguments = args
	
	if name == "dialogo":
		_type = DIALOG
	elif name == "error":
		_type = ERROR
	elif name == "esperar":
		_type = WAIT
	else:
		_type = COMMAND
	
	if not args:
		_callable = Callable(ScriptCommands, name)
	else:
		_callable = Callable(ScriptCommands, name).bind(args)

# Runs the stored callable
func run():
	_callable.call()
