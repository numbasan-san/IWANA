extends Node

# TODO: cambiar 

class_name Comandos

@onready var controladorPantallas = $"../ControladorPantallas"
@onready var contenidosDialogo = controladorPantallas.pantallaDialogo.get_node("ContenidosDialogo")
@export var fondos: String

# Asigna una imagen de fondo a la escena
func fondo(nombre_imagen: Array[String]):
	assert(nombre_imagen.size() == 1, "Número de argumentos incorrecto. Esperaba 1, recibió " + str(nombre_imagen))
	print("Cambiando fondo de la escena a " + nombre_imagen[0])
	contenidosDialogo.cambiar_fondo(nombre_imagen[0])

# Cambia la imagen a uno o más personajes
func imagen(args: Array[String]):
	print("Cambiando imagenes de:")
	for par in args:
		var split = par.split("->")
		print(split[0].strip_edges() + " a " + split[1].strip_edges())
	
func derecha(args: Array[String]):
	print("Colocando a la derecha: " + str(args))

func dialogo(args: Array[String]):
	if args[0]:
		print(args[0] + ": " + args[1])
	else:
		print(args[1])
	contenidosDialogo.cambiar_dialogo(args[1], args[0])

func abrir():
	print("Abriendo pantalla de dialogo")
	controladorPantallas.transicion(controladorPantallas.pantallaDialogo)

# TODO: cambiar esto para que pueda pasar a cualquier pantalla, no solo mundo.
# Quizas cuando se cambie el sistema de transiciones
func cerrar():
	print("Cerrando pantalla de dialogo")
	controladorPantallas.transicion(controladorPantallas.pantallaMundo)

func error(nombre_erroneo: Array[String]):
	print("No se encontró un comando con el nombre '" + nombre_erroneo[0] + "'")
