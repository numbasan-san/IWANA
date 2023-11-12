extends CanvasLayer

class_name Pantalla

@export var contenidos: Node

# Las transiciones que tenga esta pantalla o null si no tiene. Lo usa el
# controlador de pantallas para activar las transiciones cuando muestra y
# esconde las distintas pantallas
@export var transiciones: AnimationPlayer

var activa = false

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
