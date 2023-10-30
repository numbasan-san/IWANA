extends Node

var jugador: Personaje
@export var path_personajes: String


var personajes: Dictionary

# Obtiene una referencia a un personaje cargado previamente, o lo agrega si no
# se encuentra
func cargar(nombre_personaje: String):
	var personaje: Personaje
	if personajes.has(nombre_personaje):
		personaje = personajes[nombre_personaje]
	else:
		personaje = load("res://" + path_personajes + "/" + nombre_personaje + ".tscn").instantiate() as Personaje
		personajes[nombre_personaje] = personaje
		if personaje.modeloMundo:
			personaje.modeloMundo.desactivar()
		add_child(personaje)
		
	return personaje

func cambiar_jugador(nombre_personaje: String):
	var personaje = cargar(nombre_personaje)
	if jugador:
		jugador.control_jugador = false
	personaje.control_jugador = true
	jugador = personaje
