extends Node

class_name Unidad

# Una unidad corresponde a un conjunto de instrucciones del guión que se
# ejecutan en secuencia. Si una instrucción es un comando, se ejecuta y se
# continúa inmediatamente con la siguiente. Si la instrucción es una linea de
# diálogo, se muestra en pantalla y se espera al input del jugador antes de
# continuar

# El nombre asignado a esta unidad. Se puede usar para referenciarla desde otras
# unidades o desde el resto del juego
var nombre: String

# La lista de instrucciones a ejecutar
var instrucciones: Array[Instruccion]

# La instrucción que se ejecutará a continuación
var actual: int

# La linea de diálogo que se mostrará a continuación
var linea_actual: int

# Las instrucciones solo se van a ejecutar cuando este valor sea true.
# Se puede usar para pausar la ejecución de la unidad cuando ocurre algún evento.
var en_ejecucion = false

# Es true si la unidad ya completó todas sus instrucciones durante esta ejecución
var listo

# Detecta cuando el usuario presiona un botón para avanzar el diálogo. No debe
# tener efecto cuando se está ejecutando otro tipo de instrucción
# TODO: arreglar esto para que los diálogos se demoren un poco en imprimir sus
# contenidos, y presionar el botón de avanzar diálogo solo lo apura y no pasa al
# diálogo siguiente
func _input(event):
	if event.is_action_pressed("nv_avanzar_dialogo") and instrucciones[actual].tipo == Instruccion.DIALOGO:
		pausar(false)

# Crea una nueva unidad con una lista de comandos a ejecutar
func _init(nombre: String, instrucciones: Array[Instruccion]):
	self.nombre = nombre
	self.instrucciones = instrucciones
	reiniciar()

# Ejecuta las instrucciones en secuencia. Hay que pensar en que hacer cuando la
# instrucción pide esperar por un tiempo, ver si usar la  función wait detiene
# todo el juego, el script que contiene las funciones, o esta función
# process
func procesar():
	if en_ejecucion and not listo:
		instrucciones[actual].ejecutar()
		# Si la instrucción cambia el diálogo, sumamos 1 a linea_actual para que
		# en el modo dev se pueda mostrar en que linea de la unidad se encuentra
		# y se detiene la ejecución hasta que el usuario pida una nueva linea
		# TODO: cambiar para que se tome un tiempo en mostrar el diálogo. Quizas
		# se debe agregar una función de espera cada vez que se muestre diálogo,
		# y el usuario puede interrumpirla con un input
		if instrucciones[actual].tipo == Instruccion.DIALOGO:
			linea_actual += 1
			pausar()
		actual += 1
		if actual >= instrucciones.size():
			listo = true

func reiniciar():
	actual = 0
	linea_actual = 0
	listo = instrucciones.size() == 0

func pausar(pausa = true):
	en_ejecucion = not pausa
