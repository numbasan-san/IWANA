extends Node

# TODO: cambiar 

class_name Comandos

@onready var pantallas: Pantallas = $/root/Juego.pantallas
@onready var personajes: Personajes = $/root/Juego.personajes
@onready var contenidos_dialogo: ContenidosDialogo = pantallas.pantalla_dialogo.get_node("ContenidosDialogo")
@export var fondos: String

# Asigna una imagen de fondo a la escena
func fondo(nombre_imagen: String):
	#assert(nombre_imagen.size() == 1, "Número de argumentos incorrecto. Esperaba 1, recibió " + str(nombre_imagen))
	print("Cambiando fondo de la escena a " + nombre_imagen)
	contenidos_dialogo.cambiar_fondo(nombre_imagen)

# Cambia la imagen a uno o más personajes
func imagen(args: Array[String]):
	print("Cambiando imagenes de:")
	for par in args:
		var split = par.split("->")
		print(split[0].strip_edges() + " a " + split[1].strip_edges())
	
func derecha(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.DERECHA)

func centro(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.CENTRO)

func izquierda(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.IZQUIERDA)

func _colocar(nombre: String, posicion: ContenidosDialogo.Posicion):
	var personaje = personajes.cargar(nombre)
	if not personaje:
		error("No se encontró un personaje con el nombre " + nombre)
	else:
		contenidos_dialogo.agregar_personaje(personaje, posicion)
		print("Colocando " + nombre + " en " + str(posicion))

func dialogo(args: Array[String]):
	if args[0]:
		print(args[0] + ": " + args[1])
	else:
		print(args[1])
	contenidos_dialogo.cambiar_dialogo(args[1], args[0])

func abrir():
	print("Abriendo pantalla de dialogo")
	await pantallas.push(pantallas.pantalla_dialogo)

# TODO: cambiar esto para que pueda pasar a cualquier pantalla, no solo mundo.
# Quizas cuando se cambie el sistema de transiciones
func cerrar():
	print("Cerrando pantalla de dialogo")
	await pantallas.pop(pantallas.pantalla_dialogo)

func error(mensaje: String):
	printerr(mensaje)
