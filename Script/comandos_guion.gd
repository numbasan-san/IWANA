class_name Comandos

# Crea una escena con el nombre especificado
static func unidad(nombre: Array[String]):
	assert(nombre.size() == 1, "Número de argumentos incorrecto. Esperaba 1, recibió " + str(nombre))
	print("Creando unidad con nombre " + nombre[0])

# Asigna una imagen de fondo a la escena
static func fondo(nombre_imagen: Array[String]):
	assert(nombre_imagen.size() == 1, "Número de argumentos incorrecto. Esperaba 1, recibió " + str(nombre_imagen))
	print("Cambiando fondo de la escena a " + nombre_imagen[0])

# Cambia la imagen a uno o más personajes
static func imagen(args: Array[String]):
	print("Cambiando imagenes de:")
	for par in args:
		var split = par.split("->")
		print(split[0].strip_edges() + " a " + split[1].strip_edges())
	
static func derecha(args: Array[String]):
	print("Colocando a la derecha: " + str(args))

static func dialogo(args: Array[String]):
	if args[0]:
		print(args[0] + ": " + args[1])
	else:
		print(args[1])

static func error(nombre_erroneo: String):
	print("No se encontró un comando con el nombre '" + nombre_erroneo + "'")
