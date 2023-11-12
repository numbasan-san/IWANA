extends Control

class_name ContenidosDialogo

enum Posicion { IZQUIERDA, CENTRO, DERECHA, NINGUNA = -1 }

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
	
	# Si llegamos acá entonces hay que sacar al personaje de algún area. Despues
	# de llamar a esta función, el modelo va a estar fuera de la pantalla y
	# de vuelta con su personaje
	quitar_personaje(personaje)
	personaje.call_deferred("remove_child", grafico)
	# TODO: agregar código para manejar transiciones
	var area_objetivo = Control
	var posicion_objetivo: Posicion
	match pos:
		Posicion.IZQUIERDA:
			area_objetivo = area_izquierda
			posicion_objetivo = Posicion.IZQUIERDA
			grafico.mirar_derecha()
		Posicion.CENTRO:
			area_objetivo = area_centro
			posicion_objetivo = Posicion.CENTRO
			grafico.mirar_derecha()
		Posicion.DERECHA:
			area_objetivo = area_derecha
			posicion_objetivo = Posicion.DERECHA
			grafico.mirar_izquierda()
	
	area_objetivo.call_deferred("add_child", grafico)
	grafico.posicion = posicion_objetivo
	grafico.show()
	call_deferred("_reordenar", area_objetivo)

# Elimina el grafico asociado a un personaje, si es que ya está en el area de
# personajes
func quitar_personaje(personaje: Personaje):
	var grafico: ModeloDialogo = personaje.modelo_dialogo
	if not grafico or grafico.posicion == Posicion.NINGUNA:
		return
	var area: Control
	match grafico.posicion:
		Posicion.IZQUIERDA:
			area = area_izquierda
		Posicion.CENTRO:
			area = area_centro
		Posicion.DERECHA:
			area = area_derecha
	grafico.hide()
	grafico.get_parent().call_deferred("remove_child", grafico)
	call_deferred("_reordenar", area)
	personaje.call_deferred("add_child", grafico)
	grafico.posicion = Posicion.NINGUNA


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
	
func cambiar_imagen(personaje: Personaje, imagen_objetivo: String):
	personaje.modelo_dialogo.cambiar_imagen(imagen_objetivo)

# Cambia la posición de los personajes en el area de la pantalla dependiendo de
# cuantos hay. Los personajes ya deben haberse agregado o quitado antes de
# llamar a esta función
func _reordenar(area: Control):
	# Vamos a mostrar a los personajes centrados en el area correspondiente,
	# dejando los extremos izquierdo y derecho libres
	var tamaño = area.get_child_count() + 2
	var i = 1
	while i < tamaño - 1:
		var vector = Vector2(i * area.size.x / tamaño, area.size.y)
		area.get_child(i - 1).position = vector
		i += 1
