extends Node

@onready var pantallas: Pantallas = $/root/Juego.pantallas
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
		var nombre = split[0].strip_edges()
		var personaje = CharacterManager.load(nombre)
		if not personaje:
			error("No se encontró un personaje con el nombre " + nombre)
			continue
		var imagen = split[1].strip_edges()
		print(nombre + " a " + imagen)
		contenidos_dialogo.cambiar_imagen(personaje, imagen)
	
func derecha(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.DERECHA)

func centro(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.CENTRO)

func izquierda(args: Array[String]):
	for nombre in args:
		_colocar(nombre, ContenidosDialogo.Posicion.IZQUIERDA)

func quitar(args: Array[String]):
	for nombre in args:
		var personaje = CharacterManager.load(nombre)
		contenidos_dialogo.quitar_personaje(personaje)

func quitar_todos():
	contenidos_dialogo.quitar_todos()

func _colocar(nombre: String, posicion: ContenidosDialogo.Posicion):
	var personaje = CharacterManager.load(nombre)
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

# Esta instrucción no hace nada por si misma, pero el control de unidades la usa
# como una marca para saber cuando detener la ejecución y esperar el input del
# usuario
func esperar():
	pass

func abrir():
	print("Abriendo pantalla de dialogo")
	if pantallas.pantalla_actual != pantallas.pantalla_dialogo:
		await pantallas.push(pantallas.pantalla_dialogo)

# TODO: cambiar esto para que pueda pasar a cualquier pantalla, no solo mundo.
# Quizas cuando se cambie el sistema de transiciones
func cerrar():
	print("Cerrando pantalla de dialogo")
	if pantallas.pantalla_actual == pantallas.pantalla_dialogo:
		await pantallas.pop(pantallas.pantalla_dialogo)

func error(mensaje: String):
	printerr(mensaje)
