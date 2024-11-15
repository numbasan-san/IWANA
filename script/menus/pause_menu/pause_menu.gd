extends Control

# menu and menu's elements settings
func menus_setting(default, settings):
	$default_menu.visible = default
	$settings_menu.visible = settings

func _ready():
	menus_setting(true, false)

func _process(delta):
	test_pause()

func resume():
	$AnimationPlayer.play_backwards("blur")
	menus_setting(false, false)
	self.visible = false
	get_tree().paused = false

func pause():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	menus_setting(true, false)

func test_pause():
	if Input.is_action_just_pressed("pause_button") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause_button") and get_tree().paused == true:
		resume()
