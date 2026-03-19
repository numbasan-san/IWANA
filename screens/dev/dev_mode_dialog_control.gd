class_name DevModeDialogControl extends Control

@export var scenes: MenuButton
@export var units: MenuButton
@export var line_number_label: Label
@export var dialog_details: Control

var enabled: bool = false

# Variable the first element of fill_scenes_list
var first_scene: String

func _process(_delta):
	if enabled:
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
		line_number_label.text = str(line)
		dialog_details.show()
	else:
		dialog_details.hide()

func enable():
	if !enabled:
		# TODO: for now, we only enable it after the game starts and the first scene
		# is loaded, so that if we open the dev mode before the scenes are loaded,
		# the next time we open it they are fixed.
		if ScriptManager.current_scene:
			enabled = true
		fill_scenes_list()
		# Esta función solo busca las unidades de la escena actual, por lo que
		# siempre debería ser seguro llamarla
		fill_units_list()

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

func _on_script_reload():
	ScriptParser.parse_all()
	ScriptManager.restart()
