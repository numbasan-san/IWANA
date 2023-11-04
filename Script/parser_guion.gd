extends Node

@export var script_comandos: Script
@onready var todos_los_comandos = script_comandos.get_script_method_list().map(
	func (dict): return dict["name"]
)

var comandos: Array[Callable]

# Por ahora vamos a asumir que todo el guión está en un solo archivo. Más
# adelante hay que permitir escribirlo en varios, lo que significa que se pueden
# hacer referencias a elementos que no están definidos en el mismo archivo, por
# lo que habría que hacer una tabla donde guardar y buscar las referencias

# Mientras el juego esté en desarrollo, combiene leer los guiones
# de una carpeta junto al ejecutable, para que otros puedan editar el
# guión. Si corremos el juego desde el editor, podemos copiar esos guiónes
# en la carpeta de recursos
func _ready():
	var carpeta_guion: String
	# Se ejecuta el juego desde el ejecutable
	if OS.has_feature("debug") and not OS.has_feature("editor"):
		carpeta_guion = OS.get_executable_path().get_base_dir() + "/Guion"
	# Si no, se está ejecutando desde el editor
	else:
		carpeta_guion = "res://Guion"
	
	print("Carpeta guión: " + carpeta_guion)
	var dir = DirAccess.open(carpeta_guion)
	var archivos_guion = Array(dir.get_files())
	print("Archivos guión: " + str(archivos_guion))
	print("Lista de comandos: " + str(todos_los_comandos))
	for archivo in archivos_guion:
		parse(carpeta_guion.path_join(archivo))
	print("Ejecutando comandos")
	for com in comandos:
		com.call()

# Por ahora se usa FileAccess, porque asumimos que los archivos de texto se van
# a leer de la misma manera si es un arhcivo externo o está en el pck. Si ese no
# es el caso, hay que agregar una condición para verificar si el texto se lee
# desde afuera del ejecutable o desde el pck
func parse(nombre_archivo: String):
	var archivo = FileAccess.open(nombre_archivo, FileAccess.READ)
	var contenido = archivo.get_as_text(true)
	var lineas = contenido.split("\n", false)
	
	# La forma en que va a funcionar el parser es la siguiente:
	# 1 - Se toma una linea
	# 2 - Si la linea comienza con [ y termina con ], es un comando.
	# 3 - Si solo comienza con [ o solo termina con ], pero no ambos,
	# 		se asume que se quería escribir un comando pero la linea está mal
	#		escrita y se arroja un error.
	# 4 - Si no comienza con [ y no termina con ], es una línea de diálogo
	
	for linea in lineas:
		if linea.begins_with("[") and linea.ends_with("]"):
			extraer_comando(linea.trim_prefix("[").trim_suffix("]").strip_edges())
		elif not linea.begins_with("[") and not linea.ends_with("]"):
			extraer_dialogo(linea)
		else:
			generar_error(linea)
	
# Recibe una linea y extrae el comando a ejecutar y sus argumentos
func extraer_comando(linea: String):
	linea = linea.strip_edges()
	print("Linea a procesar: " + linea)
	# Si la linea comienza con # es un comentario y se ignora
	if linea.begins_with("#"):
		return
	# Se separa el nombre del comando de sus argumentos. Solo se permite un ':'
	var componentes = linea.split(":")
	assert(componentes.size() <= 2, "El comando debe ser de al forma <nombre>: <args>")
	# Como las funciones se escriben con minúscula, convertimos el nombre del comando
	var com = componentes[0].strip_edges().to_lower()
	var args = componentes[1].strip_edges()
	print("Comando: " + com)
	print("Argumentos: " + str(args))
	
	# El comando especificado en el guión tiene que estar definido en la lista
	# de comandos
	if todos_los_comandos.find(com) >= 0:
		# Separamos los argumentos en una lista
		var split_args = args.split(",")
		print("Despues de dividir argumentos: " + str(split_args))
		# Creamos un delegado para ejecutar el comando más tarde con los
		# argumentos entregados. Cada comando se encargará de verificar que
		# estos sean los adecuados
		comandos.append(Callable(script_comandos, com).bind(split_args))
	else:
		assert(false, "Comando " + com + " no encontrado")

# Recibe una linea y extrae una linea de diálogo y quien la dice, si aplica
func extraer_dialogo(linea: String):
	pass

# Recibe una linea mal formada y genera un comando que al ejecutarlo arroja un
# error
func generar_error(linea: String):
	pass
