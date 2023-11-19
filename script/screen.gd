class_name Screen
extends CanvasLayer

@export var contenidos: Node

# Las transiciones que tenga esta pantalla o null si no tiene. Lo usa el
# controlador de pantallas para activar las transiciones cuando muestra y
# esconde las distintas pantallas
@export var transiciones: AnimationPlayer

var activa = false

# A veces ocurre un error cuando se solicita un pop en una función _process,
# mientras se espera a que termine la animación, _process vuelve a ejecutarse,
# posiblemente en otro thread, y llama varias veces a la función pop, cada una
# pasando como parámetro la misma pantalla, y todas esas ejecuciones se encolan.
# Entonces a medida que todas las funciones terminan de esperar, eliminan la
# pantalla del tope de la pila en secuencia, lo que hace que se vacíe.
# Esta variable debe ser true despues que se llama a pop de esta pantalla por
# primera vez y volver a hacerse false cuando termine de eliminarse. Entonces
# el controlador de pantallas puede revisar si ya está en proceso de removerse e
# ignorar otras peticiones
var pop_solicitado = false
var push_solicitado = false

# Activa los procesos de los contenidos de esta pantalla y la muestra
func activar():
	show()
	contenidos.process_mode = Node.PROCESS_MODE_INHERIT
	set_process_input(true)
	activa = true

# Desactiva los procesos de los contenidos de esta pantalla. De esta manera, si
# hay una animación registrada puede reproducirse aunque la pantalla esté
# desactivada. El argumento visible determina si la pantalla seguirá siendo 
# visible o se esconde. Esto es útil cuando se quiere dibujar un overlay sobre
# la pantalla mientras está pausada, por ejemplo el menú de pausa
func desactivar(_visible: bool = false):
	activa = false
	set_process_input(false)
	contenidos.process_mode = Node.PROCESS_MODE_DISABLED
	if _visible:
		show()
	else:
		hide()

func pausar(valor: bool = true):
	activa = not valor
