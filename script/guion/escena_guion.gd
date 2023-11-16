class_name Escena

# Una escena contiene un conjunto de unidades del guión que se ejecutan 
# siguiendo una secuencia. 

# El nombre asignado a esta escena. Se puede usar para referenciarla desde el 
# resto del juego
var nombre: String

# Las unidades que pertenecen a esta escena. Cada entrada es un 
# par (nombre, unidad)
var unidades: Dictionary

# Las conecciones entre unidades que determinan en que orden se deben ejecutar.
# Cada entrada es un par (nombre_inicial, nombre_siguiente), donde
# nombre_siguiente es el nombre de la unidad que debe ejecutarse despues de que
# termine de ejecutarse nombre_inicial
var conexiones: Dictionary

# El nombre de la primera unidad que se debe ejecutar de esta escena
var nombre_primera: String

# La instrucción que se está ejecutando en este momento
var unidad_actual: Unidad

# Las unidad solo se van a ejecutar cuando este valor sea true.
# Se puede usar para pausar la ejecución de la escena cuando ocurre algún evento.
var en_ejecucion = false

# Es true si la escena ya completó todas sus unidades durante esta ejecución
var listo

# Crea una nueva escena con una lista de unidades a ejecutar
func _init(_nombre: String, _inicial: String, _unidades: Array[Unidad]):
	self.nombre = _nombre
	self.unidades = {}
	self.nombre_primera = _inicial
	for unidad in _unidades:
		agregar(unidad)
	reiniciar()

func procesar():
	if en_ejecucion and not listo:
		unidad_actual.procesar()
		if unidad_actual.listo:
			if conexiones.has(unidad_actual.nombre):
				var nombre_siguiente = conexiones[unidad_actual.nombre]
				unidad_actual = unidades[nombre_siguiente]
				unidad_actual.reiniciar()
			else:
				unidad_actual = null
				listo = true

func reiniciar():
	for unidad in unidades.values():
		unidad.reiniciar()
	cargar(nombre_primera)

func cargar(nombre: String):
	if unidades.has(nombre):
		unidad_actual = unidades[nombre]
		unidad_actual.pausar(false)
		en_ejecucion = true
	else:
		printerr("No se encontró una unidad con nombre " + nombre)

func agregar(unidad: Unidad):
	if not unidades.has(unidad.nombre):
		unidades[unidad.nombre] = unidad
	else:
		printerr("La escena ya contiene una unidad con el nombre " + unidad.nombre)

func enlazar(fuente: String, destino: String):
	if not unidades.has(fuente):
		printerr("La escena no contiene a la unidad " + fuente)
	elif not unidades.has(destino):
		printerr("La escena no contiene a la unidad " + destino)
	else:
		conexiones[fuente] = destino
		

func pausar(pausa = true):
	en_ejecucion = not pausa
	unidad_actual.pausar(pausa)
