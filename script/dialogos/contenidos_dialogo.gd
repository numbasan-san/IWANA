extends Control

class_name ContenidosDialogo

enum Posicion { IZQUIERDA, CENTRO, DERECHA }

@export var ruta_fondos: String

@onready var fondo: TextureRect = $EscenaNV/Fondo
@onready var area_personajes = $EscenaNV/AreaPersonajes
@onready var area_izquierda: Control = area_personajes.get_node("Izquierda")
@onready var area_centro: Control = area_personajes.get_node("Centro")
@onready var area_derecha: Control = area_personajes.get_node("Derecha")

@onready var label_nombre = $"CuadroDiálogo/PanelNombre/LabelNombre"
@onready var label_texto = $"CuadroDiálogo/Texto"

# Agrega el grafico asociado a un personaje a la izquierda, centro o derecha
# del area de personajes.
# Si el personaje ya había sido agregado en ese lado, no hace nada
# Si el personaje ya había sido agregado en otro lado, lo cambia de lugar
func agregar_personaje(personaje: Personaje, pos: Posicion):
	var grafico: ModeloDialogo = personaje.modelo_dialogo
	
	# Si el personaje no tiene un gráfico de diálogo, en general porque no debe
	# aparecer en diálogos, o ya está en la posición, no se hace nada
	if not grafico or grafico.posicion == pos:
		return
	
	quitarPersonaje(personaje)
	personaje.call_deferred("remove_child", grafico)
	# TODO: agregar código para manejar transiciones
	match pos:
		Posicion.IZQUIERDA:
			area_izquierda.call_deferred("add_child", grafico)
			grafico.posicion = Posicion.IZQUIERDA
			grafico.mirar_derecha()
			grafico.show()
			var vector = Vector2(2 * area_izquierda.size.x / 3, area_izquierda.size.y)
			grafico.set_deferred("position", vector)
			
		Posicion.CENTRO:
			area_centro.call_deferred("add_child", grafico)
			grafico.posicion = Posicion.CENTRO
			grafico.mirar_derecha()
			grafico.show()
			var vector = Vector2(area_izquierda.size.x / 2, area_izquierda.size.y)
			grafico.set_deferred("position", vector)
			
		Posicion.DERECHA:
			area_derecha.call_deferred("add_child", grafico)
			grafico.posicion = Posicion.DERECHA
			grafico.mirar_izquierda()
			grafico.show()
			var vector = Vector2(area_izquierda.size.x / 3, area_izquierda.size.y)
			grafico.set_deferred("position", vector)

# Elimina el grafico asociado a un personaje, si es que ya está en el area de
# personajes
func quitarPersonaje(personaje: Personaje):
	var grafico: ModeloDialogo = personaje.modelo_dialogo
	if not grafico or grafico.posicion == -1:
		return
	
	grafico.hide()
	grafico.get_parent().call_deferred("remove_child", grafico)
	personaje.call_deferred("add_child", grafico)
	grafico.posicion = -1


func cambiar_fondo(imagen: String):
	if not imagen:
		fondo.hide()
	
	# Si el nombre de imagen no tiene extensión, asumimos que se desea un png
	if not imagen.get_extension():
		imagen = imagen + ".png"
	var ruta = "res://".path_join(ruta_fondos).path_join(imagen)
	fondo.texture = load(ruta)
	fondo.show()

func cambiar_dialogo(texto: String, nombre: String = ""):
	label_nombre.text = nombre
	label_texto.text = texto
