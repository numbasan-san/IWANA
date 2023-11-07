extends Node

@export var script_comandos: Script
@onready var todos_los_comandos = script_comandos.get_script_method_list().map(
	func (dict): return dict["name"]
)

var unidades: Dictionary

# Separa el guion en unidades. 
static var regex_unidad = RegEx.new()

# Por ahora vamos a asumir que todo el guión está en un solo archivo. Más
# adelante hay que permitir escribirlo en varios, lo que significa que se pueden
# hacer referencias a elementos que no están definidos en el mismo archivo, por
# lo que habría que hacer una tabla donde guardar y buscar las referencias

# Mientras el juego esté en desarrollo, combiene leer los guiones
# de una carpeta junto al ejecutable, para que otros puedan editar el
# guión. Si corremos el juego desde el editor, podemos copiar esos guiónes
# en la carpeta de recursos
func _ready():
	# Separa el guion en unidades. Para que esto funcione todas las instrucciones
	# tienen que estar escritas dentro de una unidad, y cada unidad debe tener una
	# etiqueta inicial [Unidad: nombre] y una final [Fin: nombre] o [Fin: Unidad]
	# Más adelante debe extenderse para poder aceptar escenas que contengan varias
	# unidades, episodios que contengan varias escenas, etc.
	regex_unidad.compile("\\[Unidad:(?: |\\t)*(?<nombre>.+)\\]\\n(?<contenido>(?:.*\\n)*?)\\[Fin:(?: |\\t)*(?:\\k<nombre>|(?:U|u)nidad)\\]")
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
		parse_archivo(carpeta_guion.path_join(archivo))
	print("Ejecutando comandos")
	print("Unidades creadas: " + str(unidades))
	for unidad in unidades:
		unidades[unidad].pausar(false)

# Por ahora ejecuta todas las unidades intercaladas. Cambiar para que tenga que
# terminar una antes de pasar a la siguiente
func _process(_delta):
	for unidad in unidades:
		unidades[unidad].procesar()

# Por ahora se usa FileAccess, porque asumimos que los archivos de texto se van
# a leer de la misma manera si es un archivo externo o está en el pck. Si ese no
# es el caso, hay que agregar una condición para verificar si el texto se lee
# desde afuera del ejecutable o desde el pck
func parse_archivo(nombre_archivo: String):
	var archivo = FileAccess.open(nombre_archivo, FileAccess.READ)
	var contenido = archivo.get_as_text(true)
	
	for m in regex_unidad.search_all(contenido):
		var nombre = m.get_string("nombre")
		var contenidos = m.get_string("contenido").split("\n", false)
		var unidad = crear_unidad(nombre, contenidos)
		unidades[nombre] = unidad
	
	#var cl = Unidad
	#var ins = cl.new([])
	#print("¿Qué es esto? " + str(cl) + " | " + str(ins))
	

func crear_unidad(nombre: String, lineas: Array[String]) -> Unidad:
	print("Creando unidad con nombre " + nombre)
	
	# La forma en que va a funcionar el parser es la siguiente:
	# 1 - Se toma una linea
	# 2 - Si la linea comienza con [ y termina con ], es un comando.
	# 3 - Si solo comienza con [ o solo termina con ], pero no ambos,
	# 		se asume que se quería escribir un comando pero la linea está mal
	#		escrita y se arroja un error.
	# 4 - Si no comienza con [ y no termina con ], es una línea de diálogo
	
	var instrucciones: Array[Instruccion] = []
	
	for linea in lineas:
		print("Linea a procesar: " + linea)
		var instruccion: Instruccion
		if linea.begins_with("[") and linea.ends_with("]"):
			instruccion = extraer_comando(linea.trim_prefix("[").trim_suffix("]").strip_edges())
		elif not linea.begins_with("[") and not linea.ends_with("]"):
			instruccion = extraer_dialogo(linea.strip_edges())
		else:
			generar_error(linea)
		if instruccion:
			instrucciones.append(instruccion)
	
	return Unidad.new(nombre, instrucciones)
	

# Recibe una linea y extrae el comando a ejecutar y sus argumentos
func extraer_comando(linea: String) -> Instruccion:
	# Si la linea comienza con # es un comentario y se ignora
	if linea.begins_with("#"):
		return
	# Se separa el nombre del comando de sus argumentos. Solo se permite un ':'
	var componentes = linea.split(":")
	assert(componentes.size() <= 2, "El comando debe ser de al forma <nombre>: <args>")
	# Como las funciones se escriben con minúscula, convertimos el nombre del comando
	var nombre = componentes[0].strip_edges().to_lower()
	var args = componentes[1].strip_edges()
	print("Comando: " + nombre)
	print("Argumentos: " + args)
	
	# El comando especificado en el guión tiene que estar definido en la lista
	# de comandos
	if todos_los_comandos.find(nombre) >= 0:
		# Separamos los argumentos en una lista
		var split_args: Array[String]
		split_args.append_array(args.split(","))
		print("Despues de dividir argumentos: " + str(split_args))
		# Creamos un delegado para ejecutar el comando más tarde con los
		# argumentos entregados. Cada comando se encargará de verificar que
		# estos sean los adecuados
		return Instruccion.new(nombre, split_args)
	else:
		assert(false, "Comando " + nombre + " no encontrado")
		return

# Recibe una linea y extrae una linea de diálogo y quien la dice, si aplica
func extraer_dialogo(linea: String):
	# Se separa el nombre del personaje de lo que dice. Solo se permite un ':'
	var componentes = linea.split(":")
	assert(componentes.size() <= 2, "La linea debe ser de al forma <nombre>: <texto> o <texto>")
	var nombre = ""
	var texto = ""
	
	if componentes.size() == 1:
		texto = componentes[0].strip_edges()
	else:
		nombre = componentes[0].strip_edges()
		texto = componentes[1].strip_edges()
	return Instruccion.new("dialogo", [nombre, texto])

# Recibe una linea mal formada y genera un comando que al ejecutarlo arroja un
# error
func generar_error(linea: String):
	print("La linea '" + linea + "' está mal escrita y no se puede reconocer como un comando o una linea de diálogo")
