extends Node2D

# Aca van algunas variables globales que afectarían todo el juego
# de manera que sea fácil encontrarlas y cambiarlas

@export var path_personajes: String
@export var path_zonas: String

# Funciones para cambiar el modo dev. Probablemente van a ser temporales
var devMode = false

func toggleDevMode():
	devMode = not devMode


# TODO: cambiar las funciones de carga para que vean si el elemento ya existe
# en los contenedores, y en caso que sea así retorne ese mismo. Si no, considerar
# hacer funciones distintas exclusivas para obtener los elementos ya cargados
# Esta función está parcialmente reemplazada por la función cargar en el nodo
# Zonas. Cuando el mismo código esté listo para personajes, hay que borrar esto
# Agrega el elemento a una lista global
func cargar(elemento: Variant):
	if elemento is Personaje:
		get_node("Personajes").add_child(elemento)
		for e in elemento.get_children():
			if e is Node2D:
				e.hide()
	elif elemento is Zona:
		get_node("Zonas").add_child(elemento)
		elemento.desactivar()
	elemento.process_mode = Node.PROCESS_MODE_DISABLED
	return elemento


func cargar_personaje(nombre_personaje: String):
	return cargar(load("res://" + path_personajes + "/" + nombre_personaje + ".tscn").instantiate())


func cargar_zona(nombre_zona: String):
	return $Zonas.cargar(nombre_zona)
	
