class_name Unidad

# Una unidad corresponde a un conjunto de instrucciones del guión que se
# ejecutan en secuencia. Las instrucciones se ejecutan inmediatamente una 
# despues de la otra, excepto por la instrucción "esperar" que pausa la
# ejecución de la unidad hasta que el usuario presiona la tecla de continuar

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

# Crea una nueva unidad con una lista de comandos a ejecutar
func _init(_nombre: String, _instrucciones: Array[Instruccion]):
	self.nombre = _nombre
	self.instrucciones = _instrucciones
	reiniciar()

# Ejecuta las instrucciones en secuencia. Hay que pensar en que hacer cuando la
# instrucción pide esperar por un tiempo, ver si usar la  función wait detiene
# todo el juego, el script que contiene las funciones, o esta función
# process
func procesar():
	if en_ejecucion and not listo:
		# Este chequeo se coloca acá para cuando la última instrucción de la
		# unidad es de espera, así uno debe despausar la ejecución con la tecla
		# de avanzar diálogo antes que la variable listo se haga true y se
		# continúe con la siguiente unidad
		if actual >= instrucciones.size():
			listo = true
			return
		instrucciones[actual].ejecutar()
		# Si la instrucción cambia el diálogo, sumamos 1 a linea_actual para que
		# en el modo dev se pueda mostrar en que linea de la unidad se encuentra
		# y se detiene la ejecución hasta que el usuario pida una nueva linea
		# TODO: cambiar para que se tome un tiempo en mostrar el diálogo. Quizas
		# se debe agregar una función de espera cada vez que se muestre diálogo,
		# y el usuario puede interrumpirla con un input
		if instrucciones[actual].tipo == Instruccion.DIALOGO:
			linea_actual += 1
		if instrucciones[actual].tipo == Instruccion.ESPERA:	
			pausar()
		actual += 1
		

func reiniciar():
	actual = 0
	linea_actual = 0
	listo = instrucciones.size() == 0
	pausar(false)

func pausar(pausa = true):
	en_ejecucion = not pausa
