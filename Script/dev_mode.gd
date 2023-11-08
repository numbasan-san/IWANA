extends Pantalla

@export var todas_las_zonas: Array[String]

@onready var mundo = $/root/Juego/PantallaMundo/Mundo

var habilitado = false

func _process(_delta):
	if habilitado:
		if $"../Personajes".jugador and $"../Personajes".jugador.zona:
			$DetallesUbicacion/NombreZona.text = $"../Personajes".jugador.zona.name
		else:
			$DetallesUbicacion/NombreZona.text = ""
	if $"../PantallaDialogo".visible:
		$DetallesDialogo.show()
	else:
		$DetallesDialogo.hide()

func habilitar():
	print("Dev Mode On")
	habilitado = true
	rellenar_lista_zonas()

func rellenar_lista_zonas():
	if not habilitado:
		return
	for nombre_zona in todas_las_zonas:
		var zona = $"../Zonas".cargar(nombre_zona)
		var boton = Button.new()
		boton.text = zona.name
		boton.pressed.connect(func () -> void:
			var jugador = $"../Personajes".jugador
			mundo.spawn(jugador, zona, "Default", "down", mundo.SpawnFallback.FIRST)
		)
		$SeleccionEscena/PanelContainer/VBoxContainer/Zonas.add_child(boton)
