extends Screen

func _ready():
	transitions.animation_finished.connect(_initial_push, CONNECT_ONE_SHOT)

func _input(event):
	if event.is_action_released("skip"):
		print("IntroScreen | Skiping intro")
		# This code assumes a specific animation and will stop working once that
		# is replaced or extended. We need a way to get specific keyframes of a
		# track and jump to them
		var fade_in_end = 2
		var fade_out_start = 4
		# If the image is just starting to appear we jump to the opposite
		# position so it starts fading out before appearing completely
		if transitions.current_animation_position < fade_in_end:
			var delta = transitions.current_animation_length \
				- transitions.current_animation_position
			transitions.seek(delta, true)
		# If it's showing completely, we jump to the fade out point
		elif transitions.current_animation_position < fade_out_start:
			transitions.seek(fade_out_start, true)
		# If it is already fading out, we do nothing

func _initial_push(anim_name):
	if anim_name == "Inicio":
		ScreenManager.push(ScreenManager.main_menu_screen, "Hide", "In")

func activate():
	transitions.play("Inicio")
	super.activate()
