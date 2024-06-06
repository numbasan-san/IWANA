extends Control

# sub-menu's settings
func map_list():
	menus_setting(false, true, false, false)
	buttons_setting(Vector2(366, 254), Vector2(340, 309), Vector2(350, 364))

func item_list():
	menus_setting(false, false, true, false)
	buttons_setting(Vector2(350, 364), Vector2(366, 254), Vector2(340, 309))
	
func characters_list():
	menus_setting(false, false, false, true)
	buttons_setting(Vector2(340, 309), Vector2(350, 364), Vector2(366, 254))

# menu and menu's elements settings
func menus_setting(default, maps, items, characters):
	$default_menu/LibroCerrado.visible = default
	$selected_menu/items_menu.visible = items
	$selected_menu/characters_menu.visible = characters
	$selected_menu/maps_menu.visible = maps

func buttons_setting(azul_coords, verde_coords, rojo_coords):
	$default_menu/azul.set_position(azul_coords)
	$default_menu/verde.set_position(verde_coords)
	$default_menu/rojo.set_position(rojo_coords)

func _ready():
	menus_setting(true, false, false, false)
	buttons_setting(Vector2(1191, 376), Vector2(1181, 266), Vector2(1186, 321))
	
func _process(delta):
	test_pause()

func resume():
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	self.visible = false
	menus_setting(false, false, false, false)
	buttons_setting(Vector2(1191, 376), Vector2(1181, 266), Vector2(1186, 321))

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


func _on_rojo_pressed():
	characters_list()

func _on_azul_pressed():
	map_list()

func _on_verde_pressed():
	item_list()
