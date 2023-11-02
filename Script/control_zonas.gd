extends Node

# La ruta donde se deben buscar las zonas
@export var path_zonas: String

# Todas las zonas que se han cargado. La llave es el nombre de la escena y
# el valor es el nodo instanciado
var zonas: Dictionary

# Obtiene una referencia a una zona cargada previamente, o agrega la zona si no
# se encuentra
func cargar(nombre_zona: String):
	# Nota: Esto solo funciona si todas las zonas están en la misma
	# carpeta, no se pueden organizar en subcarpetas. Arreglarlo para que
	# se busquen en subcarpetas	
	
	var zona: Zona
	if zonas.has(nombre_zona):
		zona = zonas[nombre_zona]
	else:
		zona = load("res://" + path_zonas + "/" + nombre_zona + ".tscn").instantiate() as Zona
		zonas[nombre_zona] = zona
		zona.desactivar()
		add_child(zona)
		
	return zona
