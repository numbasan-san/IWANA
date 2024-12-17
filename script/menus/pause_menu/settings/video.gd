extends Control

@onready var resolution_selector: OptionButton = $VBoxContainer/HBoxContainer/resolution

var fullscreen = false

var resolutions: Dictionary = {
	"640x480": Vector2i(640, 480),
	"800x600": Vector2i(800, 600),
	"1024x768": Vector2i(1024, 768),
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080),
#	"2560x1440": Vector2i(2560, 1440),
#	"3840x2160": Vector2i(3840, 2160),
#	"7680x4320": Vector2i(7680, 4320)
}

func _ready():
	# Cargar opciones de resolución en el selector
	for resolution in resolutions.keys():
		resolution_selector.add_item(resolution)

func _on_fullscreen_toggled(button_pressed):
	fullscreen = button_pressed
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Ajustar el escalado manualmente
	if fullscreen:
		# Tamaño base del juego
		var base_resolution = Vector2i(320, 240) # Resolución base del juego
		var screen_resolution = DisplayServer.screen_get_size()
		
		# Calcular escala
		var scale = screen_resolution / base_resolution
		
		# Aplicar escala al nodo raíz del juego (Control o CanvasLayer, etc.)
		var root_node = get_node("/root/Main") # Cambia a la ruta de tu nodo principal
		if root_node:
			root_node.scale = Vector2i(scale.x, scale.y)
			print("Escalado ajustado a: ", root_node.scale)
		else:
			print("Nodo principal no encontrado")

func _on_resolution_item_selected(index): # Cambia la resolución del juego
	var selected_resolution = resolution_selector.get_item_text(index)
	var screen_size = resolutions.get(selected_resolution)
	
	if screen_size:
		if fullscreen:
			var screen_dimensions = DisplayServer.screen_get_size()
			var aspect_ratio = float(screen_size.x) / screen_size.y
			var scaled_size = Vector2i(screen_dimensions.x, int(screen_dimensions.x / aspect_ratio))
			
			if scaled_size.y > screen_dimensions.y:
				scaled_size = Vector2i(int(screen_dimensions.y * aspect_ratio), screen_dimensions.y)
			
			DisplayServer.window_set_size(scaled_size)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		print("Resolución cambiada a: ", screen_size)
		
		var current_screen_size = DisplayServer.window_get_size()
#		$"Panel/Resolution Setted".text = "Resolución configurada: " + str(screen_size) + "\n"
#		$"Panel/Resolution Setted".text += "Resolución actual: " + str(current_screen_size)
	else:
		print("Resolución seleccionada no válida.")
