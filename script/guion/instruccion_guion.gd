# Representa una instrucción que puede ser un comando, mostrar una linea
# de diálogo, o generar un error

class_name Instruccion

# Considerar si un comando que pausa la ejecución por un tiempo debe ser otro
# tipo que va acá, o si solo es una función que llama a una función de espera
# predefinida
enum { COMANDO, DIALOGO, ERROR }

var nombre: String

var argumentos: Variant

# Callable que se va a invocar al ejecutar la instrucción
var contenido: Callable

# Si esta instrucción es un comando o una linea de diálogo
var tipo: int

# Construye una nueva instrucción que puede ser ejecutada en el futuro. Si el
# nombre de la instrucción no está definido en la lista de comandos, se crea un
# comando especial que siempre imprime un error
func _init(comandos: Comandos, nombre: String, args: Variant = null):
	self.nombre = nombre
	self.argumentos = args
	
	if nombre == "dialogo":
		tipo = DIALOGO
	elif nombre == "error":
		tipo = ERROR
	else:
		tipo = COMANDO
	
	if args == null:
		contenido = Callable(comandos, nombre)
	else:
		contenido = Callable(comandos, nombre).bind(args)


func ejecutar():
	print("Ejecutando comando " + nombre + " con argumentos " + str(argumentos))
	contenido.call()