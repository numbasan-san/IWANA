extends Screen

@export var zones: MenuButton
@export var scenes: MenuButton
@export var units: MenuButton

var enabled = false

# Variable para almacenar el primer elemento de fill_scenes_list
var first_scene: String

func _process(_delta):
	if enabled:
		if Player.character and Player.character.zone:
			zones.disabled = false
			zones.text = Player.character.zone.name
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
	# Esta función solo busca las unidades de la escena actual, por lo que
	# siempre debería ser seguro llamarla
	fill_units_list()

func fill_zones_list():
	if not enabled:
		return
	var popup: PopupMenu = zones.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones de popup requieren el índice del ítem,
	# pero al agregar un ítem la función no devuelve su índice asignado, por lo que necesitamos
	# asignar manualmente un id y obtener el índice a través de ese id
	var item_id = 0
	ZoneManager.load_all()
	for zone_name in ZoneManager.zones:
		var zone = ZoneManager.load(zone_name)
		popup.add_item(zone.name, item_id)
		var index = popup.get_item_index(item_id)
		item_id += 1
		popup.set_item_metadata(index, zone)
		
	# Al conectar esta señal asumimos que nunca se conectará a otra función fuera de este script.
	# Si esto cambia en algún momento, necesitamos arreglar este código
	var world = ScreenManager.rpg_screen.contents
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var zone = popup.get_item_metadata(index)
			world.spawn(Player.character, zone, "Default", "down", world.SpawnFallback.FIRST)
		)

func fill_scenes_list():
	if not enabled:
		return
	var popup: PopupMenu = scenes.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones de popup requieren el índice del ítem,
	# pero al agregar un ítem la función no devuelve su índice asignado, por lo que necesitamos
	# asignar manualmente un id y obtener el índice a través de ese id
	var item_id = 0
	for scene_name in ScriptManager.scenes:
		popup.add_item(scene_name, item_id)
		item_id += 1
		
	# Al conectar esta señal asumimos que nunca se conectará a otra función fuera de este script.
	# Si esto cambia en algún momento, necesitamos arreglar este código
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
	# Esta variable es necesaria porque varias funciones de popup requieren el índice del ítem,
	# pero al agregar un ítem la función no devuelve su índice asignado, por lo que necesitamos
	# asignar manualmente un id y obtener el índice a través de ese id
	var item_id = 0
	for unit_name in ScriptManager.current_scene.units:
		popup.add_item(unit_name, item_id)
		item_id += 1
		
	# Al conectar esta señal asumimos que nunca se conectará a otra función fuera de este script.
	# Si esto cambia en algún momento, necesitamos arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var unit_name = popup.get_item_text(index)
			ScriptManager.current_scene.load(unit_name)
		)

func _on_script_reload():
	ScriptParser.parse_all()
	ScriptManager.restart()
