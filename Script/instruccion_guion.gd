# Representa una instrucción que puede ser un comando, mostrar una linea
# de diálogo, o generar un error

class_name Instruccion

# Considerar si un comando que pausa la ejecución por un tiempo debe ser otro
# tipo que va acá, o si solo es una función que llama a una función de espera
# predefinida
enum { COMANDO, DIALOGO, ERROR }

# Script donde están definidas las funciones a ejecutar
static var script_comandos: Script  = load("res://Script/comandos_guion.gd")

# Nombres de los comandos definidos para verificar que la instrucción sea válida
static var lista_comandos = script_comandos.get_script_method_list().map(
	func (dict): return dict["name"]
)

var nombre: String

var argumentos: Array[String]

# Callable que se va a invocar al ejecutar la instrucción
var contenido: Callable

# Si esta instrucción es un comando o una linea de diálogo
var tipo: int

# Construye una nueva instrucción que puede ser ejecutada en el futuro. Si el
# nombre de la instrucción no está definido en la lista de comandos, se crea un
# comando especial que siempre imprime un error
func _init(nombre: String, args: Array[String]):
	self.nombre = nombre
	self.argumentos = args
	# Si no se encuentra una función con ese nombre, se reemplaza por un comando
	# que genera un error
	if nombre == "dialogo":
		tipo = DIALOGO
	else:
		tipo = COMANDO
	if lista_comandos.find(nombre) == -1:
		args = [nombre]
		nombre = "error"
		tipo = ERROR
	contenido = Callable(script_comandos, nombre).bind(args)


func ejecutar():
	contenido.call()
