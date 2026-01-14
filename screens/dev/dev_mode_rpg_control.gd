class_name DevModeRPGControl extends Control

@export var characters: MenuButton
@export var zones: MenuButton
@export var party: DevPartyControl

var enabled: bool = false

func _process(_delta):
	if enabled and visible:
		if Player.character and Player.character.zone:
			zones.disabled = false
			zones.text = Player.character.zone.name
		else:
			zones.disabled = true
			zones.text = "Ninguna"

func enable():
	if !enabled:
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
