extends Pantalla

@export var todas_las_zonas: Array[String]

@onready var mundo = $/root/Juego.pantallas.pantalla_mundo.get_node("Mundo")

var habilitado = false

func _process(_delta):
	if habilitado:
		if $"/root/Juego".personajes.jugador and $"/root/Juego".personajes.jugador.zona:
			$Contenidos/DetallesUbicacion/NombreZona.text = $"/root/Juego".personajes.jugador.zona.name
		else:
			$Contenidos/DetallesUbicacion/NombreZona.text = ""
	if $"/root/Juego".pantallas.pantalla_dialogo.visible:
		$Contenidos/DetallesDialogo.show()
	else:
		$Contenidos/DetallesDialogo.hide()

func habilitar():
	print("Dev Mode On")
	activar()
	habilitado = true
	rellenar_lista_zonas()

func rellenar_lista_zonas():
	if not habilitado:
		return
	for nombre_zona in todas_las_zonas:
		var zona = $"/root/Juego".zonas.cargar(nombre_zona)
		var boton = Button.new()
		boton.text = zona.name
		boton.focus_mode = Control.FOCUS_NONE
		boton.mouse_filter = Control.MOUSE_FILTER_STOP
		boton.add_theme_font_size_override("font_size", 30)
		boton.pressed.connect(func () -> void:
			var jugador = $"/root/Juego".personajes.jugador
			mundo.spawn(jugador, zona, "Default", "down", mundo.SpawnFallback.FIRST)
		)
		$Contenidos/SeleccionEscena/PanelContainer/VBoxContainer/Zonas.add_child(boton)
