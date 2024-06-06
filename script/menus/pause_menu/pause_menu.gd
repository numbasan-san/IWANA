extends Control

func resume():
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	self.visible = false

func pause():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func test_pause():
	if Input.is_action_just_pressed("pause_button") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause_button") and get_tree().paused == true:
		resume()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_pause()


func _on_resume_pressed():
	resume()

func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
