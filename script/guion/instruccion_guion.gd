# Representa una instrucción que puede ser un comando, mostrar una linea
# de diálogo, o generar un error

class_name Instruccion

# Considerar si un comando que pausa la ejecución por un tiempo debe ser otro
# tipo que va acá, o si solo es una función que llama a una función de espera
# predefinida
enum { COMANDO, DIALOGO, ERROR, ESPERA }

# El nombre de la instrucción, usada para propósitos de debugging
var nombre: String

# Los argumentos que se van a aplicar a esta instrucción, usada para propósitos
# de debugging
var argumentos: Variant

# Callable que se va a invocar al ejecutar la instrucción
var contenido: Callable

# Si esta instrucción es un comando o una linea de diálogo
var tipo: int

# Construye una nueva instrucción que puede ser ejecutada en el futuro. Si el
# nombre de la instrucción no está definido en la lista de comandos, se crea un
# comando especial que siempre imprime un error
func _init(comandos: Comandos, _nombre: String, args: Variant = null):
	self.nombre = _nombre
	self.argumentos = args
	
	if nombre == "dialogo":
		tipo = DIALOGO
	elif nombre == "error":
		tipo = ERROR
	elif nombre == "esperar":
		tipo = ESPERA
	else:
		tipo = COMANDO
	
	if args == null:
		contenido = Callable(comandos, nombre)
	else:
		contenido = Callable(comandos, nombre).bind(args)


func ejecutar():
	print("Ejecutando comando " + nombre + " con argumentos " + str(argumentos))
	contenido.call()
