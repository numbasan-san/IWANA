extends Node

@export var path_zonas: String

var nodos: Dictionary

# Obtiene una referencia a una zona cargada previamente, o agrega la zona si no
# se encuentra
func cargar(nombre_zona: String):
	var zona: Zona
	if nodos.has(nombre_zona):
		zona = nodos[nombre_zona]
	else:
		print("Agregando zona desde escena: " + str(nombre_zona))
		zona = load("res://" + path_zonas + "/" + nombre_zona + ".tscn").instantiate() as Zona
		nodos[nombre_zona] = zona
		zona.desactivar()
		add_child(zona)
		print("Agregada zona: " + zona.name)
		
	print("Cargada zona: " + zona.name)
	return zona
