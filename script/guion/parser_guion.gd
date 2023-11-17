class_name ParserGuion extends Node

var script_comandos: Comandos
var comandos: Dictionary = {}

var carpeta_guion: String

@export var controlador_guion: ControladorGuion

# Separa el guion en unidades. Para que esto funcione todas las instrucciones
# tienen que estar escritas dentro de una unidad, y cada unidad debe tener una
# etiqueta inicial [Unidad: nombre] y una final [Fin: nombre] o [Fin: Unidad]
# Una unidad puede pertenecer a una escena o ninguna. Unidades que pertenecen a
# una escena solo pueden ser accedidas o enlazadas dentro de la misma escena.
# Unidades que no pertenecen a una escena pueden ser accedidas o enlazadas desde
# cualquier lugar
static var matcher_unidad = RegEx.new()
static var regex_unidad = "\\s*\\[(?:U|u)nidad:(?: |\\t)*(?<nombre>.+)\\]\\n(?<contenido>(?:.*\\n)*?)\\[Fin:(?: |\\t)*(?:\\k<nombre>|(?:U|u)nidad)\\]"

# Separa el guión en escenas. Cada escena debe tener una etiqueta inicial
# [Escena: nombre] y una final [Fin: nombre] o [Fin: Escena]
static var matcher_escena = RegEx.new()
static var regex_escena = "\\s*\\[(?:E|e)scena:(?: |\\t)*(?<nombre>.+)\\]\\n(?<contenido>(?:.*\\n)*?)\\[Fin:(?: |\\t)*(?:\\k<nombre>|(?:E|e)scena)\\]"

# Extrae la primera unidad que se debe ejecutar al iniciar la escena
static var matcher_inicial = RegEx.new()
static var regex_inicial = "\\s*\\[(?:I|i)nicial:(?: |\\t)*(?<nombre>(?:.*)*?)\\]"

# Extrae las listas de enlaces entre unidades
static var matcher_enlaces = RegEx.new()
static var regex_enlaces = "\\s*\\[(?:E|e)nlaces:(?: |\\t)*(?<contenido>(?:.*)*?)\\]"

# Por ahora vamos a asumir que todo el guión está en un solo archivo. Más
# adelante hay que permitir escribirlo en varios, lo que significa que se pueden
# hacer referencias a elementos que no están definidos en el mismo archivo, por
# lo que habría que hacer una tabla donde guardar y buscar las referencias

# Mientras el juego esté en desarrollo, combiene leer los guiones
# de una carpeta junto al ejecutable, para que otros puedan editar el
# guión. Si corremos el juego desde el editor, podemos copiar esos guiónes
# en la carpeta de recursos
func _ready():
	script_comandos = $"../Comandos"
	for dict in script_comandos.get_script().get_script_method_list():
		if dict["args"].size() > 0:
			comandos[dict["name"]] = dict["args"][0]["type"]
		else:
			comandos[dict["name"]] = 0
	
	# Separa el guion en unidades. Para que esto funcione todas las instrucciones
	# tienen que estar escritas dentro de una unidad, y cada unidad debe tener una
	# etiqueta inicial [Unidad: nombre] y una final [Fin: nombre] o [Fin: Unidad]
	# Más adelante debe extenderse para poder aceptar escenas que contengan varias
	# unidades, episodios que contengan varias escenas, etc.
	matcher_unidad.compile(regex_unidad)
	matcher_escena.compile(regex_escena)
	matcher_inicial.compile(regex_inicial)
	matcher_enlaces.compile(regex_enlaces)
	# Se ejecuta el juego desde el ejecutable
	if OS.has_feature("debug") and not OS.has_feature("editor"):
		carpeta_guion = OS.get_executable_path().get_base_dir() + "/Guion"
	# Si no, se está ejecutando desde el editor
	else:
		carpeta_guion = "res://Guion"
	
	print("Carpeta guión: " + carpeta_guion)
	print("Lista de comandos: " + str(comandos))
	parse_all()
	

func parse_all():
	# Primero se borra el controlador por si ya se habían cargado escenas
	# previamente. Debe llamarse a la función reiniciar cuando se desee iniciar
	# la ejecución del controlador para que funcione correctamente
	controlador_guion.borrar()
	var dir = DirAccess.open(carpeta_guion)
	var archivos_guion = Array(dir.get_files())
	print("Archivos guión: " + str(archivos_guion))
	for archivo in archivos_guion:
		parse_archivo(carpeta_guion.path_join(archivo))
	

# Por ahora se usa FileAccess, porque asumimos que los archivos de texto se van
# a leer de la misma manera si es un archivo externo o está en el pck. Si ese no
# es el caso, hay que agregar una condición para verificar si el texto se lee
# desde afuera del ejecutable o desde el pck
func parse_archivo(nombre_archivo: String):
	var archivo = FileAccess.open(nombre_archivo, FileAccess.READ)
	var contenido = archivo.get_as_text(true)
	
	var matches = matcher_escena.search_all(contenido)
	if matches.size() == 0:
		printerr("No se encontraron escenas en el guión de nombre " + nombre_archivo)
	for m in matches:
		var nombre = m.get_string("nombre")
		var escena = crear_escena(nombre, m.get_string("contenido"))
		controlador_guion.agregar(escena)
	
