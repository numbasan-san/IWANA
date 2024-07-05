extends Control

# sub-menu's settings
func characters_list():
	menus_setting(false, true, false, false)
	buttons_setting(
		Vector2(384, 265), 
		Vector2(365, 320), 
		Vector2(375, 375)
	)

func map_list():
	menus_setting(false, false, true, false)
	$selected_menu/maps_menu.load()
	buttons_setting(
		Vector2(384, 265), 
		Vector2(365, 320), 
		Vector2(375, 375)
	)

func item_list():
	menus_setting(false, false, false, true)
	buttons_setting(
		Vector2(384, 265), 
		Vector2(365, 320), 
		Vector2(375, 375)
	)

# menu and menu's elements settings
func menus_setting(default, characters, maps, items):
	$default_menu/LibroCerrado.visible = default
	$selected_menu/characters_menu.visible = characters
	$selected_menu/maps_menu.visible = maps
	$selected_menu/items_menu.visible = items

func buttons_setting(characters_coords, maps_coords, items_coords):
	$default_menu/characters_btn.set_position(characters_coords)
	$default_menu/maps_btn.set_position(maps_coords)
	$default_menu/items_btn.set_position(items_coords)


func _ready():
	menus_setting(true, false, false, false)
	buttons_setting(
		Vector2(1183, 265), 
		Vector2(1188, 320), 
		Vector2(1193, 375)
	)
	
func _process(delta):
	test_pause()

func resume():
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	self.visible = false
	menus_setting(false, false, false, false)
	buttons_setting(
		Vector2(1183, 265), 
		Vector2(1188, 320), 
		Vector2(1193, 375)
	)

func pause():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	menus_setting(true, false, false, false)

func test_pause():
	if Input.is_action_just_pressed("game_menu") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("game_menu") and get_tree().paused == true:
		resume()


func _on_characters_btn_pressed():
	characters_list()

func _on_maps_btn_pressed():
	map_list()

func _on_items_btn_pressed():
	item_list()
