extends Node

class_name ControladorGuion

signal continuar

var escenas: Dictionary
var puntero_escena: int = 0
var escena_actual: Escena

var en_ejecucion: bool = false

func _process(_delta):
	if en_ejecucion:
		if puntero_escena >= escenas.size():
			en_ejecucion = false
		else:
			escena_actual.procesar()
			if escena_actual.listo:
				puntero_escena += 1
				if puntero_escena < escenas.size():
					escena_actual = escenas.values()[puntero_escena]
					escena_actual.reiniciar()

func reiniciar():
	if not continuar.is_connected(_on_continuar):
		continuar.connect(_on_continuar)
	for escena in escenas.values():
		escena.reiniciar()
	activar(0)

func cargar(nombre: String):
	var indice = escenas.keys().find(nombre)
	if indice == -1:
		push_error("No se encontró una escena con nombre " + nombre)
	activar(indice)

# TODO: pensar un mejor nombre que refleje su proposito
func activar(indice: int):
	if 0 <= indice and indice < escenas.size():
		puntero_escena = indice
		escena_actual = escenas.values()[puntero_escena]
		escena_actual.pausar(false)
		en_ejecucion = true
	else:
		printerr("Indice de escena fuera de rango")

func _on_continuar():
	if puntero_escena < escenas.size():
		escenas.values()[puntero_escena].pausar(false)
	
func agregar(escena: Escena):
	escenas[escena.nombre] = escena
