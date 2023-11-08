extends CanvasLayer

class_name Pantalla

var activa = false

func activar():
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	set_process_input(true)
	activa = true
	
func desactivar():
	activa = false
	set_process_input(false)
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

func pausar(valor: bool = true):
	activa = not valor
