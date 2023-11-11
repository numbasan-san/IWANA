extends Node

class_name Personajes

# La ruta donde se deben buscar los personajes
@export var path_personajes: String

# El jugador que actualmente está siendo controlado por el jugador. Puede ser
# null cuando aún no se ha asignado
var jugador: Personaje
# Todos los personajes que se han cargado, incluido el personaje del jugador.
# La llave es el nombre de la escena y el valor es el nodo instanciado
var personajes: Dictionary

# Obtiene una referencia a un personaje cargado previamente, o lo agrega si no
# se encuentra. Si un personaje con ese nombre no existe se retorna null
func cargar(nombre_personaje: String):
	nombre_personaje = nombre_personaje.to_lower()
	var personaje: Personaje
	if personajes.has(nombre_personaje):
		personaje = personajes[nombre_personaje]
	else:
		var scn = load("res://" + path_personajes + "/" + nombre_personaje + ".tscn")
		if not scn:
			return null
		personaje = scn.instantiate() as Personaje
		personajes[nombre_personaje] = personaje
		if personaje.modelo_rpg:
			# Se desactiva para evitar colisiones o uso de recursos
			personaje.modelo_rpg.desactivar()
		add_child(personaje)
		
	return personaje

# Cambia cuál es el personaje controlado por el jugador
# TODO: este código todavía no cambia el nodo ControlJugador, por lo que
# actualmente no tiene efecto
func cambiar_jugador(nombre_personaje: String):
	var personaje = cargar(nombre_personaje)
	if jugador:
		jugador.control_jugador = false
	personaje.control_jugador = true
	jugador = personaje
