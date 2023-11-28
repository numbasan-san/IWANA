class_name Unit

# A unit is a set of script instructions that are run sequentialy. The
# instructions are run immediately one after the other, except for the "esperar"
# or "wait" instruction, which pauses the execution of the unit until the player
# presses a key.

# The name of this unit. It can be used as a reference from inside other units
# or elsewhere in the game code
var name: String

# The list of instructions to run when the unit is activated
var instructions: Array[Instruction]

# Pointer to the instruction that is going to run next
var current: int

# The number of the line of dialog that is currently showing, mainly used for
# debugging
var current_line: int

# The instructions are only going to be executed while this variable is true. It
# can be used to pause the unit after some event ocurrs
var _running = false

# It should be true if this unit has completed all of its instructions
var _done = false

# Builds a new unit with a name and list of instructions
func _init(name_arg: String, instructions_arg: Array[Instruction]):
	self.name = name_arg
	self.instructions = instructions_arg
	restart()

# Runs the current instruction and moves the pointer to the next one
func run():
	if _running and not _done:
		# This check is done here so that when the last instruction is wait, the
		# unit won't be marked as done until after the continue key is pressed
		if current >= instructions.size():
			_done = true
			return
		instructions[current].run()
		
		# TODO: add code to animate the dialog being written and to wait till it
		# is done animating. A click should finish the animation immediately and
		# a second click should continue execution
		if instructions[current].type == Instruction.DIALOG:
			current_line += 1
		if instructions[current].type == Instruction.WAIT:
			pause()
		current += 1
		

func restart():
	current = 0
	current_line = 0
	_done = instructions.size() == 0
	pause(false)

func pause(paused = true):
	_running = not paused

func is_done():
	return _done
