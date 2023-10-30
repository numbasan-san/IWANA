extends Node

@export var path_zonas: String

var zonas: Dictionary

# Obtiene una referencia a una zona cargada previamente, o agrega la zona si no
# se encuentra
func cargar(nombre_zona: String):
	var zona: Zona
	if zonas.has(nombre_zona):
		zona = zonas[nombre_zona]
	else:
		zona = load("res://" + path_zonas + "/" + nombre_zona + ".tscn").instantiate() as Zona
		zonas[nombre_zona] = zona
		zona.desactivar()
		add_child(zona)
		
	return zona