func crear_escena(nombre_escena: String, contenido_escena: String) -> Escena:
	print("Creando escena con nombre " + nombre_escena)
	var unidades: Array[Unidad] = []
	var matches_unidades = matcher_unidad.search_all(contenido_escena)
	if matches_unidades.size() == 0:
		printerr("No se encontraron unidades en esta escena")
	for m in matches_unidades:
		var nombre_unidad = m.get_string("nombre")
		var contenidos = m.get_string("contenido").split("\n", false)
		unidades.append(crear_unidad(nombre_unidad, contenidos))
	
	var matches_inicial = matcher_inicial.search_all(contenido_escena)
	var inicial
	if matches_inicial.size() != 1:
		printerr("Debe haber exactamente 1 unidad inicial")
	else:
		inicial = matches_inicial[0].get_string("nombre")
		
	var escena = Escena.new(nombre_escena, inicial, unidades)
	
	var matches_enlaces = matcher_enlaces.search_all(contenido_escena)
	if matches_inicial.size() == 0:
		printerr("No se encontraron enlaces")
	for m in matches_enlaces:
		var split = m.get_string("contenido").split("->", false)
		var array = Array(split).map(func(s): return s.strip_edges())
		if array.size() > 1:
			var i = 1
			while i < array.size():
				escena.enlazar(array[i - 1], array[i])
				i += 1
	return escena

func crear_unidad(nombre_unidad: String, lineas: Array[String]) -> Unidad:
	print("Creando unidad con nombre " + nombre_unidad)
	
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
		if linea.begins_with("[") and linea.ends_with("]"):
			instrucciones.append(extraer_comando(linea.trim_prefix("[").trim_suffix("]").strip_edges()))
		elif not linea.begins_with("[") and not linea.ends_with("]"):
			instrucciones.append(extraer_dialogo(linea.strip_edges()))
			instrucciones.append(Instruccion.new(script_comandos, "esperar"))
		else:
			instrucciones.append(Instruccion.new(script_comandos, "error", "La instrucción estaba mal escrita.\n Linea: " + linea))
		
	return Unidad.new(nombre_unidad, instrucciones)
	

# Recibe una linea y extrae el comando a ejecutar y sus argumentos
func extraer_comando(linea: String) -> Instruccion:
	# Si la linea comienza con # es un comentario y se ignora
	if linea.begins_with("#"):
		return
	# Se separa el nombre del comando de sus argumentos. Solo se permite un ':'
	var componentes = linea.split(":")
	assert(componentes.size() <= 2, "El comando debe ser de la forma <nombre>: <args>")
	# Como las funciones se escriben con minúscula, convertimos el nombre del comando
	var nombre = componentes[0].strip_edges().to_snake_case()
	
	# Todo el codigo a continuacion está feo porque args puede ser null
	# o array de strings, y hay muchos ifs. Ver si se puede arreglar. Hay que
	# obtener la información de los argumentos que reciben las funciones para
	# saber como convertir los argumentos recibidos del guión
	var args = null
	if componentes.size() > 1:
		args = componentes[1].strip_edges()
	print("Comando: " + nombre)
	print("Argumentos: " + str(args))
	
	# El comando especificado en el guión tiene que estar definido en la lista
	# de comandos
	if comandos.keys().find(nombre) >= 0:
		# Este es el caso para los comandos que no reciben parámetros
		if comandos[nombre] == Variant.Type.TYPE_NIL:
			if args == null:
				return Instruccion.new(script_comandos, nombre)
			else:
				return Instruccion.new(script_comandos, "error", "El comando " + nombre + " no debe recibir parámetros, pero recibió " + args)
		# Desde este punto los comandos deben recibir parámetros. Si no, es
		# un error
		if args == null:
			return Instruccion.new(script_comandos, "error", "El comando " + nombre + " debe recibir parámetros")
		# Separamos los argumentos en una lista
		var split_args = args.split(",")
		# Este es el caso para los comandos que solo reciben un parámetro
		if comandos[nombre] == Variant.Type.TYPE_STRING:
			if split_args.size() == 1:
				return Instruccion.new(script_comandos, nombre, split_args[0] as String)
			else:
				return Instruccion.new(script_comandos, "error", "El comando " + nombre + " debe recibir un parámetro de tipo String, pero recibió " + split_args)
		# Finalmente, este es el caso para los comandos que reciben varios parámetros
		var temp: Array[String] = []
		for string in split_args:
			temp.append(string.strip_edges())
		# Creamos un delegado para ejecutar el comando más tarde con los
		# argumentos entregados. Cada comando se encargará de verificar que
		# estos sean los adecuados
		return Instruccion.new(script_comandos, nombre, temp)
	else:
		return Instruccion.new(script_comandos, "error", "No existe un comando con el nombre: " + nombre)

# Recibe una linea y extrae una linea de diálogo y quien la dice, si aplica
func extraer_dialogo(linea: String):
	# Se separa el nombre del personaje de lo que dice. Solo se permite un ':'
	var componentes = linea.split(":")
	assert(componentes.size() <= 2, "La linea debe ser de la forma <nombre>: <texto> o <texto>")
	var nombre = ""
	var texto = ""
	
	if componentes.size() == 1:
		texto = componentes[0].strip_edges()
	else:
		nombre = componentes[0].strip_edges()
		texto = componentes[1].strip_edges()
	return Instruccion.new(script_comandos, "dialogo", [nombre, texto] as Array[String])
