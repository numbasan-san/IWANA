extends Node2D

# Reconsiderar si esto va acá o en otra clase
# Este enum se usa en la función spawn para determinar qué se debe hacer si el
# punto de spawn entregado no existe. Si es ERROR, se imprime un error en la
# consola y no se cambia la posición del personaje. Si es ZERO, se colocará el
# personaje en el punto (0, 0). Uno debe asegurarse al diseñar la zona que ese
# punto esté en un lugar sin obstáculos. Si es FIRST, se elegirá el primer
# punto de spawn que se encuentre en la lista de puntos de la zona. Si no hay
# ningún punto definido, se usará ZERO
enum SpawnFallback{ ERROR, ZERO, FIRST }


# Remueve el personaje de la zona en la que está actualmente y lo coloca
# en la zona nueva
func reposition_character(
		character: Character,
		zona: Zona,
		posicion: Vector2 = Vector2(0, 0),
		direccion: String = 'down'):
	
	# Primero cambiamos al personaje de zona
	character.reposition(zona, posicion, direccion)
	
	# Si el personaje está controlado por el jugador, la zona en la que está
	# es la zona hija del nodo mundo, y hay que cambiarla
	if CharacterManager.player == character:
		
		# Si Mundo tiene una zona hija, y esta es distinta a la nueva zona,
		# Debe removerse y devolverse al contenedor Zonas
		if (get_child_count() > 0) and (get_child(0) != zona):
			var zona_actual = get_child(0)
			call_deferred("remove_child", zona_actual)
			ZoneManager.call_deferred("add_child", zona_actual)
			zona_actual.call_deferred("desactivar")
		
		# Si Mundo no tiene hijos o tiene pero es distinto a la zona nueva,
		# esta se debe sacar del contenedor Zonas
		if get_child_count() == 0 or get_child(0) != zona:
			ZoneManager.call_deferred("remove_child", zona)
			call_deferred("add_child", zona)
			zona.activar()
		
		# Si no, se está moviendo al personaje dentro
		# de la misma zona, no hay que cambiar nada

# Mueve este personaje a una posicion determinada por un nodo designado
# "Spawn" que debe ser colocado anteriormente en la zona
func spawn(
		character: Character,
		zona: Zona,
		punto_spawn: String = "Default",
		direccion: String = 'down',
		fallback: SpawnFallback = SpawnFallback.ZERO):
	
	var nodo_spawn = zona.get_node("Spawns").get_node(punto_spawn)
	var posicion: Vector2
	
	# Trata de encontrar el punto de spawn especificado y colocar el
	# personaje ahí
	if nodo_spawn:
		posicion = nodo_spawn.position
	# Si no se encuentra el spawn, se ejecuta una acción que depende de fallback
	else:
		# Se imprime un error y se termina la ejecución, para encontrar el error
		# más facilmente
		if fallback == SpawnFallback.ERROR:
			printerr("Punto de spawn " + "Spawns/" + punto_spawn + " no encontrado")
			return
		# Se busca si hay algún punto de spawn definido y se elige el primero
		elif fallback == SpawnFallback.FIRST:
			nodo_spawn = zona.get_node("Spawns").get_child(0)
			# Si se encuentra un spawn, se usa ese
			if nodo_spawn:
				posicion = nodo_spawn.position
			# Si no, por defecto se usa la posición (0, 0)
			else:
				posicion = Vector2(0, 0)
		# Se usa la posición (0, 0). Uno debe asegurarse que esté dentro de
		# la zona
		elif fallback == SpawnFallback.ZERO:
			posicion = Vector2(0, 0)
	# En cualquier caso, si la ejecución llega acá se tiene una posición válida
	reposition_character(character, zona, posicion, direccion)

