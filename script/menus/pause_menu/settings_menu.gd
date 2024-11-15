extends Control

@onready var resolution_selector: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/resolution
var fullscreen = true
var resolutions: Dictionary = {
	"640x480": Vector2(640, 480),
	"800x600": Vector2(800, 600),
	"1024x768": Vector2(1024, 768),
	"1280x720": Vector2(1280, 720),
	"1366x768": Vector2(1366, 768),
	"1600x900": Vector2(1600, 900),
	"1920x1080": Vector2(1920, 1080),
	"2560x1440": Vector2(2560, 1440),
	"3840x2160": Vector2(3840, 2160),
	"7680x4320": Vector2(7680, 4320)
}

func _ready():
	for resolution in resolutions.keys():
		resolution_selector.add_item(resolution)

func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)

func _on_mute_toggled(button_pressed):
	AudioServer.set_bus_mute(0, button_pressed)

func _on_fullscreen_toggled(button_pressed):
	fullscreen = !fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_resolution_item_selected(index):
	var selected_resolution = resolution_selector.get_item_text(index)
	var size = resolutions.get(selected_resolution)
	DisplayServer.window_set_size(size)
	print("Resolución cambiada a: ", size)
