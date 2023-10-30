extends Node

@export var todas_las_zonas: Array[String]

var activado = false

# Antes de que se ag
var _jugador_asignado = false

func _process(delta):
	if activado:
		if $"../Personajes".jugador and $"../Personajes".jugador.zona:
			$DetallesUbicacion/NombreZona.text = $"../Personajes".jugador.zona.name
		else:
			$DetallesUbicacion/NombreZona.text = ""
	if $"../PantallaDialogo".visible:
		$DetallesDialogo.show()
	else:
		$DetallesDialogo.hide()

func activar():
	print("Dev Mode On")
	activado = true
	rellenar_lista_zonas()

func rellenar_lista_zonas():
	if not activado:
		return
	for nombre_zona in todas_las_zonas:
		var zona = $"../Zonas".cargar(nombre_zona)
		var boton = Button.new()
		boton.text = zona.name
		boton.pressed.connect(func () -> void:
			var jugador = $"../Personajes".jugador
			$/root/Juego/PantallaMundo/Mundo.recolocar_personaje(jugador, zona)
		)
		$SeleccionEscena/PanelContainer/VBoxContainer/Zonas.add_child(boton)
