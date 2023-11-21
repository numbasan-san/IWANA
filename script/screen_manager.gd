extends Node

# Controls the active screens and menus and their transitions.
# Only one screen will be active each time. Others have to be paused or closed.
# If a screen is closed it needs to have a system to save its state.
# A menu is a screen that doesn't cover the entire area or is partialy
# transparent, so it can be drawn over other screens.

# The screen stack is used to transition between screens or to open menus over
# the current screen. Only the screen on top of the stack must be active When
# another screen is added, the current one must be deactivated and the new one
# activated.
# TODO: consider if we should keep it like this or we should allow several
# screens to be active at the same time, to allow some menus and overlays that
# don't pause execution of the lower screens.
# If the current screen defines In and Out animations, these will play when the
# screen is added or removed from the pile respectively. If it defines Hide and
# Show animations, they will be played when the screen is covered by another or
# revealed respectively.
var _screen_stack: Array[Screen]

# This variable points to the top of the stack
var current_screen: Screen:
	get:
		if _screen_stack.is_empty():
			return null
		return _screen_stack.back()

# The dev mode screen shows information of the state of the game and allows its
# easy manipulation
@export var dev_screen: Screen

# The first screen of the game shows the logos of the company an dev tools, if
# any, intro animations, credits, etc.
@export var intro_screen: Screen

# The first screen after the intro has options to start a new game, load a
# previous one, change settings, etc.
@export var main_menu_screen: Screen

# The screen of the rpg mode, which will be shown during most of the game
@export var rpg_screen: Screen

# The screen for combat mode
@export var combat_screen: Screen

# The screen that will show dialogs between characters in a visual novel style.
# It can have a background image, or be transparent so that it will show as an
# overlay when talking to NPCs
@export var dialog_screen: Screen


func _ready():
	main_menu_screen.deactivate()
	dialog_screen.deactivate()
	rpg_screen.deactivate()
	combat_screen.deactivate()
	dev_screen.deactivate()
	intro_screen.deactivate()
	
	push(intro_screen, false)
	

# Adds a new screen to the top of the stack. 
# It's assumed that the inactive screens will still be visible even if covered
# by new screens, so that transparent screens will show the contents of the
# previous ones.
func push(new_screen: Screen, animate: bool = true):
	if new_screen.push_requested:
		return
	new_screen.push_requested = true
	
	if current_screen:
		# The current screen is deactivated but still shown, so that the
		# animation can still play.
		current_screen.deactivate(true)
		if animate and current_screen.transitions.has_animation("Hide"):
			current_screen.transitions.play("Hide")
			await current_screen.transitions.animation_finished
	# From this point we don't need to manipulate the old screen
	_screen_stack.push_back(new_screen)
	# The new screen is activated so that its animations are shown and it
	# can respond to player input while it's still appearing
	current_screen.activate()
	
	if animate and current_screen.transitions and current_screen.transitions.has_animation("In"):
		current_screen.transitions.play("In")
		await current_screen.transitions.animation_finished
	current_screen.push_requested = false

# Remove the screen on top of the stack and give control back to the next screen.
# The screen to be removed must be passed as an argument so that it can be
# checked if it actually correspond to the active screen, so that the code
# doesn't remove other screens by mistake.
func pop(removed_screen: Screen, animate: bool = true):
	# If we try to remove a screen that isn't the current one or it's already in
	# the process of being removed, we ignore it
	if current_screen != removed_screen or current_screen.pop_solicitado:
		return
	current_screen.pop_solicitado = true
	# If the current screen has a transition animation, we must wait for it to
	# finish playing
	if animate and current_screen.transitions and current_screen.transitions.has_animation("Out"):
		# The current screen is paused so that it ignores player input but is
		# still being shown while it's being animated
		current_screen.deactivate(true)
		current_screen.transitions.play("Out")
		await current_screen.transitions.animation_finished
		
	# At this point the removal animation is done playing and the execution is
	# resumed, so it's safe to change this variable to false
	current_screen.pop_solicitado = false
	
	current_screen.deactivate()
	_screen_stack.pop_back()
	current_screen.activate()
	if animate and current_screen.transitions.has_animation("Show"):
		current_screen.transitions.play("Show")
		await current_screen.transitions.animation_finished
