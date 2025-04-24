class_name DevMode extends Screen

@export var characters: MenuButton
@export var party: DevPartyControl
@export var zones: MenuButton
@export var scenes: MenuButton
@export var units: MenuButton
@export var test: Label

var enabled = false

# Variable para almacenar el primer elemento de fill_scenes_list
var first_scene: String

func _ready():
	party.dev = self

func _process(_delta):
	if enabled and is_active:
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

func enable():
	print("Dev Mode On")
	activate()
	enabled = true
	
	Player.control_changed.connect(func(char):
		characters.text = char.char_name.to_pascal_case())
	Player.control_removed.connect(func():
		characters.text = "Ninguno")
	party.enable()
	fill_characters_list()
	if Player.character:
		var char = Player.character
		characters.text = char.char_name.to_pascal_case()
	fill_zones_list()
	fill_scenes_list()
	# Esta función solo busca las unidades de la escena actual, por lo que
	# siempre debería ser seguro llamarla
	fill_units_list()
	
func fill_zones_list():
	if not enabled:
		return
	
	ZoneManager.load_all()
	var dict = {}
	for zone in ZoneManager.zones.values():
		dict[zone.name] = zone
	var world = ScreenManager.rpg_screen.contents
	var spawn = func(zone: Zone):
		world.spawn(Player.character, zone, "Default", "down", world.SpawnFallback.FIRST)
	
	zones.fill_contents(dict, spawn)

func fill_scenes_list():
	if not enabled:
		return
	
	var load_scene = func(scene: Scene):
		ScriptManager.load(scene.name)
		fill_units_list()
	
	scenes.fill_contents(ScriptManager.scenes, load_scene)

func fill_units_list():
	if not enabled or not ScriptManager.current_scene:
		return
	
	var load_unit = func(unit: Unit):
		ScriptManager.current_scene.load(unit.name)
	
	units.fill_contents(ScriptManager.current_scene.units, load_unit)

# This only allows changing control between characters that have been loaded
# already
func fill_characters_list():
	if not enabled:
		return
	
	CharacterManager.load_all()
	
	var dict = {}
	for char_name in CharacterManager.characters:
		dict[char_name.to_pascal_case()] = CharacterManager.characters[char_name]
	
	var world = ScreenManager.rpg_screen.contents
	var control_character = func(char):
		Player.control(char)
		if not Player.character.zone:
			var def_zone = ZoneManager.load("dev_testing")
			world.spawn(Player.character, def_zone, "Default", "down", world.SpawnFallback.FIRST)
	characters.fill_contents(dict, control_character)

func _on_script_reload():
	ScriptParser.parse_all()
	ScriptManager.restart()

