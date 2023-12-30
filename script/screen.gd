class_name Screen
extends CanvasLayer

@export var contents: Node

# The transitions of this screen, or null it it doesn't have any. It's used by
# the ScreenManager to animate transitions when showing or hiding screens
@export var transitions: AnimationPlayer

var is_active = false

# Sometimes ocurr an error when a pop is requested in a _process function while
# waiting for a previous animation to finish, _process runs several times in a
# different thread, calling pop repeatedly passing as argument the same screen, 
# and all those calls get queued. As each call stops waiting, each removes the
# screen on top of the stack, which causes it to empty.
# To prevent that, this variable is set to true when entering the pop function
# and set to false as it finishes waiting, so that the function only runs the
# first time it's called.
var pop_solicitado = false
# The same is done for calls to push, to prevent stacking clones of the screen
var push_requested = false

# Activates the processes of the contents of the screen and shows them.
func activate():
	show()
	contents.process_mode = Node.PROCESS_MODE_INHERIT
	set_process_input(true)
	is_active = true

# Deactivates the processes of the contents of this screen. We don't stop the
# entire screen, only the contents, so that if it has transition animations,
# they will still be played, as animations are run in the _process function.
# The argument visible tells if the contents will be visible while paused. This
# is useful if one wants to draw an overlay over the previous screen while it's
# paused.
func deactivate(_visible: bool = false):
	is_active = false
	set_process_input(false)
	contents.set_physics_process(false)
	contents.process_mode = Node.PROCESS_MODE_DISABLED
	if _visible:
		show()
	else:
		hide()
