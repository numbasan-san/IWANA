extends Control


# menu and menu's elements settings
func menus_setting(default, characters, maps, items, contacts):
	$selected_menu/default_menu.visible = default
	$selected_menu/characters_menu.visible = characters
	$selected_menu/maps_menu.visible = maps
	$selected_menu/items_menu.visible = items
	$selected_menu/contacts_menu.visible = contacts

func _ready():
	menus_setting(true, false, false, false, false)

func _process(delta):
	test_pause()

func resume():
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	self.visible = false

func pause():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	menus_setting(true, false, false, false, false)

func test_pause():
	if Input.is_action_just_pressed("game_menu") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("game_menu") and get_tree().paused == true:
		resume()
