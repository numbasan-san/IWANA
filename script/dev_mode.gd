extends Screen

@export var all_zones: Array[String]
@export var zones: MenuButton
@export var scenes: MenuButton
@export var units: MenuButton

var enabled = false

func _process(_delta):
	if enabled:
		if CharacterManager.player and CharacterManager.player.zone:
			zones.disabled = false
			zones.text = CharacterManager.player.zone.name
		else:
			zones.disabled = true
			zones.text = "Ninguna"
		var current_scene = ScriptManager.current_scene
		if current_scene:
			scenes.text = current_scene.name
			if current_scene.current_unit:
				units.text = current_scene.current_unit.name
			else:
				units.text = "Ninguna"
		else:
			scenes.text = "Ninguna"
			units.text = "Ninguna"
			
	if ScreenManager.dialog_screen.visible:
		var line = ScriptManager.current_scene.current_unit.current_line
		$Contents/DialogDetails/LineNumberLabel.text = str(line)
		$Contents/DialogDetails.show()
	else:
		$Contents/DialogDetails.hide()

func habilitar():
	print("Dev Mode On")
	activate()
	enabled = true
	fill_zones_list()
	fill_scenes_list()
	# This function only searches for the units of the current scene, so it
	# should be always safe to call
	fill_units_list()

func fill_zones_list():
	if not enabled:
		return
	var popup: PopupMenu = zones.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# This variable is necesary because several popup functions require the item
	# index, but when adding an item the function doesn't return its assigned
	# index, so we need to manually assign an id and obtain the index through that
	var item_id = 0
	for zone_name in all_zones:
		var zone = ZoneManager.load(zone_name)
		popup.add_item(zone.name, item_id)
		var index = popup.get_item_index(item_id)
		item_id += 1
		popup.set_item_metadata(index, zone)
		
	# When connecting this signal we assume that it's never going to be
	# connected to another function outside this script. If this changes at any
	# point we need to fix this code
	var world = ScreenManager.rpg_screen.contents
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var zone = popup.get_item_metadata(index)
			var player = CharacterManager.player
			world.spawn(player, zone, "Default", "down", world.SpawnFallback.FIRST)
		)

func fill_scenes_list():
	if not enabled:
		return
	var popup: PopupMenu = scenes.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# This variable is necesary because several popup functions require the item
	# index, but when adding an item the function doesn't return its assigned
	# index, so we need to manually assign an id and obtain the index through that
	var item_id = 0
	for scene_name in ScriptManager.scenes:
		popup.add_item(scene_name, item_id)
		item_id += 1
		
	# When connecting this signal we assume that it's never going to be
	# connected to another function outside this script. If this changes at any
	# point we need to fix this code
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var scene_name = popup.get_item_text(index)
			ScriptManager.load(scene_name)
			fill_units_list()
		)

func fill_units_list():
	if not enabled:
		return
	var popup: PopupMenu = units.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# This variable is necesary because several popup functions require the item
	# index, but when adding an item the function doesn't return its assigned
	# index, so we need to manually assign an id and obtain the index through that
	var item_id = 0
	for unit_name in ScriptManager.current_scene.units:
		popup.add_item(unit_name, item_id)
		item_id += 1
		
	# When connecting this signal we assume that it's never going to be
	# connected to another function outside this script. If this changes at any
	# point we need to fix this code
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var unit_name = popup.get_item_text(index)
			ScriptManager.current_scene.load(unit_name)
		)

func _on_script_reload():
	ScriptParser.parse_all()
	ScriptManager.restart()
	
