extends Node

class_name ControladorGuion

signal continuar

var unidades: Dictionary
var puntero_unidad: int = 0
var unidad_actual: Unidad

var en_ejecucion: bool = false

func _process(_delta):
	if en_ejecucion:
		if puntero_unidad >= unidades.size():
			en_ejecucion = false
		else:
			unidad_actual.procesar()
			if unidad_actual.listo:
				puntero_unidad += 1
				if puntero_unidad < unidades.size():
					unidad_actual = unidades.values()[puntero_unidad]
					unidad_actual.reiniciar()

func reiniciar():
	if not continuar.is_connected(_on_continuar):
		continuar.connect(_on_continuar)
	for unidad in unidades.values():
		unidad.reiniciar()
	activar(0)

func cargar(nombre: String):
	var indice = unidades.keys().find(nombre)
	if indice == -1:
		push_error("No se encontró una unidad con nombre " + nombre)
	activar(indice)

# TODO: pensar un mejor nombre que refleje su proposito
func activar(indice: int):
	if 0 <= indice and indice < unidades.size():
		puntero_unidad = indice
		unidad_actual = unidades.values()[puntero_unidad]
		unidad_actual.pausar(false)
		en_ejecucion = true
	else:
		push_error("Indice fuera de rango")

func _on_continuar():
	if puntero_unidad < unidades.size():
		unidades.values()[puntero_unidad].pausar(false)
	
func agregar(unidad: Unidad):
	unidades[unidad.nombre] = unidad
